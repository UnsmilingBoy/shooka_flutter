import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';
import 'package:shooka_flutter/utils/scaffolds/profile_scaffold.dart';

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

  Widget app(Widget child) {
    final storage = const FlutterSecureStorage();
    final auth = AuthService(
      dio: Dio(),
      storage: storage,
      baseUrl: 'http://localhost',
    );
    final api = ApiService(dio: Dio(), auth: auth, storage: storage);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(api: api)),
      ],
      child: MaterialApp(home: child),
    );
  }

  Future<void> resize(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpAndSettle();
  }

  testWidgets('ProfileScaffold resize across breakpoint', (tester) async {
    await tester.pumpWidget(
      app(const ProfileScaffold(name: 't', username: 'u', body: SizedBox())),
    );
    await resize(tester, 1600);
    await resize(tester, 900);
    await resize(tester, 1600);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('BackScaffold resize across breakpoint', (tester) async {
    await tester.pumpWidget(
      app(
        const BackScaffold(
          label: 't',
          backLabel: 'h',
          backRoute: '/',
          body: SizedBox(),
        ),
      ),
    );
    await resize(tester, 1600);
    await resize(tester, 900);
    await resize(tester, 1600);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('navigate then resize during transition', (tester) async {
    final storage = const FlutterSecureStorage();
    final auth = AuthService(
      dio: Dio(),
      storage: storage,
      baseUrl: 'http://localhost',
    );
    final api = ApiService(dio: Dio(), auth: auth, storage: storage);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider(api: api)),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/page'),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
          routes: {
            '/page': (context) => const BackScaffold(
                  label: 'p',
                  backLabel: 'h',
                  backRoute: '/home',
                  body: SizedBox(),
                ),
          },
        ),
      ),
    );

    await resize(tester, 1600);
    await tester.tap(find.text('go'));
    await tester.pump();

    // Resize below the breakpoint mid-transition.
    await resize(tester, 900);

    await resize(tester, 1600);
    await resize(tester, 900);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
