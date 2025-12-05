import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/components/splash_screen.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/utils/consts/error_codes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys for remember me
  static const _kRememberMe = 'remember_me';
  static const _kSavedUsername = 'saved_username';
  static const _kSavedPassword = 'saved_password';

  bool _loading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String _error = "";
  String _version = "";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _loadVersion();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = info.version);
    }
  }

  Future<void> _loadSavedCredentials() async {
    final rememberMe = await _storage.read(key: _kRememberMe);
    if (rememberMe == 'true') {
      final savedUsername = await _storage.read(key: _kSavedUsername);
      final savedPassword = await _storage.read(key: _kSavedPassword);
      if (mounted) {
        setState(() {
          _rememberMe = true;
          if (savedUsername != null) usernameController.text = savedUsername;
          if (savedPassword != null) passwordController.text = savedPassword;
        });
      }
    }
  }

  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      await _storage.write(key: _kRememberMe, value: 'true');
      await _storage.write(
        key: _kSavedUsername,
        value: usernameController.text.trim(),
      );
      await _storage.write(
        key: _kSavedPassword,
        value: passwordController.text,
      );
    } else {
      await _storage.delete(key: _kRememberMe);
      await _storage.delete(key: _kSavedUsername);
      await _storage.delete(key: _kSavedPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [colorScheme.surface, colorScheme.surface]
                  : [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo with shadow
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/icons/romak-logo-blue.png",
                                width: 80,
                                height: 80,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Login Card
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    "خوش آمدید",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "برای ادامه وارد حساب کاربری خود شوید",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Username Field
                                  _buildTextField(
                                    controller: usernameController,
                                    label: "نام کاربری",
                                    icon: Icons.person_outline_rounded,
                                    colorScheme: colorScheme,
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  _buildTextField(
                                    controller: passwordController,
                                    label: "رمز عبور",
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    colorScheme: colorScheme,
                                  ),

                                  const SizedBox(height: 16),

                                  // Remember Me Checkbox
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  _rememberMe = value ?? false,
                                            );
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          activeColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _rememberMe = !_rememberMe,
                                        ),
                                        child: Text(
                                          "مرا به خاطر بسپار",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.7),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Error Message
                                  if (_error.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.error.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: colorScheme.error.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            color: colorScheme.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _error,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme.error,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 24),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _loading
                                          ? null
                                          : () => _handleLogin(auth),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.6),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              "ورود به حساب",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Footer
                            Text(
                              _version.isNotEmpty ? "نسخه $_version" : "",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.4,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool isPassword = false,
  }) {
    return TextField(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.5)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthService auth) async {
    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final ok = await auth.login(
        usernameController.text.trim(),
        passwordController.text,
      );
      if (ok) {
        await _saveCredentials();
        await getHomePageData(context);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (kDebugMode) print(ok);
        setState(() {
          _error = "نام کاربری یا رمز عبور اشتباه است.";
        });
      }
    } on DioException catch (e) {
      if (kDebugMode) print(e);
      setState(() => _error = errorCodeMessage(e.response?.statusCode));
    } catch (e) {
      if (kDebugMode) print(e);
      setState(() {
        _error = "مشکلی پیش آمده.";
      });
    } finally {
      setState(() => _loading = false);
    }
  }
}
