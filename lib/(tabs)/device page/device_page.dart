import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/device_image_slider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_device_information.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_installation_location_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_events.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_installation_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_more_device_info.dart';
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

      //
      // Body
      //
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            ImageSlider(
              imagePathList: [
                'assets/images/sample_device_pics/1.jpeg',
                'assets/images/sample_device_pics/2.jpeg',
                'assets/images/sample_device_pics/3.jpeg',
              ],
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
            DpEvents(),
          ],
        ),
      ),
    );
  }
}
