import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/base_page.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(body: Center(child: Text("Device List Page")));
  }
}
