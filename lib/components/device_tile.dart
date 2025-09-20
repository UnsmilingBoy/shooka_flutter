import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class DeviceTile extends StatelessWidget {
  final String name;
  final String city;
  final String status;
  final Color? color;
  final double? borderRadius;
  const DeviceTile({
    super.key,
    required this.name,
    required this.city,
    required this.status,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      borderRadius: borderRadius,
      onPressed: () {
        print("Navigate to device details");
      },
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: color,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          overflow: TextOverflow.ellipsis,
          name,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(overflow: TextOverflow.ellipsis, "شهر: $city"),
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
