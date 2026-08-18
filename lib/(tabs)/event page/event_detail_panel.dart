import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/edit_event_modal.dart';
import 'package:shooka_flutter/(tabs)/event%20page/event_content.dart';
import 'package:shooka_flutter/models/event_data_class.dart';

/// A panel version of EventPage that can be embedded in a split view.
/// This widget doesn't have its own scaffold - it's meant to be embedded.
class EventDetailPanel extends StatelessWidget {
  final String title;
  final String device;
  final String creator;
  final String timeCreated;
  final List<EventCategoryDetails> message;
  final VoidCallback? onClose;
  final int? eventGroupId;
  final String? factorId;
  final bool isCompleted;
  final String? completedAt;
  final bool isSent;
  final String? sentAt;
  final bool canEdit;
  final VoidCallback? onEditPressed;

  const EventDetailPanel({
    super.key,
    required this.title,
    required this.device,
    required this.creator,
    required this.timeCreated,
    required this.message,
    this.onClose,
    this.eventGroupId,
    this.factorId,
    this.isCompleted = false,
    this.completedAt,
    this.isSent = false,
    this.sentAt,
    this.canEdit = true,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "جزئیات رویداد",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canEdit)
                  IconButton(
                    icon: Icon(Icons.edit),
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
                    tooltip: 'ویرایش',
                    iconSize: 20,
                  ),
                if (onClose != null)
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: onClose,
                    tooltip: 'بستن',
                    iconSize: 20,
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
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
          ),
        ],
      ),
    );
  }
}
