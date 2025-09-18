import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/profile_scaffold.dart';

class EventsTab extends StatefulWidget {
  final bool openAddEvent;
  const EventsTab({super.key, required this.openAddEvent});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(
      body: Column(
        children: [Text("Events"), Text("add event is ${widget.openAddEvent}")],
      ),
    );
  }
}
