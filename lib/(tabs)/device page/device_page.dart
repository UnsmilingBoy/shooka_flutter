import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device%20images/components/device_image_slider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/basic%20device%20info/dp_basic_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device%20images/dp_device_images.dart';
import 'package:shooka_flutter/(tabs)/device%20page/location%20info/dp_installation_location_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/components/dp_events.dart';
import 'package:shooka_flutter/(tabs)/device%20page/installation%20info/dp_installation_info.dart';
import 'package:shooka_flutter/(tabs)/device%20page/usage%20info/dp_usage_info.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
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
    // Use addPostFrameCallback to ensure context is ready and avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<DeviceProvider>().loadCompleteDeviceInfo(
        id: widget.deviceId,
      ),
      context.read<EventProvider>().loadEvents(device: widget.deviceId),
    ]);
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final bool isDesktop =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;

    return BackScaffold(
      label: "جزئیات موتورخانه",
      backRoute: "/device_list",
      backLabel: "موتورخانه‌ها",
      onRefresh: isDesktop ? _refreshData : null,

      //
      // Body
      //
      body: deviceProvider.completeInfoLoading
          ? Center(child: Loading())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
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
                    // Add Pictures
                    //
                    DeviceImages(),

                    //
                    // Events
                    //
                    DpEvents(),
                  ],
                ),
              ),
            ),
    );
  }
}
