import 'package:dio/dio.dart';
import 'package:shooka_flutter/main.dart';
import 'auth_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthService auth;

  AuthInterceptor(this.auth);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await auth.getToken();
    if (token != null) {
      // Use Token authentication instead of Bearer
      options.headers['Authorization'] = 'Token $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;

    // If 401, redirect to login immediately (no refresh token in single token auth)
    if (status == 401) {
      // Clear stored token
      await auth.logout();

      // Redirect to login
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }

    // Forward error
    handler.next(err);
  }
}
