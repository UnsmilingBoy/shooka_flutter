import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/home/home_page.dart';
import 'package:shooka_flutter/(tabs)/login%20page/login.dart';
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

  Future<void> _checkAuth() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final token = await auth.getAccessToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final ok = await auth.tryRefreshToken();
      if (ok) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
        return;
      }
    }
    // fallback to login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

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
