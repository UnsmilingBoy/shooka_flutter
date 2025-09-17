import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/base_page.dart';

class DeviceList extends StatefulWidget {
  final bool openAddDevice;

  const DeviceList({super.key, required this.openAddDevice});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Column(
        children: [
          Text("Device List Page"),
          Text("Modal is ${widget.openAddDevice}"),
        ],
      ),
    );
  }
}
