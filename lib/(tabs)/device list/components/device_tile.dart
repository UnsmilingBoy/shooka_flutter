import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device_page.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class DeviceTile extends StatefulWidget {
  final String name;
  final String org;
  final String? status;
  final Color? color;
  final double? borderRadius;
  final int deviceId;
  final bool isFirst;

  const DeviceTile({
    super.key,
    required this.name,
    required this.org,
    required this.status,
    this.color,
    this.borderRadius,
    required this.deviceId,
    this.isFirst = false,
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
        subtitle: Text(
          overflow: TextOverflow.ellipsis,
          "سازمان: ${widget.org}",
        ),
        subtitleTextStyle: Theme.of(context).textTheme.labelSmall,
        trailing: Tooltip(
          key: _tooltipKey,
          message: "موتورخانه ${widget.status} است.",
          child: Icon(
            size: 15,
            Icons.circle,
            color: widget.status == "متصل" ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
