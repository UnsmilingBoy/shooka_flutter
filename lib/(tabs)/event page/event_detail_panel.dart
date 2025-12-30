import 'package:flutter/material.dart';
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

  const EventDetailPanel({
    super.key,
    required this.title,
    required this.device,
    required this.creator,
    required this.timeCreated,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Panel Header
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

          // Panel Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: EventContent(
                title: title,
                device: device,
                creator: creator,
                timeCreated: timeCreated,
                message: message,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
