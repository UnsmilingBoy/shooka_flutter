import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/home/home_page.dart';
import 'package:shooka_flutter/(tabs)/login%20page/login.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import '../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
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
        await getHomePageData();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
        return;
      } else {
        // Token expired → try to refresh
        final ok = await auth.tryRefreshToken();
        if (ok) {
          await getHomePageData();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MyHomePage()),
          );
          return;
        }
      }
    }

    // No token OR refresh failed → go to login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  //
  // Get HomePage Data
  //
  Future<void> getHomePageData() async {
    await context.read<UserProvider>().loadUserProfile();
    await context.read<GeneralProvider>().fetchFilters();
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
              Text(
                "سامانه شوکا",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Loading(),
            ],
          ),
        ),
      ),
    );
  }
}
