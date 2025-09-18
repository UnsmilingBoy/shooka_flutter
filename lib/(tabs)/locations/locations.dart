import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/profile_scaffold.dart';

class LocationsTab extends StatelessWidget {
  const LocationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(body: Text("Locations"));
  }
}
