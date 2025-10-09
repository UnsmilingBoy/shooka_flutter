import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/device_image_slider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_device_information.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_installation_location_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_events.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_installation_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_more_device_info.dart';
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
                  DeviceInformation(),

                  //
                  //  Install Location Info
                  //
                  InstallationLocationInfo(),

                  //
                  //  More Device Info
                  //
                  MoreDeviceInfo(),

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
