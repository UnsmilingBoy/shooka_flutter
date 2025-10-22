import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shooka_flutter/models/complete_device_info_data_class.dart';
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
    required String phoneNumber,
    required bool isActive,
    required String role,
    String? email,
    String? profilePic,
  }) async {
    var isSuperUser = false;
    var isStaff = false;

    if (role == "superuser") {
      isSuperUser = true;
      isStaff = true;
    } else if (role == "staff") {
      isSuperUser = false;
      isStaff = true;
    }

    var body = {
      "first_name": name,
      "username": username,
      "password": password,
      "is_active": isActive,
      "phone_number": phoneNumber,
      "email": email,
      "is_superuser": isSuperUser,
      "is_staff": isStaff,
      if (profilePic != null)
        "profile_image": "data:image/jpeg;base64,$profilePic",
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
  // Delete User
  //
  Future<int> deleteUser({required int id}) async {
    try {
      final response = await dio.delete('/api/users/$id/');

      log(response.data.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to delete user: ${e.response?.statusCode}");
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
    String? profilePic,
    int? id,
    String? role,
  }) async {
    final userId = id ?? await storage.read(key: "userId");
    bool? isSuperUser;
    bool? isStaff;

    if (role != null) {
      if (role == "superuser") {
        isSuperUser = true;
        isStaff = true;
      } else if (role == "staff") {
        isSuperUser = false;
        isStaff = true;
      } else {
        isSuperUser = false;
        isStaff = false;
      }
    }

    var body = {
      "username": username,
      "email": email,
      "first_name": name,
      "last_name": "",
      "phone_number_update": phoneNumber,
      if (profilePic != null)
        "profile_image_base64": "data:image/jpeg;base64,$profilePic",
      "is_superuser": isSuperUser,
      "is_staff": isStaff,
    };

    log("user update body: $body");

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
      log("${response.data}");

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
    int? page,
    int? installer,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? search,
  }) async {
    final queryParams = {
      "all": all == true ? "true" : "false",
      if (page != null) "page": page,
      if (installer != null) "installer": installer,
      if (organization != null) "organization": organization,
      if (administration != null) "administration": administration,
      if (province != null) "province": province,
      if (city != null) "city": city,
      if (search != null) "search": search,
    };

    log("query params for devices are: $queryParams");

    try {
      final response = await dio.get(
        '/apiv2/devices-list/',
        queryParameters: queryParams,
      );
      log(response.data.toString());

      if (response.statusCode == 200) {
        final List<dynamic> data = page != null
            ? response.data["results"]
            : response.data;
        return {
          "pages": response.data["total_pages"],
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
  // Add Device
  //
  Future<int> addDevice({
    required String name,
    required String serialNumber,
    required String installationAddress,
    required String engineRoomFeature,
    required int location,
    required int organization,
    required bool status,
    String? latLong,
    required List<String> images,
  }) async {
    var body = {
      "name": name,
      "serial_number": serialNumber,
      "installation_address": installationAddress,
      "engine_room_feature": engineRoomFeature,
      "location": location,
      "organization": organization,
      "status": status,
      "lat_long": latLong,
      "details": {"name": name, "serial_number": serialNumber},
      "images": images,
    };

    log(body.toString());
    try {
      final response = await dio.post('/apiv2/device/add/', data: body);
      log(response.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      log("Failed to add device: ${e.response}");
      return e.response!.statusCode!;
    }
  }

  //
  // Edit Device
  //
  Future<int> editDevice({
    required int id,
    String? name,
    String? serialNumber,
    String? installationAddress,
    String? engineRoomFeature,
    int? location,
    int? organization,
    bool? status,
    String? latLong,
  }) async {
    var body = {
      "id": id,
      if (name != null) "name": name,
      if (serialNumber != null) "serial_number": serialNumber,
      if (installationAddress != null)
        "installation_address": installationAddress,
      if (engineRoomFeature != null) "engine_room_feature": engineRoomFeature,
      if (location != null) "location": location,
      if (organization != null) "organization": organization,
      if (status != null) "status": status,
      if (latLong != null) "lat_long": latLong,
    };

    log(body.toString());
    try {
      final response = await dio.post('/apiv2/device/edit/', data: body);
      log(response.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      log("Failed to edit device: ${e.response}");
      return e.response!.statusCode!;
    }
  }

  //
  // Fetch Device Basic Info
  //
  Future<Device> fetchBasicDeviceInfo({required int id}) async {
    try {
      final response = await dio.get('/apiv2/objects/device/$id/');

      log(response.data.toString());
      return Device.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        "Failed to get Basic Device Info: ${e.response?.statusCode}",
      );
    }
  }

  //
  // Fetch Complete Device Page Info
  //
  Future<CompleteDeviceInfo> fetchDevicePageInfo({required int id}) async {
    try {
      final response = await dio.post(
        '/apiv2/device/retrieve-info/',
        data: {"device_id": id},
      );

      log(response.data.toString());
      return CompleteDeviceInfo.fromJson(response.data["data"]);
    } on DioException catch (e) {
      throw Exception(
        "Failed to get Complete Device Info: ${e.response?.statusCode}",
      );
    }
  }

  //
  // Update Complete Device Info
  //
  Future<int> updateCompleteDeviceInfo({
    // DEVICE ID and Object Type
    required int deviceId,
    required String objectType,
    // Location Public Info
    String? phoneNumber1,
    String? phoneNumber2,
    String? linkerPerson1,
    String? linkerPerson2,
    int? buildingMetrage,
    int? meterSubscriptionNumber,
    String? buildingImage, // base64
    // Engineroom Public Info
    String? usage, // both, heating, cooling
    bool? hasExchanger,
    int? numberOfPoolExchangers,
    int? numberOfJaccuziExchangers,
    int? numberOfFloorHeatingExchangers,
    int? numberOfBoilers,
    int? numberOfCirculatingPumps,
    int? numberOfCoilSources,
    int? numberOfCoilSourcesPumps,
    int? numberOfHotWaterPumps,
    // Installation Info
    String? installedDeviceModel, // 4relays, 8relays, 16relays
    String? connectionType, // internet, simcard
    String? modemModel,
    bool? hasSimcard,
    String? modemSimcardNumber,
    String? installationDate, // "1404-07-13 12:02:42"
    String? deviceSerialNumberImage, // base64
    String? modemSimcardSerialNumberImage, // base64
    // Engineroom Images
    List<String>? images, // base64
  }) async {
    late dynamic body;
    if (objectType == "locationpublicinfo") {
      body = {
        "object_type": "locationpublicinfo",
        // Location Public Info
        "phone_number1": phoneNumber1,
        "phone_number2": phoneNumber2,
        "linker_person1": linkerPerson1,
        "linker_person2": linkerPerson2,
        "building_metrage": buildingMetrage,
        "meter_subscription_number": meterSubscriptionNumber,
        if (buildingImage != null)
          "building_image": "data:image/jpeg;base64,$buildingImage",
      };
    } else if (objectType == "engineroompublicinfo") {
      body = {
        "object_type": "engineroompublicinfo",
        // Engineroom Public Info
        "usage": usage,
        "has_exchanger": hasExchanger,
        "number_of_pool_exchangers": numberOfPoolExchangers,
        "number_of_jaccuzi_exchangers": numberOfJaccuziExchangers,
        "number_of_floor_heating_exchangers": numberOfFloorHeatingExchangers,
        "number_of_boilers": numberOfBoilers,
        "number_of_circulating_pumps": numberOfCirculatingPumps,
        "number_of_coil_sources": numberOfCoilSources,
        "number_of_coil_sources_pumps": numberOfCoilSourcesPumps,
        "number_of_hot_water_pumps": numberOfHotWaterPumps,
      };
    } else if (objectType == "installationinfo") {
      body = {
        "object_type": "installationinfo",
        // Installation Info
        "installed_device_model": installedDeviceModel,
        "connection_type": connectionType,
        "modem_model": modemModel,
        "has_simcard": hasSimcard,
        "modem_simcard_number": modemSimcardNumber,
        "installation_date": installationDate,
        if (deviceSerialNumberImage != null)
          "device_serial_number_image":
              "data:image/jpeg;base64,$deviceSerialNumberImage",
        if (modemSimcardSerialNumberImage != null)
          "modem_simcard_serial_number_image":
              "data:image/png;base64,$modemSimcardSerialNumberImage",
      };
    } else if (objectType == "engineroomimages") {
      body = {"object_type": "engineroomimages", "images": images};
    }

    dynamic sendBody = {
      // DEVICE ID
      "device_id": deviceId,

      ...body,
    };

    log(sendBody.toString());
    try {
      final response = await dio.post(
        '/apiv2/device/edit-info/',
        data: sendBody,
      );
      log(response.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      log("Failed to update device: ${e.response}");
      return e.response!.statusCode!;
    }
  }

  //
  // Delete engineroom Image
  //
  Future<int> deleteEngineroomImages({
    required int deviceId,
    required List<int> idList,
  }) async {
    var body = {"device_id": deviceId, "images_id": idList};
    print(body);

    try {
      final response = await dio.post(
        '/apiv2/device/delete-images/',
        data: body,
      );
      log(response.data.toString());
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to remove images: ${e.response?.statusCode}");
    }
  }

  //
  // Fetch Filter Options
  //
  Future<dynamic> fetchFilters() async {
    try {
      final response = await dio.get('/apiv2/get_option_for_insert/');

      log("${response.data}");
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

  //
  // Get APK Version
  //
  Future<dynamic> fetchApkVersion() async {
    try {
      final response = await dio.get('/apiv2/apk-version/');

      log("${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw Exception("Failed to get apk version: ${e.response}");
    }
  }
}
