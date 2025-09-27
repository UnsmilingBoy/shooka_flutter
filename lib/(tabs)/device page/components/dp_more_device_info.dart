import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class MoreDeviceInfo extends StatelessWidget {
  const MoreDeviceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(
      title: "اطلاعات کاربری موتورخانه",
      children: [Text("turtle")],
    );
  }
}
