import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/device%20list/base_device_list.dart';
import 'package:shooka_flutter/models/device_filter_state.dart';

/// Suspended devices list page showing only devices under review (در حال بررسی)
class SuspendedDeviceList extends StatelessWidget {
  const SuspendedDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDeviceList(openAddDevice: false, mode: DeviceListMode.suspended);
  }
}
