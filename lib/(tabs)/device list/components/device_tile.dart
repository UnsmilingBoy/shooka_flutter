import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device_page.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

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

  const DeviceTile({
    super.key,
    required this.name,
    required this.org,
    required this.isConnected,
    this.color,
    this.borderRadius,
    required this.deviceId,
    this.isFirst = false,
    this.installationDate,
    this.address,
    this.status,
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
            // Show details in a row on larger screens only
            if (showDetailsInRow &&
                (widget.installationDate != null ||
                    widget.address != null ||
                    widget.status != null))
              Row(
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
                      (widget.address != null || widget.status != null))
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
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        widget.address!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ],
                  // Divider
                  if (widget.address != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        height: 12,
                        width: 1,
                        color: Colors.grey[400],
                      ),
                    ),
                  // Serial Number
                  if (widget.status != null) ...[
                    Icon(
                      Icons.check_box_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
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
          ],
        ),
        trailing: Tooltip(
          key: _tooltipKey,
          message: "موتورخانه ${widget.isConnected} است.",
          child: Icon(
            size: 15,
            Icons.circle,
            color: widget.isConnected == "متصل" ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
