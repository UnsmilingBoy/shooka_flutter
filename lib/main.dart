import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/device_list.dart';
import 'package:shooka_flutter/(tabs)/profile/profile_page.dart';
import 'package:shooka_flutter/core/theme/theme.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/(tabs)/home/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl, // Set RTL for the whole app
      child: MaterialApp(
        initialRoute: "/home",
        routes: {
          '/home': (context) => const MyHomePage(),
          '/profile': (context) => const ProfilePage(),
          '/device_list': (context) => const DeviceList(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Shooka',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
      ),
    );
  }
}
