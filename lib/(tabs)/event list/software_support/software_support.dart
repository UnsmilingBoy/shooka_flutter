import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/export_events_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/software_support/add_software_support_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/software_support/edit_software_support_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/software_support/filter_software_support_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20page/event_detail_panel.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class SoftwareSupport extends StatefulWidget {
  const SoftwareSupport({super.key});

  @override
  State<SoftwareSupport> createState() => _SoftwareSupportState();
}

class _SoftwareSupportState extends State<SoftwareSupport> {
  final ScrollController _scrollController = ScrollController();
  late final SoftwareSupportProvider _supportProvider;
  Event? _selectedEvent;
  String searchValue = "";

  @override
  void initState() {
    super.initState();

    _supportProvider = context.read<SoftwareSupportProvider>();
    Future.microtask(() async {
      await _supportProvider.loadEvents();
      if (mounted) _checkAndLoadMoreIfNeeded();
    });
    if (_supportProvider.users.isEmpty && !_supportProvider.usersLoading) {
      _supportProvider.fetchUsers();
    }
    _scrollController.addListener(_onScroll);
    _supportProvider.addListener(_onEventListChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _supportProvider.removeListener(_onEventListChanged);
    super.dispose();
  }

  void _onEventListChanged() {
    if (mounted && !context.read<SoftwareSupportProvider>().fetchLoading) {
      if (_selectedEvent != null) {
        final events = context.read<SoftwareSupportProvider>().events;
        final updatedEvent = events.firstWhere(
          (event) =>
              event.timestamp == _selectedEvent!.timestamp &&
              event.title == _selectedEvent!.title,
          orElse: () => _selectedEvent!,
        );
        setState(() {
          _selectedEvent = updatedEvent;
        });
      }

      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) _checkAndLoadMoreIfNeeded();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<SoftwareSupportProvider>();
      if (!provider.fetchLoading) provider.eventsNextPage();
    }
  }

  void _checkAndLoadMoreIfNeeded() {
    if (!mounted) return;

    final provider = context.read<SoftwareSupportProvider>();

    if (_scrollController.hasClients) {
      final position = _scrollController.position;

      if (position.maxScrollExtent <= 0 &&
          provider.eventsPage < provider.eventsTotalPages &&
          !provider.eventsNextPageLoading) {
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

  int? _eventIdOf(Event event) {
    return event.eventCategoryDetails.isNotEmpty
        ? event.eventCategoryDetails.first.eventId
        : null;
  }

  String _eventTextOf(Event event) {
    return event.eventCategoryDetails.isNotEmpty
        ? event.eventCategoryDetails.first.text
        : '';
  }

  void _handleExport() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => const ExportEventsModal(isSoftwareSupport: true),
      );
    } else {
      showMaterialModalBottomSheet(
        enableDrag: false,
        context: context,
        builder: (context) =>
            const ExportEventsModal(isSoftwareSupport: true),
      );
    }
  }

  void _openEditModal(Event event) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final modal = EditSoftwareSupportModal(
      eventGroupId: event.eventGroupId,
      eventId: _eventIdOf(event),
      title: event.title,
      text: _eventTextOf(event),
      registeredRequester: event.registeredRequester,
      externalRequester: event.externalRequester,
      requesterPhoneNumber: event.requesterPhoneNumber,
    );
    if (isDesktop) {
      showDialog(context: context, builder: (context) => modal);
    } else {
      showMaterialModalBottomSheet(
        context: context,
        enableDrag: false,
        builder: (context) => modal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final provider = context.watch<SoftwareSupportProvider>();
    final events = provider.events;
    final getLoading = provider.fetchLoading;
    final nextPageLoading = provider.eventsNextPageLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final accessControl = context.watch<UserProvider>().accessControl;
    final canAddEvent = accessControl.hasAccessTo(
      AppPanel.addEventFunctionality,
    );
    final canUseSplitView = screenWidth > 1200;
    final showSplitView = canUseSplitView && _selectedEvent != null;

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "پشتیبانی نرم افزاری",
      floatingActionButton: canAddEvent
          ? AddFloatingButton(addModal: AddSoftwareSupportModal())
          : null,
      body: showSplitView
          ? _buildSplitView(
              context,
              provider,
              events,
              searchController,
              getLoading,
              nextPageLoading,
            )
          : _buildNormalView(
              context,
              provider,
              events,
              searchController,
              getLoading,
              nextPageLoading,
              canUseSplitView,
            ),
    );
  }

  Widget _buildSplitView(
    BuildContext context,
    SoftwareSupportProvider provider,
    List<Event> events,
    TextEditingController searchController,
    bool getLoading,
    bool nextPageLoading,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildHeader(provider, searchController),
              SizedBox(height: 10),
              _buildSearchIndicator(context),
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
            canEdit: true,
            onEditPressed: () => _openEditModal(_selectedEvent!),
            onClose: _closeDetailPanel,
          ),
        ),
      ],
    );
  }

  Widget _buildNormalView(
    BuildContext context,
    SoftwareSupportProvider provider,
    List<Event> events,
    TextEditingController searchController,
    bool getLoading,
    bool nextPageLoading,
    bool canUseSplitView,
  ) {
    return Column(
      spacing: 10,
      children: [
        _buildHeader(provider, searchController),
        _buildSearchIndicator(context),
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

  Widget _buildHeader(
    SoftwareSupportProvider provider,
    TextEditingController searchController,
  ) {
    final canExport = context.read<UserProvider>().accessControl.hasAccessTo(
      AppPanel.exportFunctionality,
    );

    return TabHeader(
      onSubmitted: (value) async {
        setState(() {
          searchValue = value;
        });
        await provider.loadEvents(search: value);
      },
      searchController: searchController,
      filterModal: FilterSoftwareSupportModal(),
      searchPlaceholder: "جستجوی رویداد...",
      onExport: canExport ? _handleExport : null,
    );
  }

  Widget _buildSearchIndicator(BuildContext context) {
    if (searchValue == "") return SizedBox.shrink();

    return Padding(
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
        final isSelected =
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
            canEdit: true,
            onEditPressed: () => _openEditModal(event),
            detailBackRoute: "/software_support",
            detailBackLabel: "پشتیبانی نرم افزاری",
            detailRouteName: "/software_support_event_page",
            onTap: enableSplitViewClick ? () => _selectEvent(event) : null,
          ),
        );
      },
    );
  }
}
