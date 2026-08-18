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
  final int? eventGroupId;
  final String? factorId;
  final bool isCompleted;
  final String? completedAt;
  final bool isSent;
  final String? sentAt;
  final bool canEdit;
  final VoidCallback? onEditPressed;
  final String backRoute;
  final String backLabel;

  const EventPage({
    super.key,
    required this.title,
    required this.device,
    required this.creator,
    required this.timeCreated,
    required this.message,
    this.eventGroupId,
    this.factorId,
    this.isCompleted = false,
    this.completedAt,
    this.isSent = false,
    this.sentAt,
    this.canEdit = true,
    this.onEditPressed,
    this.backRoute = "/events",
    this.backLabel = "رویدادها",
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return BackScaffold(
      label: "جزئیات رویداد",
      backRoute: backRoute,
      backLabel: backLabel,
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: onEditPressed ??
                  () {
                    if (isDesktop) {
                      showDialog(
                        context: context,
                        builder: (context) => EditEventModal(
                          deviceName: device,
                          title: title,
                          timestamp: timeCreated,
                          eventCategoryDetails: message,
                          eventGroupId: eventGroupId,
                          factorId: factorId,
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
                          eventGroupId: eventGroupId,
                          factorId: factorId,
                        ),
                      );
                    }
                  },
              label: Text("ویرایش"),
              icon: Icon(Icons.edit),
            )
          : null,
      body: SingleChildScrollView(
        child: EventContent(
          title: title,
          device: device,
          creator: creator,
          timeCreated: timeCreated,
          message: message,
          eventGroupId: eventGroupId,
          factorId: factorId,
          isCompleted: isCompleted,
          completedAt: completedAt,
          isSent: isSent,
          sentAt: sentAt,
        ),
      ),
    );
  }
}
