import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/add_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/filter_event_modal.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/sample_datas.dart';
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
      body: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            //
            // Header (Search and Filter)
            //
            TabHeader(
              searchController: searchController,
              filterModal: FilterEventModal(),
              searchPlaceholder: "جستجوی رویداد...",
            ),

            //
            // Events List
            //
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: logsSampleData.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: EventTile(
                  eventId: logsSampleData[index]["event_id"] as int,
                  title: logsSampleData[index]["title"] as String,
                  author: logsSampleData[index]["author"] as String,
                  device: logsSampleData[index]["device"] as String,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
