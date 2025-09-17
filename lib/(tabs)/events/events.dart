import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/base_page.dart';

class EventsTab extends StatefulWidget {
  final bool openAddEvent;
  const EventsTab({super.key, required this.openAddEvent});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Column(
        children: [Text("Events"), Text("add event is ${widget.openAddEvent}")],
      ),
    );
  }
}
