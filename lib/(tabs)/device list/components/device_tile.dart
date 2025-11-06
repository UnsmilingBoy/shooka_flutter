import 'dart:io';

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
    final showDetailsInRow = screenWidth > 600;

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
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: widget.color,

      //
      // The actual tile.
      //
      child: ListTile(
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

            //
            // Show details in a row on larger screens only
            //
            if (showDetailsInRow &&
                (widget.installationDate != null ||
                    widget.address != null ||
                    widget.status != null ||
                    widget.creator != null))
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Installation Date
                    if (widget.installationDate != null) ...[
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        widget.installationDate!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                    // Divider
                    if (widget.installationDate != null &&
                        (widget.address != null ||
                            widget.status != null ||
                            widget.creator != null))
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          height: 12,
                          width: 1,
                          color: Colors.grey[400],
                        ),
                      ),
                    // Address
                    if (widget.address != null) ...[
                      Icon(Icons.location_on, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        widget.address!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                    // Divider
                    if (widget.address != null &&
                        (widget.creator != null || widget.status != null))
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          height: 12,
                          width: 1,
                          color: Colors.grey[400],
                        ),
                      ),
                    // Creator
                    if (widget.creator != null) ...[
                      Icon(Icons.person, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        widget.creator!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                    // Divider
                    if (widget.creator != null && widget.status != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          height: 12,
                          width: 1,
                          color: Colors.grey[400],
                        ),
                      ),
                    // Status
                    if (widget.status != null) ...[
                      Icon(Icons.check, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        widget.status!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
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
                color: widget.isConnected == "متصل" ? Colors.green : Colors.red,
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

                  // For web and Windows, use Google Maps URL
                  // For mobile (Android/iOS), use geo: URI for app chooser
                  String url;
                  if (kIsWeb || Platform.isWindows) {
                    url =
                        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                  } else {
                    url = 'geo:$lat,$lng?q=$lat,$lng';
                  }

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
