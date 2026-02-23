import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/accounting/accounting_tab.dart';
import 'package:shooka_flutter/(tabs)/device%20list/device_list.dart';
import 'package:shooka_flutter/(tabs)/device%20list/rejected_device_list.dart';
import 'package:shooka_flutter/(tabs)/device%20list/suspended_device_list.dart';
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
import 'package:shooka_flutter/services/connection_error_interceptor.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/encryption_interceptor.dart';
import 'package:shooka_flutter/services/encryption_service.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:toastification/toastification.dart';

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final baseUrl = 'https://romaktech2.ir';
  // final baseUrl = 'https://teska-lab.romaksystem.com';
  final baseUrl = 'https://api.test.romaksystem.com';

  final storage = const FlutterSecureStorage();

  // Initialize encryption service and keys
  final encryptionService = EncryptionService(storage: storage);
  await encryptionService.initializeKeys();

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      sendTimeout: Duration(seconds: 15),
    ),
  );

  final authService = AuthService(dio: dio, storage: storage, baseUrl: baseUrl);

  // Add interceptors in order: Connection Error, Auth, then Encryption
  dio.interceptors.add(ConnectionErrorInterceptor());
  dio.interceptors.add(AuthInterceptor(authService));
  dio.interceptors.add(EncryptionInterceptor(encryptionService));

  final apiService = ApiService(dio: dio, auth: authService, storage: storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>.value(value: authService),
        Provider<Dio>.value(value: dio),
        Provider<ApiService>.value(value: apiService),
        Provider<EncryptionService>.value(value: encryptionService),
        // Provide GeneralProvider first so it can be injected into other providers
        ChangeNotifierProvider(create: (_) => GeneralProvider(api: apiService)),

        // Inject GeneralProvider into UserProvider via Proxy so UserProvider can call fetchFilters()
        ChangeNotifierProxyProvider<GeneralProvider, UserProvider>(
          create: (_) => UserProvider(api: apiService),
          update: (context, general, userProvider) {
            userProvider ??= UserProvider(api: apiService);
            userProvider.setGeneralProvider(general);
            return userProvider;
          },
        ),

        ChangeNotifierProvider(create: (_) => EventProvider(api: apiService)),

        // Inject GeneralProvider into DeviceProvider via Proxy
        ChangeNotifierProxyProvider<GeneralProvider, DeviceProvider>(
          create: (_) => DeviceProvider(api: apiService),
          update: (context, general, deviceProvider) {
            deviceProvider ??= DeviceProvider(api: apiService);
            deviceProvider.setGeneralProvider(general);
            return deviceProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ToastificationWrapper(
        child: Builder(
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context);

            return MaterialApp(
              navigatorKey: navigatorKey,
              home: SplashPage(),
              routes: {
                '/login': (context) => const LoginPage(),
                '/home': (context) => const MyHomePage(),
                '/profile': (context) => const ProfilePage(),
                '/device_list': (context) =>
                    const DeviceList(openAddDevice: false),
                '/rejected_devices': (context) => const RejectedDeviceList(),
                '/suspended_devices': (context) => const SuspendedDeviceList(),
                // I handle '/device_page' in DeviceTile with MaterialPageRoute and set its RouteSetting name to '/device_page' for passing device id.
                '/add_device': (context) =>
                    const DeviceList(openAddDevice: true),
                '/events': (context) => const EventsTab(openAddEvent: false),
                // I handle '/event_page' in EventTile Just like /device_page.
                '/add_event': (context) => const EventsTab(openAddEvent: true),
                '/organizations': (context) => const OrganiztionsTab(),
                '/views': (context) => const ViewsTab(),
                '/locations': (context) => const LocationsTab(),
                '/users': (context) => const UsersTab(),
                '/accounting': (context) => const AccountingTab(),
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
              builder: (context, child) {
                // Apply responsive font scaling
                final scale = AppTheme.getFontScale(context);
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
