import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/back_scaffold.dart';

class LocationsTab extends StatelessWidget {
  const LocationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "مکان ها",
      body: Text("Locations"),
    );
  }
}
