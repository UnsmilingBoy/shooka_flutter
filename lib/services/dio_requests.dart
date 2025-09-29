import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shooka_flutter/models/user.dart';
import 'auth_service.dart';

class ApiService {
  final Dio dio;
  final FlutterSecureStorage storage;
  final AuthService auth;

  ApiService({required this.dio, required this.auth, required this.storage});

  //
  // Fetch User
  //
  Future<User> fetchUserProfile() async {
    final userId = await storage.read(key: "userId");

    try {
      final response = await dio.get('/api/users/$userId/');

      log(response.data.toString());
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("Failed to get user profile: ${e.response?.statusCode}");
    }
  }

  //
  // Update User
  //
  Future<void> updateUserProfile(name, username, email, phoneNumber) async {
    final userId = await storage.read(key: "userId");

    var body = {
      "username": username,
      "email": email,
      "first_name": name,
      "last_name": "",
    };

    try {
      final response = await dio.patch('/api/users/$userId/', data: body);
      log(response.toString());
    } on DioException catch (e) {
      throw Exception(
        "Failed to update user profile: ${e.response?.statusCode}",
      );
    }
  }

  //
  // Change password
  //
  Future<int> changePassword(prevPassword, newPassword) async {
    final userId = await storage.read(key: "userId");

    var body = {"prev_password": prevPassword, "new_password": newPassword};

    try {
      final response = await dio.post(
        '/api/users/$userId/change_password/',
        data: body,
      );
      log(response.data.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to change password: ${e.response?.statusCode}");
    }
  }
}
