import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/device%20page/device_page.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class DeviceTile extends StatelessWidget {
  final String name;
  final String org;
  final String? status;
  final Color? color;
  final double? borderRadius;
  final int deviceId;

  const DeviceTile({
    super.key,
    required this.name,
    required this.org,
    required this.status,
    this.color,
    this.borderRadius,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      // Navigates to DevicePage and passes deviceId.
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/device_page"),
          builder: (_) => DevicePage(deviceId: deviceId),
        ),
      ),
      borderRadius: borderRadius,
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: color,

      //
      // The actual tile.
      //
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          overflow: TextOverflow.ellipsis,
          name,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(overflow: TextOverflow.ellipsis, "سازمان: $org"),
        subtitleTextStyle: Theme.of(context).textTheme.labelSmall,
        trailing: Tooltip(
          message: "موتورخانه $status است.",
          child: Icon(
            size: 15,
            Icons.circle,
            color: status == "فعال" ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
