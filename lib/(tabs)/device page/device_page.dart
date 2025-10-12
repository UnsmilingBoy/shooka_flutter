import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device%20images/components/device_image_slider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/basic%20device%20info/dp_basic_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/location%20info/dp_installation_location_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_events.dart';
import 'package:shooka_flutter/(tabs)/device%20page/installation%20info/dp_installation_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/usage%20info/dp_usage_info.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class DevicePage extends StatefulWidget {
  final int deviceId;
  const DevicePage({super.key, required this.deviceId});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeviceProvider>().loadCompleteDeviceInfo(
        id: widget.deviceId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return BackScaffold(
      label: "جزئیات موتورخانه",
      backRoute: "/device_list",
      backLabel: "موتورخانه‌ها",

      //
      // Body
      //
      body: deviceProvider.completeInfoLoading
          ? Center(child: Loading())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  if (deviceProvider.completeDeviceInfo != null &&
                      deviceProvider
                          .completeDeviceInfo!
                          .engineroomImages
                          .isNotEmpty)
                    ImageSlider(
                      imagePathList: deviceProvider
                          .completeDeviceInfo!
                          .engineroomImages
                          .map((item) => item.image)
                          .toList(),
                    ),
                  //
                  // Device Information Tile
                  //
                  BasicDeviceInformation(),

                  //
                  //  Install Location Info
                  //
                  InstallationLocationInfo(),

                  //
                  //  More Device Info
                  //
                  UsageInfo(),

                  //
                  // Installation Info
                  //
                  InstallationInfo(),

                  //
                  // Events
                  //
                  DpEvents(deviceId: widget.deviceId),
                ],
              ),
            ),
    );
  }
}
