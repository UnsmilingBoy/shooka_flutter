import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/device_status_modal.dart';
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
  final bool? rawStatus; // true = approved, false = rejected, null = pending
  final String? rejectionNote; // Note explaining why device was rejected
  final String? creator;
  final String? latLong;
  final String plan;
  final bool isSelected; // For split view - highlights selected device
  final VoidCallback? onTap; // Custom tap handler for split view mode
  final bool compactMode; // For split view - shows simplified layout
  final bool
  showRejectedActions; // Show rejection note + status change buttons instead of status badge
  final bool
  showRejectionNote; // Show rejection note button (only for rejected mode, not suspended)

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
    this.rawStatus,
    this.rejectionNote,
    required this.creator,
    required this.latLong,
    required this.plan,
    this.isSelected = false,
    this.onTap,
    this.compactMode = false,
    this.showRejectedActions = false,
    this.showRejectionNote = false,
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

  void _showStatusModal() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => DeviceStatusModal(
          deviceId: widget.deviceId,
          deviceName: widget.name,
          currentStatus: widget.rawStatus,
        ),
      );
    } else {
      showMaterialModalBottomSheet(
        enableDrag: false,
        context: context,
        builder: (context) => DeviceStatusModal(
          deviceId: widget.deviceId,
          deviceName: widget.name,
          currentStatus: widget.rawStatus,
        ),
      );
    }
  }

  void _showRejectionNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'دلیل رد دستگاه',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'دستگاه: ${widget.name}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  widget.rejectionNote ?? 'دلیلی ثبت نشده است.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('بستن'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rejection Note Button (only for rejected mode)
        if (widget.showRejectionNote) ...[
          Tooltip(
            message: 'دلیل رد',
            child: IconButton(
              onPressed: _showRejectionNoteDialog,
              icon: Icon(Icons.note_alt_outlined, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.1),
                foregroundColor: Colors.orange,
                padding: EdgeInsets.all(8),
                minimumSize: Size(36, 36),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
        // Change Status Button
        Tooltip(
          message: 'تغییر وضعیت',
          child: IconButton(
            onPressed: _showStatusModal,
            icon: Icon(Icons.swap_horiz_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
              foregroundColor: Colors.blue,
              padding: EdgeInsets.all(8),
              minimumSize: Size(36, 36),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    // Determine color and text based on status
    Color statusColor;
    String statusText;

    if (widget.rawStatus == true) {
      statusColor = Colors.green;
      statusText = widget.status ?? 'تأیید شده';
    } else if (widget.rawStatus == false) {
      statusColor = Colors.red;
      statusText = widget.status ?? 'رد شده';
    } else {
      statusColor = Colors.orange;
      statusText = widget.status ?? 'در حال بررسی';
    }

    return GestureDetector(
      onTap: _showStatusModal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: statusColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusText,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: statusColor),
            ),
            SizedBox(width: 6),
            Icon(Icons.edit_outlined, size: 14, color: statusColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Use wide screen layout only if screen > 800 AND not in compact mode
    final isWideScreen = screenWidth > 800 && !widget.compactMode;

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

    // Determine the background color based on selection state
    Color? backgroundColor = widget.color;
    if (widget.isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    }

    return ContainerButton(
      // Use custom onTap if provided (split view mode), otherwise navigate
      onPressed:
          widget.onTap ??
          () => Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: "/device_page"),
              builder: (_) => DevicePage(deviceId: widget.deviceId),
            ),
          ),
      borderRadius: widget.borderRadius,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isWideScreen ? 25 : 0,
      ),
      color: backgroundColor,

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
                  flex: 1,
                  child: Text(
                    widget.installationDate ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                // Address
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.address ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.plan,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                // Status badge or Rejected Actions (clickable to open modal)
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: widget.showRejectedActions
                        ? _buildRejectedActions(context)
                        : _buildStatusBadge(context),
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
                style: Theme.of(context).textTheme.titleSmall?.apply(
                  color: widget.isSelected ? Colors.white : null,
                ),
              ),
              subtitle: Text(
                overflow: TextOverflow.ellipsis,
                "سازمان: ${widget.org}",
                style: Theme.of(context).textTheme.labelSmall?.apply(
                  color: widget.isSelected ? Colors.grey.shade400 : null,
                ),
              ),
              trailing: widget.showRejectionNote
                  // For rejected devices on mobile: only show rejection note button
                  ? IconButton(
                      onPressed: _showRejectionNoteDialog,
                      icon: Icon(Icons.note_alt_outlined, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        foregroundColor: Colors.orange,
                        padding: EdgeInsets.all(8),
                      ),
                      tooltip: 'دلیل رد',
                    )
                  : widget.showRejectedActions
                  // For suspended devices on mobile: no trailing widget (or we can add something else later)
                  ? null
                  // Normal devices: show connectivity and navigation
                  : Column(
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('خطا: $e')),
                                );
                              }
                            },
                          ),
                      ],
                    ),
            ),
    );
  }
}
