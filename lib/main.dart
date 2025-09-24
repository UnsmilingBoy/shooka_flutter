import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/device_list.dart';
import 'package:shooka_flutter/(tabs)/event%20list/events.dart';
import 'package:shooka_flutter/(tabs)/locations/locations.dart';
import 'package:shooka_flutter/(tabs)/login%20page/login.dart';
import 'package:shooka_flutter/(tabs)/organizations/organiztions.dart';
import 'package:shooka_flutter/(tabs)/profile/profile_page.dart';
import 'package:shooka_flutter/(tabs)/users/users.dart';
import 'package:shooka_flutter/(tabs)/views/views.dart';
import 'package:shooka_flutter/core/theme/theme.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/(tabs)/home/home_page.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl, // Set RTL for the whole app
      child: MaterialApp(
        initialRoute: "/home",
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const MyHomePage(),
          '/profile': (context) => const ProfilePage(),
          '/device_list': (context) => const DeviceList(openAddDevice: false),
          // I handle '/device_page' in DeviceTile with MaterialPageRoute and set its RouteSetting name to '/device_page' for passing device id.
          '/add_device': (context) => const DeviceList(openAddDevice: true),
          '/events': (context) => const EventsTab(openAddEvent: false),
          // I handle '/event_page' in EventTile Just like /device_page.
          '/add_event': (context) => const EventsTab(openAddEvent: true),
          '/organizations': (context) => const OrganiztionsTab(),
          '/views': (context) => const ViewsTab(),
          '/locations': (context) => const LocationsTab(),
          '/users': (context) => const UsersTab(),
        },
        locale: const Locale("fa", "IR"),
        supportedLocales: const [Locale("fa", "IR"), Locale("en", "US")],
        localizationsDelegates: const [
          PersianMaterialLocalizations.delegate,
          PersianCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'Shooka',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
      ),
    );
  }
}
