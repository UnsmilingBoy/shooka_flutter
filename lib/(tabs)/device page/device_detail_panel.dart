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

/// A panel version of DevicePage that can be embedded in a split view.
/// This widget doesn't have its own scaffold - it's meant to be embedded.
class DeviceDetailPanel extends StatefulWidget {
  final int deviceId;
  final String deviceName;
  final VoidCallback? onClose;

  const DeviceDetailPanel({
    super.key,
    required this.deviceId,
    required this.deviceName,
    this.onClose,
  });

  @override
  State<DeviceDetailPanel> createState() => _DeviceDetailPanelState();
}

class _DeviceDetailPanelState extends State<DeviceDetailPanel> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(DeviceDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when device changes
    if (oldWidget.deviceId != widget.deviceId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      context.read<DeviceProvider>().loadCompleteDeviceInfo(
        id: widget.deviceId,
      ),
      context.read<EventProvider>().loadEvents(device: widget.deviceId),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Panel Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.deviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDesktop)
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _refreshData,
                    tooltip: 'بروزرسانی',
                    iconSize: 20,
                  ),
                if (widget.onClose != null)
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: 'بستن',
                    iconSize: 20,
                  ),
              ],
            ),
          ),

          // Panel Content
          Expanded(
            child: _isLoading || deviceProvider.completeInfoLoading
                ? Center(child: Loading())
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (deviceProvider.completeDeviceInfo != null &&
                              deviceProvider
                                  .completeDeviceInfo!
                                  .engineroomImages
                                  .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ImageSlider(
                                  imagePathList: deviceProvider
                                      .completeDeviceInfo!
                                      .engineroomImages
                                      .map((item) => item.image)
                                      .toList(),
                                ),
                              ),
                            ),
                          //
                          // Device Information Tile
                          //
                          BasicDeviceInformation(),
                          SizedBox(height: 10),

                          //
                          //  Install Location Info
                          //
                          InstallationLocationInfo(),
                          SizedBox(height: 10),

                          //
                          //  More Device Info
                          //
                          UsageInfo(),
                          SizedBox(height: 10),

                          //
                          // Installation Info
                          //
                          InstallationInfo(),
                          SizedBox(height: 10),

                          //
                          // Add Pictures
                          //
                          DeviceImages(),
                          SizedBox(height: 10),

                          //
                          // Events
                          //
                          DpEvents(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
