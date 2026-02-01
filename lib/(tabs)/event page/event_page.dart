import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/edit_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20page/event_content.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class EventPage extends StatelessWidget {
  final String title;
  final String device;
  final String creator;
  final String timeCreated;
  final List<EventCategoryDetails> message;

  const EventPage({
    super.key,
    required this.title,
    required this.device,
    required this.creator,
    required this.timeCreated,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return BackScaffold(
      label: "جزئیات رویداد",
      backRoute: "/events",
      backLabel: "رویدادها",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isDesktop) {
            showDialog(
              context: context,
              builder: (context) => EditEventModal(
                deviceName: device,
                title: title,
                timestamp: timeCreated,
                eventCategoryDetails: message,
              ),
            );
          } else {
            showMaterialModalBottomSheet(
              context: context,
              enableDrag: false,
              builder: (context) => EditEventModal(
                deviceName: device,
                title: title,
                timestamp: timeCreated,
                eventCategoryDetails: message,
              ),
            );
          }
        },
        label: Text("ویرایش"),
        icon: Icon(Icons.edit),
      ),
      body: SingleChildScrollView(
        child: EventContent(
          title: title,
          device: device,
          creator: creator,
          timeCreated: timeCreated,
          message: message,
        ),
      ),
    );
  }
}
