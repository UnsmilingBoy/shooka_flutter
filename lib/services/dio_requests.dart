import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/models/user_data_class.dart';
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
  Future<void> updateUserProfile({
    required String name,
    required String username,
    required String email,
    required String phoneNumber,
  }) async {
    final userId = await storage.read(key: "userId");

    var body = {
      "username": username,
      "email": email,
      "first_name": name,
      "last_name": "",
      "phone_number_update": phoneNumber,
    };

    log(body.toString());

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
  Future<int> changePassword({
    required String prevPassword,
    required String newPassword,
  }) async {
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

  //
  // Fetch Event List
  //
  Future<List<Event>> fetchEventList({
    required bool all,
    int? creator,
    int? device,
    String? start,
    String? end,
    String? title,
    String? search,
  }) async {
    final queryParams = {
      "all": all == true ? "true" : "false",
      if (creator != null) "creator": creator,
      if (device != null) "device": device,
      if (start != null) "start": start,
      if (end != null) "end": end,
      if (title != null) "title": title,
      if (search != null) "search": search,
    };

    try {
      final response = await dio.get(
        '/api/event-history/',
        queryParameters: queryParams,
      );
      log(response.data.toString());

      final List<dynamic> data = all ? response.data : response.data["results"];
      return data.map((json) => Event.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception("Failed to get user profile: ${e.response?.statusCode}");
    }
  }

  //
  // Fetch Device List
  //
  Future<List<Device>> fetchDevices({
    required bool all,
    int? installer,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? search,
  }) async {
    final queryParams = {
      "all": all == true ? "true" : "false",
      if (installer != null) "installer": installer,
      if (organization != null) "organization": organization,
      if (administration != null) "administration": administration,
      if (province != null) "province": province,
      if (city != null) "city": city,
      if (search != null) "search": search,
    };

    try {
      final response = await dio.get(
        '/apiv2/devices-list/',
        queryParameters: queryParams,
      );
      log(response.data.toString());

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } on DioException catch (e) {
      throw Exception("Failed to get user profile: ${e.response?.statusCode}");
    }
  }

  //
  // Fetch Filter Options
  //
  Future<dynamic> fetchFilters() async {
    try {
      final response = await dio.get('/apiv2/get_option_for_insert/');

      log("boooooooooooooooo${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        "Failed to get filter options: ${e.response?.statusCode}",
      );
    }
  }
}
