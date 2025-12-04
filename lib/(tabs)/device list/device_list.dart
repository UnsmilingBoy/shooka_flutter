import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/device%20list/base_device_list.dart';
import 'package:shooka_flutter/models/device_filter_state.dart';

/// Device list page showing all devices
class DeviceList extends StatelessWidget {
  final bool openAddDevice;

  const DeviceList({super.key, required this.openAddDevice});

  @override
  Widget build(BuildContext context) {
    return BaseDeviceList(
      openAddDevice: openAddDevice,
      mode: DeviceListMode.all,
    );
  }
}
