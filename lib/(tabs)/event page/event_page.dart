import 'package:flutter/material.dart';
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
    return BackScaffold(
      label: "جزئیات رویداد",
      backRoute: "/events",
      backLabel: "رویدادها",
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
