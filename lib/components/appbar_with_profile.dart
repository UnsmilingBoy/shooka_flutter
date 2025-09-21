import 'package:flutter/material.dart';

class ProfileAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppbar({super.key});

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
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/profile.jpg"),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "s.shafizadeh",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  "سپنتا شفیع زاده",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
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
