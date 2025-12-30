import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/add_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/filter_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20page/event_detail_panel.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class EventsTab extends StatefulWidget {
  final bool openAddEvent;
  const EventsTab({super.key, required this.openAddEvent});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final ScrollController _scrollController = ScrollController();

  // Split view state
  Event? _selectedEvent;

  // Export loading state
  bool _exportLoading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<EventProvider>().loadEvents();
      // Check after initial load completes
      if (mounted) {
        _checkAndLoadMoreIfNeeded();
      }
    });
    _scrollController.addListener(_onScroll);

    // Listen to event provider changes and check if more items needed
    context.read<EventProvider>().addListener(_onEventListChanged);

    // Opens the add event modal if the route was "/add_event"
    if (widget.openAddEvent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMaterialModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => AddEventModal(),
        );
      });
    }
  }

  void _onEventListChanged() {
    // Check after list updates (e.g., after add/edit/delete)
    if (mounted && !context.read<EventProvider>().fetchLoading) {
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
    context.read<EventProvider>().removeListener(_onEventListChanged);
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

  Future<void> _handleExport() async {
    setState(() => _exportLoading = true);
    try {
      await context.read<EventProvider>().exportEventsToWord();
      filledSuccessToast(title: 'فایل ورد با موفقیت دانلود شد');
    } catch (e) {
      flatErrorToast(
        title: 'خطا در دانلود فایل ورد',
        description: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _exportLoading = false);
      }
    }
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
      floatingActionButton: AddFloatingButton(addModal: AddEventModal()),

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
                onExport: _handleExport,
                exportLoading: _exportLoading,
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
          onExport: _handleExport,
          exportLoading: _exportLoading,
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
