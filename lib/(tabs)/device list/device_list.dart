import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/back_scaffold.dart';

class DeviceList extends StatefulWidget {
  final bool openAddDevice;

  const DeviceList({super.key, required this.openAddDevice});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: "موتورخانه ها",
      backLabel: "خانه",
      backRoute: "/home",
      body: Column(
        children: [
          Row(children: [Text("لیست موتورخانه ها")]),
        ],
      ),
    );
  }
}
