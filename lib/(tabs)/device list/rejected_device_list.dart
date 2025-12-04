import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/device%20list/base_device_list.dart';
import 'package:shooka_flutter/models/device_filter_state.dart';

/// Rejected devices list page showing only rejected devices
class RejectedDeviceList extends StatelessWidget {
  const RejectedDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDeviceList(openAddDevice: false, mode: DeviceListMode.rejected);
  }
}
