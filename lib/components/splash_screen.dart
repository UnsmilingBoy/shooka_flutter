import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
      // Load package info (version)
      await _loadPackageInfo();

      // Fetch remote apk/version info
      await context.read<GeneralProvider>().fetchApkVersion();

      // Now it's safe to compare versions and show dialogs
      bool result = _maybeShowUpdateDialog();

      // Finally check auth (navigates away depending on token)
      if (result) await _checkAuth();
    });
  }

  bool _maybeShowUpdateDialog() {
    final general = context.read<GeneralProvider>();
    final remoteVersion = general.apkVersion;

    // If remoteVersion is empty we don't show the dialog. Otherwise compare.
    if (remoteVersion.isNotEmpty && remoteVersion != _version) {
      showDialog(
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
  // Check auth function (checks if the token is valid and refreshes if not)
  //
  Future<void> _checkAuth() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getAccessToken();
    print(token);

    if (token != null) {
      if (!JwtDecoder.isExpired(token)) {
        // Token still valid → go to home
        await getHomePageData(context);
        Navigator.pushReplacementNamed(context, "/home");
        return;
      } else {
        // Token expired → try to refresh
        final ok = await auth.tryRefreshToken();
        if (ok) {
          await getHomePageData(context);
          Navigator.pushReplacementNamed(context, "/home");
          return;
        }
      }
    }

    // No token OR refresh failed → go to login
    Navigator.pushReplacementNamed(context, "/login");
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
