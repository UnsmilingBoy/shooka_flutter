import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class DeviceInformation extends StatelessWidget {
  const DeviceInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(
      initiallyExpanded: true,
      title: "اطلاعات موتورخانه",
      children: [],
    );
  }
}
