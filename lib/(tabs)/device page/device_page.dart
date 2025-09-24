import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class DevicePage extends StatelessWidget {
  final int deviceId;
  const DevicePage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: "جزئیات موتورخانه",
      backRoute: "/device_list",
      backLabel: "موتورخانه‌ها",
      body: Text("Device Id: $deviceId"),
    );
  }
}
