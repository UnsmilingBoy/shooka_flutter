import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/add_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/add_invoice_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/export_events_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/filter_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20page/event_detail_panel.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class EventsTab extends StatefulWidget {
  final bool openAddEvent;
  const EventsTab({super.key, required this.openAddEvent});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final ScrollController _scrollController = ScrollController();
  late final EventProvider _eventProvider;

  // Scroll preservation across reloads (edit/status saves)
  double? _savedScrollOffset;
  bool _scrollRestorePending = false;

  // Split view state
  Event? _selectedEvent;

  @override
  void initState() {
    super.initState();

    _eventProvider = context.read<EventProvider>();

    Future.microtask(() async {
      await _eventProvider.loadEvents();
      // Check after initial load completes
      if (mounted) {
        _checkAndLoadMoreIfNeeded();
      }
    });
    _scrollController.addListener(_onScroll);

    // Listen to event provider changes and check if more items needed
    _eventProvider.addListener(_onEventListChanged);

    // Opens the add event modal if the route was "/add_event" and user has permission
    if (widget.openAddEvent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final canAdd = context.read<UserProvider>().accessControl.hasAccessTo(
          AppPanel.addEventFunctionality,
        );
        if (!canAdd) return;

        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 900;
        if (isDesktop) {
          showDialog(context: context, builder: (context) => AddEventModal());
        } else {
          showMaterialModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: (context) => AddEventModal(),
          );
        }
      });
    }
  }

  void _onEventListChanged() {
    final provider = context.read<EventProvider>();
    final isLoading = provider.fetchLoading;

    if (isLoading) {
      // Capture the current viewport before a "preserve scroll" reload
      // rebuilds the list (the old list is still attached at this point).
      if (provider.preserveScrollAfterReload &&
          !_scrollRestorePending &&
          _scrollController.hasClients) {
        _savedScrollOffset = _scrollController.offset;
        _scrollRestorePending = true;
      }
      return;
    }

    // A scroll-preserving reload just finished; restore the viewport.
    if (_scrollRestorePending) {
      _restoreScrollPositionAfterReload();
      return;
    }

    if (mounted) {
      // Update selected event with fresh data if it's currently shown
      if (_selectedEvent != null) {
        final events = provider.events;
        final updatedEvent = events.firstWhere(
          (event) =>
              event.timestamp == _selectedEvent!.timestamp &&
              event.deviceName == _selectedEvent!.deviceName,
          orElse: () => _selectedEvent!,
        );
        if (mounted) {
          setState(() {
            _selectedEvent = updatedEvent;
          });
        }
      }

      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          _checkAndLoadMoreIfNeeded();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _eventProvider.removeListener(_onEventListChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Trigger next page when near the end
      final provider = context.read<EventProvider>();
      if (!provider.fetchLoading) {
        provider.eventsNextPage();
      }
    }
  }

  // Check if viewport has enough items to scroll, if not load more
  void _checkAndLoadMoreIfNeeded() {
    if (!mounted) return;

    final provider = context.read<EventProvider>();

    // If we have a scroll controller with a position
    if (_scrollController.hasClients) {
      final position = _scrollController.position;

      // If list doesn't fill viewport (no scrolling possible)
      if (position.maxScrollExtent <= 0 &&
          provider.eventsPage < provider.eventsTotalPages &&
          !provider.eventsNextPageLoading) {
        // Load next page and check again
        provider.eventsNextPage().then((_) {
          if (mounted) {
            Future.delayed(
              Duration(milliseconds: 100),
              _checkAndLoadMoreIfNeeded,
            );
          }
        });
      }
    } else {
      // If no clients yet, wait a bit and try again
      Future.delayed(Duration(milliseconds: 100), _checkAndLoadMoreIfNeeded);
    }
  }

  /// Restore the scroll position to the saved offset after a reload.
  /// Loads additional pages until the saved offset becomes reachable,
  /// then jumps back to it.
  Future<void> _restoreScrollPositionAfterReload() async {
    final savedOffset = _savedScrollOffset;
    _savedScrollOffset = null;
    _scrollRestorePending = false;

    if (!mounted || savedOffset == null) return;

    final provider = context.read<EventProvider>();

    // Wait for the rebuilt list to attach to the scroll controller
    // (the widget rebuilds with the new data before this resolves).
    int attempts = 0;
    while (mounted && !_scrollController.hasClients && attempts < 50) {
      attempts++;
      await Future.delayed(Duration(milliseconds: 20));
    }
    if (!mounted || !_scrollController.hasClients) return;

    // Load more pages until the saved offset is reachable.
    while (mounted &&
        _scrollController.hasClients &&
        savedOffset > _scrollController.position.maxScrollExtent &&
        provider.eventsPage < provider.eventsTotalPages) {
      // Wait for any in-flight page request to finish
      if (provider.eventsNextPageLoading) {
        await Future.delayed(Duration(milliseconds: 50));
        continue;
      }
      await provider.eventsNextPage();
      if (!mounted) return;
      // Give the list a chance to rebuild with the new items
      await Future.delayed(Duration(milliseconds: 50));
    }

    if (!mounted || !_scrollController.hasClients) return;

    final targetOffset = savedOffset > _scrollController.position.maxScrollExtent
        ? _scrollController.position.maxScrollExtent
        : savedOffset;

    // Jump after the list has been rebuilt with the restored items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(targetOffset);
    });
  }

  void _selectEvent(Event event) {
    setState(() {
      _selectedEvent = event;
    });
  }

  void _closeDetailPanel() {
    setState(() {
      _selectedEvent = null;
    });
  }

  void _handleExport() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    if (isDesktop) {
      showDialog(context: context, builder: (context) => const ExportEventsModal());
    } else {
      showMaterialModalBottomSheet(
        enableDrag: false,
        context: context,
        builder: (context) => const ExportEventsModal(),
      );
    }
  }

  void _handleAddInvoice() {
    showDialog(context: context, builder: (context) => AddInvoiceModal());
  }

  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    final eventsProvider = context.watch<EventProvider>();

    final events = eventsProvider.events;
    final getLoading = eventsProvider.fetchLoading;
    final nextPageLoading = eventsProvider.eventsNextPageLoading;
    final screenWidth = MediaQuery.of(context).size.width;

    final accessControl = context.watch<UserProvider>().accessControl;
    final canAddEvent = accessControl.hasAccessTo(
      AppPanel.addEventFunctionality,
    );

    // Can use split view on screens wider than 1200px
    final bool canUseSplitView = screenWidth > 1200;
    // Actually show split view only when an event is selected
    final bool showSplitView = canUseSplitView && _selectedEvent != null;

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "رویداد ها",

      //
      // Floating action button
      //
      floatingActionButton: canAddEvent
          ? AddFloatingButton(addModal: AddEventModal())
          : null,

      //
      // Body
      //
      body: showSplitView
          ? _buildSplitView(
              context,
              eventsProvider,
              events,
              searchController,
              getLoading,
              nextPageLoading,
            )
          : _buildNormalView(
              context,
              eventsProvider,
              events,
              searchController,
              getLoading,
              nextPageLoading,
              canUseSplitView,
            ),
    );
  }

  /// Build the split view layout for large screens
  Widget _buildSplitView(
    BuildContext context,
    EventProvider eventsProvider,
    List<Event> events,
    TextEditingController searchController,
    bool getLoading,
    bool nextPageLoading,
  ) {
    final canExport = context.read<UserProvider>().accessControl.hasAccessTo(
      AppPanel.exportFunctionality,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event List Panel (Right side in RTL) - compact when detail is shown
        Expanded(
          flex: 4,
          child: Column(
            children: [
              // Header
              TabHeader(
                onSubmitted: (value) async {
                  setState(() {
                    searchValue = value;
                  });
                  await eventsProvider.loadEvents(search: value);
                },
                searchController: searchController,
                filterModal: FilterEventModal(),
                searchPlaceholder: "جستجوی رویداد...",
                onExport: canExport ? _handleExport : null,
                customButtons: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: MyIconButton(
                      onPressed: _handleAddInvoice,
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Search results indicator
              if (searchValue != "")
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "نتایج جستجو برای رویداد ها با نام: $searchValue",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),

              // Event List
              Expanded(
                child: getLoading
                    ? Center(child: Loading())
                    : events.isEmpty
                    ? Center(child: Text("رویدادی یافت نشد."))
                    : _buildEventListView(
                        context,
                        events,
                        nextPageLoading,
                        enableSplitViewClick: true,
                        compactMode: true,
                      ),
              ),
            ],
          ),
        ),

        // Detail Panel (Left side in RTL)
        SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: EventDetailPanel(
            key: ValueKey(_selectedEvent?.timestamp),
            title: _selectedEvent!.title,
            device: _selectedEvent!.deviceName,
            creator: _selectedEvent!.creator,
            timeCreated: _selectedEvent!.timestamp,
            message: _selectedEvent!.eventCategoryDetails,
            eventGroupId: _selectedEvent!.eventGroupId,
            factorId: _selectedEvent!.factorId,
            isCompleted: _selectedEvent!.isCompleted,
            completedAt: _selectedEvent!.completedAt,
            isSent: _selectedEvent!.isSent,
            sentAt: _selectedEvent!.sentAt,
            onClose: _closeDetailPanel,
          ),
        ),
      ],
    );
  }

  /// Build the normal (non-split) view for smaller screens
  Widget _buildNormalView(
    BuildContext context,
    EventProvider eventsProvider,
    List<Event> events,
    TextEditingController searchController,
    bool getLoading,
    bool nextPageLoading,
    bool canUseSplitView,
  ) {
    final canExport = context.read<UserProvider>().accessControl.hasAccessTo(
      AppPanel.exportFunctionality,
    );

    return Column(
      spacing: 10,
      children: [
        //
        // Header (Search and Filter)
        //
        TabHeader(
          onSubmitted: (value) async {
            setState(() {
              searchValue = value;
            });
            await eventsProvider.loadEvents(search: value);
          },
          searchController: searchController,
          filterModal: FilterEventModal(),
          searchPlaceholder: "جستجوی رویداد...",
          onExport: canExport ? _handleExport : null,
          customButtons: [
            SizedBox(
              height: 50,
              width: 50,
              child: MyIconButton(
                onPressed: _handleAddInvoice,
                color: Theme.of(context).colorScheme.tertiary,
                child: Icon(Icons.receipt_long_rounded, color: Colors.white),
              ),
            ),
          ],
        ),

        //
        // Searched For (Only appears when the user searches for something)
        //
        if (searchValue != "")
          Row(
            children: [
              Expanded(
                child: Text(
                  "نتایج جستجو برای رویداد ها با نام: $searchValue",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),

        //
        // Events List
        //
        Expanded(
          child: getLoading
              ? Center(child: Loading())
              : events.isEmpty
              ? Center(child: Text("رویدادی یافت نشد."))
              : _buildEventListView(
                  context,
                  events,
                  nextPageLoading,
                  enableSplitViewClick: canUseSplitView,
                ),
        ),
      ],
    );
  }

  Widget _buildEventListView(
    BuildContext context,
    List<Event> events,
    bool nextPageLoading, {
    required bool enableSplitViewClick,
    bool compactMode = false,
  }) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: nextPageLoading ? events.length + 1 : events.length,
      itemBuilder: (context, index) {
        if (index == events.length && nextPageLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Loading()),
          );
        }

        final event = events[index];
        final bool isSelected =
            _selectedEvent?.timestamp == event.timestamp &&
            _selectedEvent?.title == event.title;

        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: EventTile(
            timeCreated: event.timestamp,
            title: event.title,
            author: event.creator,
            device: event.deviceName,
            message: event.eventCategoryDetails,
            eventGroupId: event.eventGroupId,
            factorId: event.factorId,
            isCompleted: event.isCompleted,
            completedAt: event.completedAt,
            isSent: event.isSent,
            sentAt: event.sentAt,
            color: Theme.of(context).colorScheme.surface,
            isSelected: isSelected,
            compactMode: compactMode,
            onTap: enableSplitViewClick ? () => _selectEvent(event) : null,
          ),
        );
      },
    );
  }
}
