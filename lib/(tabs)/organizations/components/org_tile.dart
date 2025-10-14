import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class OrgTile extends StatelessWidget {
  final double? borderRadius;
  final String orgName;
  final String orgParent;
  final Color? color;
  final VoidCallback? onPressed;
  const OrgTile({
    super.key,
    this.borderRadius,
    required this.orgName,
    required this.orgParent,
    required this.color,
    this.onPressed,
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
                orgName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        // trailing: MyIconButton(
        //   padding: EdgeInsets.all(3),
        //   child: Icon(
        //     Icons.delete_forever_rounded,
        //     color: Theme.of(context).colorScheme.error,
        //   ),
        // ),
        subtitle: Text("نهاد: $orgParent"),
        subtitleTextStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.apply(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
