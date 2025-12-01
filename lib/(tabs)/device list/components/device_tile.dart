import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device_page.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceTile extends StatefulWidget {
  final String name;
  final String org;
  final String? isConnected;
  final Color? color;
  final double? borderRadius;
  final int deviceId;
  final bool isFirst;
  final String? installationDate;
  final String? address;
  final String? status;
  final String? creator;
  final String? latLong;

  const DeviceTile({
    super.key,
    required this.name,
    required this.org,
    required this.isConnected,
    this.color,
    this.borderRadius,
    required this.deviceId,
    this.isFirst = false,
    required this.installationDate,
    required this.address,
    required this.status,
    required this.creator,
    required this.latLong,
  });

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();

    // Only show tooltip for the first item
    if (widget.isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tooltipKey.currentState?.ensureTooltipVisible();

        // Auto-hide after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            _tooltipKey.currentState?.deactivate();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    // Parse latLong into LatLng
    LatLng? deviceLatLng;
    final latLongStr = widget.latLong;
    if (latLongStr != null && latLongStr.isNotEmpty) {
      final latLongParts = latLongStr.split(',');
      if (latLongParts.length == 2) {
        final lat = double.tryParse(latLongParts[0].trim());
        final lng = double.tryParse(latLongParts[1].trim());
        if (lat != null && lng != null) {
          deviceLatLng = LatLng(lat, lng);
        }
      }
    }

    return ContainerButton(
      // Navigates to DevicePage and passes deviceId.
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/device_page"),
          builder: (_) => DevicePage(deviceId: widget.deviceId),
        ),
      ),
      borderRadius: widget.borderRadius,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isWideScreen ? 16 : 0,
      ),
      color: widget.color,

      //
      // Wide screen layout: spread fields like columns
      //
      child: isWideScreen
          ? Row(
              children: [
                // Name
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                // Organization
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.org,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                // Creator
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.creator ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                // Installation Date
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.installationDate ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                // Address
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.address ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                // Status
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.status ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                // Connection status
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Tooltip(
                      key: _tooltipKey,
                      message: "موتورخانه ${widget.isConnected} است.",
                      child: Icon(
                        size: 12,
                        Icons.circle,
                        color: widget.isConnected == "متصل"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            )
          //
          // Mobile layout: original ListTile
          //
          : ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                overflow: TextOverflow.ellipsis,
                widget.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    "سازمان: ${widget.org}",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              trailing: Column(
                spacing: 7,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    key: _tooltipKey,
                    message: "موتورخانه ${widget.isConnected} است.",
                    child: Icon(
                      size: 15,
                      Icons.circle,
                      color: widget.isConnected == "متصل"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  //
                  // Navigation Button
                  //
                  if (widget.latLong != null && !kIsWeb)
                    MyIconButton(
                      padding: EdgeInsets.all(3),
                      child: Icon(Icons.navigation_rounded, size: 18),
                      onPressed: () async {
                        final lat = deviceLatLng!.latitude;
                        final lng = deviceLatLng.longitude;

                        // For mobile (Android/iOS), use geo: URI for app chooser
                        String url = 'geo:$lat,$lng?q=$lat,$lng';

                        try {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('خطا: $e')));
                        }
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
