import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/tabs_list.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

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

    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            //
            // Drawer Header
            //
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10, top: 60),
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
                bottom: 20,
                top: 5,
              ),
              child: Row(
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
                children: tabsList.map<Widget>((tab) {
                  final hrefs = (tab["href"] as List<dynamic>?)?.cast<String>();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ContainerButton(
                      color: (hrefs?.contains(routeName) ?? false)
                          ? Theme.of(context).primaryColor
                          : null,
                      borderRadius: 10,
                      padding: MediaQuery.of(context).size.width < 600
                          ? EdgeInsets.all(15)
                          : EdgeInsets.all(20),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(hrefs!.first);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Icon(
                            tab["icon"] as IconData,
                            size: 22,
                            color: hrefs?.contains(routeName) ?? false
                                ? Colors.white
                                : null,
                          ),
                          Text(
                            tab["label"] as String,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.apply(
                                  color: hrefs?.contains(routeName) ?? false
                                      ? Colors.white
                                      : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
        ),
      ),
    );
  }
}
