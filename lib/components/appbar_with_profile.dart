import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/models/user_data_class.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/constants.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';

class ProfileAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String name;
  final String username;
  final String? image;
  final User? user;
  const ProfileAppbar({
    super.key,
    required this.name,
    required this.username,
    this.image,
    this.user,
  });

  @override
  State<ProfileAppbar> createState() => _ProfileAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ProfileAppbarState extends State<ProfileAppbar> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

    if (!isDesktop) {
      return AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed("/profile"),
          child: _ProfileChip(
            name: widget.name,
            username: widget.username,
          ),
        ),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      title: MenuAnchor(
        controller: _menuController,
        alignmentOffset: const Offset(0, 8),
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surface,
          ),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(6),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        menuChildren: [
          _ProfileMenu(
            user: widget.user,
            name: widget.name,
            username: widget.username,
          ),
        ],
        builder: (context, controller, child) {
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
            child: _ProfileChip(
              name: widget.name,
              username: widget.username,
              showArrow: true,
              isOpen: controller.isOpen,
            ),
          );
        },
      ),
      actions: [
        MyIconButton(
          padding: const EdgeInsets.all(5),
          borderRadius: 1000,
          child: const Icon(Icons.brightness_4_rounded),
          onPressed: () {
            final themeProvider = Provider.of<ThemeProvider>(
              context,
              listen: false,
            );
            themeProvider.toggleTheme(!themeProvider.isDarkMode);
          },
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String name;
  final String username;
  final bool showArrow;
  final bool isOpen;

  const _ProfileChip({
    required this.name,
    required this.username,
    this.showArrow = false,
    this.isOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "U",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: Theme.of(context).textTheme.labelLarge),
              Text(name, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          if (showArrow)
            Icon(
              isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Theme.of(context).hintColor,
            ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatefulWidget {
  final User? user;
  final String name;
  final String username;

  const _ProfileMenu({
    required this.user,
    required this.name,
    required this.username,
  });

  @override
  State<_ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<_ProfileMenu> {
  bool _logOutLoading = false;

  Future<void> _signOut() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _logOutLoading = true;
    });
    await auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final name = user != null && user.firstName.isNotEmpty
        ? "${user.firstName} ${user.lastName}"
        : widget.name;
    final role = user?.userRole.userRoleLabel ?? "";
    final phone = user?.phoneNumber ?? "0";
    final email = user?.email ?? "بدون ایمیل";

    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            //
            // Header: avatar + name + role
            //
            Row(
              spacing: 10,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 26,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "U",
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.apply(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        role,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1),

            //
            // Profile details
            //
            _ProfileDetailTile(
              icon: Icons.person_rounded,
              label: "نام کاربری",
              value: widget.username,
            ),
            _ProfileDetailTile(
              icon: Icons.phone,
              label: "شماره همراه",
              value: phone,
            ),
            _ProfileDetailTile(
              icon: Icons.email,
              label: "ایمیل",
              value: email,
            ),
            const Divider(height: 1),

            //
            // Sign out button
            //
            ContainerButton(
              color: Theme.of(context).colorScheme.error,
              borderRadius: 10,
              padding: const EdgeInsets.all(12),
              fillWidth: true,
              onPressed: _logOutLoading ? null : _signOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  _logOutLoading
                      ? const Loading()
                      : const Icon(Icons.logout, size: 18, color: Colors.white),
                  Text(
                    "خروج از حساب",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.apply(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        Text("$label:", style: Theme.of(context).textTheme.labelMedium),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.apply(color: Theme.of(context).hintColor),
          ),
        ),
      ],
    );
  }
}
