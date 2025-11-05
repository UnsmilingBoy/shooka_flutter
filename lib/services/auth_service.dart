import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final Dio dio;
  final FlutterSecureStorage storage;
  final String baseUrl;

  // internal guard to avoid multiple simultaneous refresh calls
  Future<bool>? _refreshFuture;

  AuthService({
    required this.dio,
    required this.storage,
    required this.baseUrl,
  });

  // Keys for secure storage
  static const _kAccess = 'access';
  static const _kRefresh = 'refresh';
  static const _kUserId = 'userId';

  Future<bool> login(String username, String password) async {
    final resp = await dio.post(
      '/api/auth/login/',
      data: {'username': username, 'password': password},
    );
    log("LOGIN RESPONSE: $resp");

    final data = resp.data;
    if (data == null || data['access'] == null) return false;

    await storage.write(key: _kAccess, value: data['access']);
    await storage.write(key: _kRefresh, value: data['refresh']);
    log("User id is: ${data["user_id"]}");
    await storage.write(key: _kUserId, value: data['user_id'].toString());
    return true;
  }

  Future<void> logout() async {
    try {
      // 1️⃣ Get tokens from storage
      final accessToken = await storage.read(key: _kAccess);
      final refreshToken = await storage.read(key: _kRefresh);

      if (accessToken != null && refreshToken != null) {
        // 2️⃣ Call backend logout endpoint
        final res = await dio.post(
          "$baseUrl/api/auth/logout/",
          data: {"refresh": refreshToken},
          options: Options(
            headers: {
              "Authorization": "Bearer $accessToken",
              "Content-Type": "application/json",
            },
          ),
        );

        if (kDebugMode) {
          print(res);
        }
      }

      // 3️⃣ Delete tokens from storage
      await storage.delete(key: _kAccess);
      await storage.delete(key: _kRefresh);

      // 4️⃣ Clear Dio Authorization header
      dio.options.headers.remove('Authorization');
    } catch (e) {
      // optional: print error but still remove local tokens
      print("Logout error: $e");
      await storage.delete(key: _kAccess);
      await storage.delete(key: _kRefresh);
      dio.options.headers.remove('Authorization');
    }
  }

  Future<String?> getAccessToken() => storage.read(key: _kAccess);
  Future<String?> getRefreshToken() => storage.read(key: _kRefresh);

  bool isAccessTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  // Public wrapper that prevents parallel refresh attempts
  Future<bool> tryRefreshToken() async {
    if (_refreshFuture != null) return _refreshFuture!;
    _refreshFuture = _doRefresh();
    final result = await _refreshFuture!;
    _refreshFuture = null;
    return result;
  }

  // Actual refresh implementation (uses a plain Dio instance without our interceptor)
  Future<bool> _doRefresh() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;

    try {
      final plain = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
        ),
      );

      final resp = await plain.post(
        '/api/auth/token/refresh/',
        data: {'refresh': refresh},
      );
      final data = resp.data;
      if (data == null || data['access'] == null) return false;

      await storage.write(key: _kAccess, value: data['access']);
      // rotate refresh token if server gives a new one
      if (data['refresh'] != null) {
        await storage.write(key: _kRefresh, value: data['refresh']);
      }
      return true;
    } catch (e) {
      log('Token refresh failed: $e');
      // refresh failed (refresh token expired or invalid)
      await logout();
      return false;
    }
  }
}
