import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class UserTile extends StatelessWidget {
  final double? borderRadius;
  final String name;
  final String role;
  final Color? color;
  final String status;
  final VoidCallback? onPressed;
  const UserTile({
    super.key,
    this.borderRadius,
    required this.color,
    this.onPressed,
    required this.name,
    required this.role,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      borderRadius: borderRadius,
      onPressed: onPressed,
      color: color,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "U",
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        trailing: Tooltip(
          message: "کاربر $status است.",
          child: Icon(
            size: 15,
            Icons.circle,
            color: status == "فعال" ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Text("نقش: $role"),
        subtitleTextStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.apply(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
