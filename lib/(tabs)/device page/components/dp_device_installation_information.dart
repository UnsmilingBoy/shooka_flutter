import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class DeviceInstallationInformation extends StatelessWidget {
  const DeviceInstallationInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(title: "اطلاعات محل نصب", children: [Text("dog")]);
  }
}
