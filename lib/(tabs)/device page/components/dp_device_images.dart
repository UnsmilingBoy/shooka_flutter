import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class DeviceImages extends StatelessWidget {
  const DeviceImages({super.key});

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(title: "تصاویر موتورخانه", children: [Text("cat")]);
  }
}
