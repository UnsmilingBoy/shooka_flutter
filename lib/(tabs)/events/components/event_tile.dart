import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class EventTile extends StatelessWidget {
  final String title;
  final String author;
  final String device;
  final Color? color;
  final double? borderRadius;
  const EventTile({
    super.key,
    required this.title,
    required this.author,
    required this.device,
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
      color: color,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Expanded(
              child: Row(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.left,
                      author,
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    color: Theme.of(context).colorScheme.secondary,
                    Icons.person,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text("دستگاه: $device"),
        subtitleTextStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.apply(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
