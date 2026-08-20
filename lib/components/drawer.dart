import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/tabs_list.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  /// When true, renders as a persistent sidebar for desktop instead of a
  /// temporary drawer that slides in over the content.
  final bool sidebar;
  const MyDrawer({super.key, this.sidebar = false});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version; // e.g. "1.2.3"
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ); // FIXED

    String? routeName = ModalRoute.of(context)?.settings.name ?? "";

    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

    if (widget.sidebar) {
      return _SidebarContainer(
        child: _buildContent(
          context,
          routeName: routeName,
          isDesktop: isDesktop,
          themeProvider: themeProvider,
        ),
      );
    }

    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildContent(
          context,
          routeName: routeName,
          isDesktop: isDesktop,
          themeProvider: themeProvider,
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    // A drawer needs to close itself before navigating, a sidebar doesn't.
    if (!widget.sidebar) {
      Navigator.pop(context);
    }
    Navigator.of(context).pushNamed(route);
  }

  Widget _buildContent(
    BuildContext context, {
    required String routeName,
    required bool isDesktop,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      children: [
        //
        // Drawer Header
        //
        Container(
          margin: EdgeInsets.only(
            right: 10,
            left: 10,
            top: widget.sidebar ? 20 : 60,
          ),
          padding: const EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: 20,
            top: 5,
          ),
          child: widget.sidebar
              ?
              //
              // Sidebar header: bigger logo stacked above the app name.
              // The theme toggle lives in the homepage appbar on desktop.
              //
              Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 45,
                    child: Image.asset(
                      'assets/icons/romak-logo-blue.png',
                      color: Colors.blue,
                      colorBlendMode: BlendMode.srcATop,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'پنل شوکا',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'نسخه $_version',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              )
              :
              //
              // Drawer header: logo + app name on a row with the theme toggle.
              //
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 5,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 27,
                        child: Image.asset(
                          'assets/icons/romak-logo-blue.png',
                          color: Colors.blue,
                          colorBlendMode: BlendMode.srcATop, // Blend mode
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'پنل شوکا',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'نسخه $_version',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  //
                  // Light/Dark Mode Toggle
                  //
                  MyIconButton(
                    padding: EdgeInsets.all(5),
                    borderRadius: 1000,
                    child: Icon(Icons.brightness_4_rounded),
                    onPressed: () =>
                        themeProvider.toggleTheme(!themeProvider.isDarkMode),
                  ),
                ],
              ),
        ),

        //
        // Drawer Items
        //
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: tabsList
                .where((tab) {
                  // On desktop the profile is shown as a dropdown in the
                  // appbar, so the profile page entry is not needed.
                  final hrefs = (tab["href"] as List<dynamic>?)
                      ?.cast<String>();
                  if (isDesktop && (hrefs?.contains('/profile') ?? false)) {
                    return false;
                  }
                  final accessControl = context
                      .watch<UserProvider>()
                      .accessControl;
                  // Tabs without a panel key are always visible (e.g. Home, Profile)
                  final panel = tab["panel"] as AppPanel?;
                  if (panel == null) return true;
                  // For tabs with a panel key, check access control
                  if (accessControl.hasAccessTo(panel)) return true;
                  // A tab is also visible when the user can see one of its
                  // children (e.g. events tab when only software support is granted).
                  final children = tab["children"] as List<dynamic>?;
                  if (children == null) return false;
                  return children.any((child) {
                    final childPanel = (child as Map)["panel"] as AppPanel?;
                    return childPanel != null &&
                        accessControl.hasAccessTo(childPanel);
                  });
                })
                .map<Widget>((tab) {
                  final hrefs = (tab["href"] as List<dynamic>?)
                      ?.cast<String>();
                  final children = tab["children"] as List<dynamic>?;
                  final isActive = hrefs?.contains(routeName) ?? false;

                  // If tab has children, render expandable section
                  if (children != null && children.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: isActive,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: isActive
                              ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                              : null,
                          collapsedBackgroundColor: isActive
                              ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                              : null,
                          leading: Icon(
                            tab["icon"] as IconData,
                            size: 22,
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                          title: Text(
                            tab["label"] as String,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.apply(
                                  color: isActive
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                          ),
                          children: children
                              .where((child) {
                                final childPanel =
                                    (child as Map)["panel"] as AppPanel?;
                                if (childPanel == null) return true;
                                return context
                                    .read<UserProvider>()
                                    .accessControl
                                    .hasAccessTo(childPanel);
                              })
                              .map<Widget>((child) {
                            final childHrefs = (child["href"] as List<dynamic>?)
                                ?.cast<String>();
                            final isChildActive =
                                childHrefs?.contains(routeName) ?? false;

                            return Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ContainerButton(
                                color: isChildActive
                                    ? Theme.of(context).primaryColor
                                    : null,
                                borderRadius: 10,
                                padding:
                                    MediaQuery.of(context).size.width < 600
                                    ? EdgeInsets.all(12)
                                    : EdgeInsets.all(15),
                                onPressed: () {
                                  _navigate(context, childHrefs!.first);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 5,
                                    children: [
                                      Icon(
                                        child["icon"] as IconData,
                                        size: 18,
                                        color: isChildActive
                                            ? Colors.white
                                            : null,
                                      ),
                                      Text(
                                        child["label"] as String,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.apply(
                                              color: isChildActive
                                                  ? Colors.white
                                                  : null,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }

                  // Regular tab without children
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ContainerButton(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : null,
                      borderRadius: 10,
                      padding: MediaQuery.of(context).size.width < 600
                          ? EdgeInsets.all(15)
                          : EdgeInsets.all(20),
                      onPressed: () {
                        _navigate(context, hrefs!.first);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Icon(
                            tab["icon"] as IconData,
                            size: 22,
                            color: isActive ? Colors.white : null,
                          ),
                          Text(
                            tab["label"] as String,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.apply(
                                  color: isActive ? Colors.white : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ),

        //
        // Download Button
        //
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton.icon(
              onPressed: () async {
                final general = context.read<GeneralProvider>();
                final url = general.apkDownloadUrl;
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لینک دانلود موجود نیست')),
                  );
                  return;
                }
                try {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('خطا: $e')));
                }
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('دانلود آخرین نسخه'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Wraps the drawer content as a persistent sidebar on desktop screens.
class _SidebarContainer extends StatelessWidget {
  final Widget child;

  const _SidebarContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kSidebarWidth,
      color: Theme.of(context).colorScheme.surface,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    );
  }
}
