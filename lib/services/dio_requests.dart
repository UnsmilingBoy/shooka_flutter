import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/models/location_data_class.dart';
import 'package:shooka_flutter/models/org_data_class.dart';
import 'package:shooka_flutter/models/user_data_class.dart';
import 'auth_service.dart';

class ApiService {
  final Dio dio;
  final FlutterSecureStorage storage;
  final AuthService auth;

  ApiService({required this.dio, required this.auth, required this.storage});

  //
  // Fetch Users List
  //
  Future<dynamic> fetchUsersList({
    required int page,
    String? search,
    String? role,
    String? status,
  }) async {
    final queryParams = {
      "page": page,
      if (search != null) "search": search,
      if (role != null) "role": role,
      if (status != null) "status": status,
    };

    try {
      final response = await dio.get(
        '/api/users/',
        queryParameters: queryParams,
      );

      log("${response.data}");

      final List<dynamic> data = response.data["results"];

      final int totalPages = response.data["total_pages"];

      final usersList = data.map((json) => User.fromJson(json)).toList();
      log("UUUUUUUUUUUUSEEEEEEEEEEEEERS:");

      return {"pages": totalPages, "results": usersList};
    } on DioException catch (e) {
      throw Exception("Failed to Get Users List: ${e.response?.statusCode}");
    }
  }

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
  // Add User
  //
  Future<int> addUser({
    required String name,
    required String username,
    required String password,
    required bool
    isActive, //TODO: Need to add more parameters (apparently it has 2 apis)
  }) async {
    var body = {
      "first_name": name,
      "username": username,
      "password": password,
      "is_active": isActive,
    };

    log(body.toString());
    try {
      final response = await dio.post('/api/users/', data: body);
      log(response.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to add user: ${e.response}");
    }
  }

  //
  // Update User
  //
  Future<int> updateUserProfile({
    required String name,
    required String username,
    required String email,
    required String phoneNumber,
    int? id,
  }) async {
    final userId = id ?? await storage.read(key: "userId");

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
      return response.statusCode ?? -1;
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
  // Add Event
  //
  Future<int> addEvent({
    required String device,
    required String title,
    required List<dynamic> events,
  }) async {
    var body = {"device": device, "title": title, "events": events};

    log(body.toString());
    try {
      final response = await dio.post('/api/event-history/', data: body);
      log(response.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to add event: ${e.response}");
    }
  }

  //
  // Fetch Device List
  //
  Future<dynamic> fetchDevices({
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
        return {
          "data": data.map((json) => Device.fromJson(json)).toList(),
          "headers": response.headers,
        };
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

  //
  // Fetch Organization List
  //
  Future<dynamic> fetchOrganizationList({
    required int page,
    String? search,
  }) async {
    final queryParams = {"page": page, if (search != null) "search": search};

    try {
      final response = await dio.get(
        '/apiv2/objects/organization/',
        queryParameters: queryParams,
      );

      log("${response.data}");

      final List<dynamic> data = response.data["results"];
      final int totalPages = response.data["total_pages"];
      return {
        "pages": totalPages,
        "results": data.map((json) => Organization.fromJson(json)).toList(),
      };
    } on DioException catch (e) {
      throw Exception(
        "Failed to get filter options: ${e.response?.statusCode}",
      );
    }
  }

  //
  // Edit Organization
  //
  Future<int> editOrganization({
    String? name,
    String? administration,
    required int id,
  }) async {
    var body = {
      "id": id,
      "organization": name,
      "administration": administration,
    };
    print(body);

    try {
      final response = await dio.post(
        '/apiv2/objects/organization/edit/',
        data: body,
      );
      log(response.data.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to edit org: ${e.response?.statusCode}");
    }
  }

  //
  // Add Organization
  //
  Future<int> addOrganization({
    required String name,
    required String administration,
  }) async {
    var body = {"organization": name, "administration": administration};

    try {
      final response = await dio.post(
        '/apiv2/objects/organization/add/',
        data: body,
      );
      log(response.data.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to add org: ${e.response?.statusCode}");
    }
  }

  //
  // Fetch Locations List
  //
  Future<dynamic> fetchLocationsList({
    required int page,
    String? search,
  }) async {
    final queryParams = {"page": page, if (search != null) "search": search};

    try {
      final response = await dio.get(
        '/apiv2/objects/location/',
        queryParameters: queryParams,
      );

      log("${response.data}");
      final List<dynamic> data = response.data["results"];
      final int totalPages = response.data["total_pages"];
      return {
        "pages": totalPages,
        "results": data.map((json) => Location.fromJson(json)).toList(),
      };
    } on DioException catch (e) {
      throw Exception("Failed to fetch Locations: ${e.response?.statusCode}");
    }
  }

  //
  // Edit Locations
  //
  Future<int> editLocation({
    String? city,
    String? province,
    required int id,
  }) async {
    var body = {"id": id, "city": city, "province": province};

    try {
      final response = await dio.post(
        '/apiv2/objects/location/edit/',
        data: body,
      );
      log(response.data.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to edit location: ${e.response?.statusCode}");
    }
  }

  //
  // Add Organization
  //
  Future<int> addLocaiton({
    required String city,
    required String province,
  }) async {
    var body = {"city": city, "province": province};

    try {
      final response = await dio.post(
        '/apiv2/objects/location/add/',
        data: body,
      );
      log(response.data.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to add location: ${e.response?.statusCode}");
    }
  }
}
