import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/device_list.dart';
import 'package:shooka_flutter/(tabs)/event%20list/events_list.dart';
import 'package:shooka_flutter/(tabs)/locations/locations.dart';
import 'package:shooka_flutter/(tabs)/login%20page/login.dart';
import 'package:shooka_flutter/(tabs)/organizations/organiztions.dart';
import 'package:shooka_flutter/(tabs)/profile/profile_page.dart';
import 'package:shooka_flutter/(tabs)/users/users.dart';
import 'package:shooka_flutter/(tabs)/views/views.dart';
import 'package:shooka_flutter/components/splash_screen.dart';
import 'package:shooka_flutter/core/theme/theme.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/(tabs)/home/home_page.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shooka_flutter/services/auth_interceptor.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';

void main() {
  final baseUrl = 'https://shouka-test.romaksystem.com';
  final storage = const FlutterSecureStorage();
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  final authService = AuthService(dio: dio, storage: storage, baseUrl: baseUrl);
  dio.interceptors.add(AuthInterceptor(authService));

  final apiService = ApiService(dio: dio, auth: authService, storage: storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>.value(value: authService),
        Provider<Dio>.value(value: dio),
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => UserProvider(api: apiService)),
        ChangeNotifierProvider(create: (_) => EventProvider(api: apiService)),
        ChangeNotifierProvider(create: (_) => DeviceProvider(api: apiService)),
      ],
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
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        home: SplashPage(),
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
