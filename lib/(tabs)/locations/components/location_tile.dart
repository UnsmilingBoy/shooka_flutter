import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class LocationTile extends StatelessWidget {
  final double? borderRadius;
  final String city;
  final String province;
  final Color? color;
  final VoidCallback? onPressed;
  final VoidCallback? iconOnPressed;
  const LocationTile({
    super.key,
    this.borderRadius,
    this.color,
    required this.city,
    required this.province,
    this.onPressed,
    this.iconOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      borderRadius: borderRadius,
      onPressed: onPressed,
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
                city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        // trailing: MyIconButton(
        //   onPressed: iconOnPressed,
        //   padding: EdgeInsets.all(3),
        //   child: Icon(
        //     Icons.delete_forever_rounded,
        //     color: Theme.of(context).colorScheme.error,
        //   ),
        // ),
        subtitle: Text("استان: $province"),
        subtitleTextStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.apply(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
