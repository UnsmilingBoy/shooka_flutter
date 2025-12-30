import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/event_data_class.dart';

/// Shared content widget for displaying event details.
/// Used by both EventPage (mobile) and EventDetailPanel (large screens).
class EventContent extends StatelessWidget {
  final String title;
  final String device;
  final String creator;
  final String timeCreated;
  final List<EventCategoryDetails> message;

  const EventContent({
    super.key,
    required this.title,
    required this.device,
    required this.creator,
    required this.timeCreated,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          //
          // Title
          //
          Row(
            children: [
              Expanded(
                child: Text(
                  "عنوان: $title",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          Column(
            spacing: 2,
            children: [
              //
              // Device
              //
              Row(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.heat_pump_rounded,
                    size: 20,
                    color: Theme.of(context).hintColor,
                  ),
                  Expanded(
                    child: Text(
                      "دستگاه:  $device",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),

              //
              // Author
              //
              Row(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.attribution_outlined,
                    size: 20,
                    color: Theme.of(context).hintColor,
                  ),
                  Expanded(
                    child: Text(
                      "ایجادکننده:  $creator",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),

              //
              // Date
              //
              Row(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 20,
                    color: Theme.of(context).hintColor,
                  ),
                  Expanded(
                    child: Text(
                      "زمان ایجاد:  $timeCreated",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),

          //
          // Event (report) Content
          //
          Divider(color: Theme.of(context).hintColor),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: message
                .map(
                  (message) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Icon(
                        message.text == "" ? Icons.close : Icons.check,
                        color: Colors.green,
                      ),
                      Expanded(
                        child: Text("${message.category}: ${message.text}"),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
