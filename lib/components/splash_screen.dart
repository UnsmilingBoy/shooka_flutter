import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import '../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Load package info (version)
        await _loadPackageInfo();

        // Fetch remote apk/version info with timeout
        await context.read<GeneralProvider>().fetchApkVersion().timeout(
          Duration(seconds: 10),
          onTimeout: () {
            // Continue even if version check fails
            log('Version check timed out');
          },
        );

        // Now it's safe to compare versions and show dialogs
        bool shouldProceed = await _maybeShowUpdateDialog();

        // Only check auth if we should proceed (no update required or update dialog dismissed)
        if (shouldProceed) {
          await _checkAuth();
        }
      } catch (e) {
        log('Error in splash init: $e');
        // On any error, try to proceed to auth check
        await _checkAuth();
      }
    });
  }

  Future<bool> _maybeShowUpdateDialog() async {
    final general = context.read<GeneralProvider>();
    final remoteVersion = general.apkVersion;

    // If remoteVersion is empty we don't show the dialog. Otherwise compare.
    if (remoteVersion.isNotEmpty && remoteVersion != _version) {
      // Show dialog and wait indefinitely - user must update or close the app
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text("به‌روزرسانی موجود است"),
              content: const Text(
                "نسخه جدید برنامه موجود است. لطفاً برای استفاده از آخرین ویژگی‌ها و بهبودها، برنامه را به‌روزرسانی کنید.",
              ),
              actions: [
                ContainerButton(
                  fillWidth: true,
                  color: Theme.of(context).primaryColor,
                  borderRadius: 10,
                  child: Text("بروزرسانی"),
                  onPressed: () async {
                    final url = general.apkDownloadUrl;
                    if (url.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('خطا'),
                          content: const Text('لینک دانلود موجود نیست.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(c).pop(),
                              child: const Text('باشه'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    try {
                      final uri = Uri.parse(url);
                      // Skip canLaunchUrl - just try to launch directly
                      final launched = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );

                      if (!launched) {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('خطا'),
                            content: const Text('باز کردن لینک انجام نشد.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(),
                                child: const Text('باشه'),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      log('Error launching URL: $e');
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('خطا'),
                          content: Text('خطا هنگام باز کردن لینک: $e'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(c).pop(),
                              child: const Text('باشه'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version; // e.g. "1.2.3"
      // _buildNumber = info.buildNumber; // e.g. "45"
    });
  }

  //
  // Check auth function (checks if the user has a valid token)
  //
  Future<void> _checkAuth() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      // Check if user is authenticated (has a token)
      if (await auth.isAuthenticated()) {
        // Token exists → go to home
        await getHomePageData(context).timeout(
          Duration(seconds: 15),
          onTimeout: () {
            log('Home page data fetch timed out, proceeding anyway');
          },
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
        return;
      }

      // No token → go to login
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      log('Error in _checkAuth: $e');
      // On any error, go to login to let user sign in fresh
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  //
  // Splash Screen UI
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              Image.asset("assets/icons/romak-logo-blue.png", width: 150),
              Column(
                spacing: 5,
                children: [
                  Text(
                    "سامانه شوکا",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    "نسخه $_version",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              Loading(),
            ],
          ),
        ),
      ),
    );
  }
}

//
// Get HomePage Data
//
Future<void> getHomePageData(BuildContext context) async {
  await context.read<UserProvider>().loadUserProfile();
  await context.read<GeneralProvider>().fetchFilters();
}
