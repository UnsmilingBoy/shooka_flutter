import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/add_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/filter_event_modal.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<EventProvider>().loadEvents(all: true);
    });

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

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    final eventsProvider = context.watch<EventProvider>();

    final events = eventsProvider.events;

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
      body: Column(
        spacing: 10,
        children: [
          //
          // Header (Search and Filter)
          //
          TabHeader(
            onSubmitted: (value) async => await context
                .read<EventProvider>()
                .loadEvents(all: true, search: value),
            searchController: searchController,
            filterModal: FilterEventModal(),
            searchPlaceholder: "جستجوی رویداد...",
          ),

          //
          // Events List
          //
          eventsProvider.isLoading
              ? Expanded(child: Center(child: Loading())) // Loading Ui
              : events.isEmpty
              ? Expanded(child: Center(child: Text("رویدادی یافت نشد.")))
              : Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: EventTile(
                        timeCreated: events[index].timestamp,
                        title: events[index].title,
                        author: events[index].creator,
                        device: events[index].deviceName,
                        message: events[index].eventCategoryDetails,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
