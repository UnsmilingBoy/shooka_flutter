import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio dio;
  final FlutterSecureStorage storage;
  final String baseUrl;

  AuthService({
    required this.dio,
    required this.storage,
    required this.baseUrl,
  });

  // Keys for secure storage (single token now)
  static const _kToken = 'token';
  static const _kUserId = 'userId';

  Future<bool> login(String username, String password) async {
    try {
      final resp = await dio.post(
        '/api-token-auth/',
        data: {'username': username, 'password': password},
      );
      log("LOGIN RESPONSE: $resp");

      final data = resp.data;
      if (data == null || data['token'] == null) return false;

      await storage.write(key: _kToken, value: data['token']);

      // Store user_id if provided
      if (data['user_id'] != null) {
        log("User id is: ${data["user_id"]}");
        await storage.write(key: _kUserId, value: data['user_id'].toString());
      }

      return true;
    } on DioException catch (e) {
      log('Login error: $e');
      log('Response data: ${e.response?.data}');
      log('Response status: ${e.response?.statusCode}');
      log('Response headers: ${e.response?.headers}');
      return false;
    } catch (e) {
      log('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Get token from storage
      final token = await storage.read(key: _kToken);

      if (token != null) {
        // Call backend logout endpoint if available
        try {
          final res = await dio.post(
            "$baseUrl/api/auth/logout/",
            options: Options(
              headers: {
                "Authorization": "Token $token",
                "Content-Type": "application/json",
              },
            ),
          );

          if (kDebugMode) {
            print(res);
          }
        } catch (e) {
          log("Backend logout failed: $e");
        }
      }

      // Delete token from storage
      await storage.delete(key: _kToken);
      await storage.delete(key: _kUserId);

      // Clear Dio Authorization header
      dio.options.headers.remove('Authorization');
    } catch (e) {
      print("Logout error: $e");
      await storage.delete(key: _kToken);
      await storage.delete(key: _kUserId);
      dio.options.headers.remove('Authorization');
    }
  }

  Future<String?> getToken() => storage.read(key: _kToken);

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
