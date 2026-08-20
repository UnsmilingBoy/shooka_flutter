import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/home/home_page.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/providers/accounting_provider.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';

class MockHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Map<String, dynamic> body = {};
    if (options.path.contains('users/profile')) {
      body = {
        'data': {
          'user_id': 1,
          'is_admin': true,
          'username': 'admin',
          'email': 'a@b.c',
          'first_name': 'A',
          'last_name': 'B',
          'is_active': true,
          'created_at': '2020-01-01',
          'phone_number': '0',
          'access_level': 1,
          'access_apps': '',
          'user_role': {
            'user_access_level': 1,
            'user_role_name': 'admin',
            'user_role_label': 'Admin',
            'user_role_description': '',
            'user_can_send_command': false,
            'accessible_panels': [],
          },
          'max_allowable_active_tokens': 1,
          'identification_number': '0',
          'token_expires_in': 100000,
          'failed_login_count': 0,
          'last_login_ip_address': '',
          'last_successful_login': '2020-01-01',
          'ip_policy_type': '',
          'allowed_ips': '',
          'last_login': [],
          'active_tokens': [],
        },
      };
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (call) async {
        if (call.method == 'getAll') {
          return {
            'appName': 'test',
            'packageName': 'test',
            'version': '1.0.0',
            'buildNumber': '1',
            'buildSignature': '',
            'installerStore': null,
          };
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      null,
    );
  });

  Widget buildHome() {
    final storage = const FlutterSecureStorage();
    final auth = AuthService(
      dio: Dio(),
      storage: storage,
      baseUrl: 'http://localhost',
    );
    final api = ApiService(
      dio: Dio()..httpClientAdapter = MockHttpClientAdapter(),
      auth: auth,
      storage: storage,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => GeneralProvider(api: api),
        ),
        ChangeNotifierProxyProvider<GeneralProvider, UserProvider>(
          create: (_) => UserProvider(api: api),
          update: (context, general, userProvider) {
            userProvider ??= UserProvider(api: api);
            userProvider.setGeneralProvider(general);
            return userProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => EventProvider(api: api)),
        ChangeNotifierProvider(
          create: (_) => SoftwareSupportProvider(api: api),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountingProvider(api: api),
        ),
        ChangeNotifierProxyProvider<GeneralProvider, DeviceProvider>(
          create: (_) => DeviceProvider(api: api),
          update: (context, general, deviceProvider) {
            deviceProvider ??= DeviceProvider(api: api);
            deviceProvider.setGeneralProvider(general);
            return deviceProvider;
          },
        ),
      ],
      child: const MaterialApp(
        home: MyHomePage(),
      ),
    );
  }

  Future<void> resize(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpAndSettle();
  }

  testWidgets('home page resize across breakpoint', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(buildHome());
      await tester.pump(const Duration(milliseconds: 100));
    });

    await resize(tester, 1600);
    await resize(tester, 900);
    await resize(tester, 1600);
    await resize(tester, 1000);
    await resize(tester, 1200);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}