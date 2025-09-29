import 'package:flutter/material.dart';

class ProfileAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String username;
  final String image;
  const ProfileAppbar({
    super.key,
    required this.name,
    required this.username,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed("/profile"),
        child: Row(
          spacing: 7,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(backgroundImage: NetworkImage(image)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: Theme.of(context).textTheme.labelLarge),
                Text(name, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
