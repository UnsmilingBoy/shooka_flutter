import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class EventPage extends StatelessWidget {
  final int eventId;
  const EventPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: "جزئیات رویداد",
      backRoute: "/events",
      backLabel: "رویدادها",
      body: Text("Event Details Page $eventId"),
    );
  }
}
