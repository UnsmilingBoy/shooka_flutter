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
    try {
      final response = await dio.post('/api/shouka/users/profile');

      return User.fromJson(response.data["data"]);
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

    try {
      final response = await dio.post('/api/users/', data: body);
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

    try {
      final response = await dio.patch('/api/users/$userId/', data: body);
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
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to change password: ${e.response?.statusCode}");
    }
  }

  //
  // Fetch Event List
  //
  Future<dynamic> fetchEventList({
    required int page,
    int? dataPerPage,
    int? creator,
    int? device,
    String? start,
    String? end,
    String? title,
    String? search,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? plan,
  }) async {
    final queryParams = {
      "page": page,
      "data_per_page": dataPerPage ?? 10,
      if (creator != null) "creator": creator,
      if (device != null) "device": device,
      if (start != null) "start": start,
      if (end != null) "end": end,
      if (title != null) "title": title,
      if (search != null) "search": search,
      if (organization != null) "organization": organization,
      if (administration != null) "administration": administration,
      if (province != null) "province": province,
      if (city != null) "city": city,
      if (plan != null) "plan": plan,
    };

    try {
      final response = await dio.post(
        '/api/shouka/events/list/',
        data: queryParams,
      );

      log("${response.data}");

      final List<dynamic> data = response.data["results"];
      final int totalPages = response.data["total_pages"];

      return {
        "pages": totalPages,
        "results": data.map((json) => Event.fromJson(json)).toList(),
      };
    } on DioException catch (e) {
      throw Exception("Failed to get events: ${e.response?.statusCode}");
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

    try {
      final response = await dio.post('/api/shouka/events/add/', data: body);
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to add event: ${e.response}");
    }
  }

  //
  // Edit Event
  //
  Future<int> editEvent({
    required String deviceName,
    required String title,
    required String timestamp,
    required int userId,
    required List<dynamic> events,
  }) async {
    var body = {
      "device_name": deviceName,
      "title": title,
      "timestamp": timestamp,
      "user_id": userId,
      "events": events,
    };

    try {
      final response = await dio.post('/api/shouka/events/edit/', data: body);
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to edit event: ${e.response}");
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
    String? plan,
    String? start,
    String? end,
    bool? isRejected,
    bool? isSuspended,
  }) async {
    final queryParams = {
      "all": all == true ? "true" : "false",
      if (page != null) "page": page,
      "data_per_page": 10,
      if (installer != null) "installer": installer,
      if (organization != null) "organization": organization,
      if (administration != null) "administration": administration,
      if (province != null) "province": province,
      if (city != null) "city": city,
      if (search != null) "search": search,
      if (plan != null) "plan": plan,
      if (start != null) "start": start,
      if (end != null) "end": end,
      if (isRejected != null) "is_rejected": isRejected,
      if (isSuspended != null) "is_suspended": isSuspended,
    };

    log("query params for devices are: $queryParams");

    try {
      final response = await dio.post(
        '/api/shouka/devices-list/',
        data: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = page != null
            ? response.data["results"]
            : response.data;
        return {
          "pages": response.data["total_pages"],
          "data": data.map((json) => Device.fromJson(json)).toList(),
          "percent": response.data["device_connectivity_percent"],
          "rejected_count": response.data["rejected_devices_count"],
        };
      } else {
        throw Exception('Failed to load devices');
      }
    } on DioException catch (e) {
      throw Exception("Failed to get device list: ${e.response?.statusCode}");
    }
  }

  //
  // Fetch Devices For Export
  //
  Future<List<Map<String, dynamic>>> fetchDevicesForExport({
    int? installer,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? search,
    String? plan,
    String? start,
    String? end,
  }) async {
    final queryParams = {
      "is_exported": true,
      if (installer != null) "installer": installer,
      if (organization != null) "organization": organization,
      if (administration != null) "administration": administration,
      if (province != null) "province": province,
      if (city != null) "city": city,
      if (search != null) "search": search,
      if (plan != null) "plan": plan,
      if (start != null) "start": start,
      if (end != null) "end": end,
    };

    log("query params for export are: $queryParams");

    try {
      final response = await dio.post(
        '/api/shouka/devices-list/',
        data: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data["results"] ?? response.data["data"] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load devices for export');
      }
    } on DioException catch (e) {
      throw Exception(
        "Failed to get device list for export: ${e.response?.statusCode}",
      );
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
    String? plan,
    String? latLong,
    required List<String> images,
    List<Map<String, dynamic>>? checkListItems,
  }) async {
    var body = {
      "name": name,
      "serial_number": serialNumber,
      "installation_address": installationAddress,
      "engine_room_feature": engineRoomFeature,
      "location": location,
      "organization": organization,
      // Don't send status - let backend set null (pending) by default
      if (plan != null) "plan": plan,
      "lat_long": latLong,
      "details": {"name": name, "serial_number": serialNumber},
      "images": images,
      if (checkListItems != null && checkListItems.isNotEmpty)
        "check_list_items": checkListItems,
    };

    try {
      log("AddDevice Request Body: $body");
      final response = await dio.post('/api/shouka/devices/add', data: body);
      log("AddDevice Response Status: ${response.statusCode}");
      log("AddDevice Response Data: ${response.data}");
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
    String? plan,
    String? latLong,
  }) async {
    // Note: status is not included here - use updateDeviceStatus() to change approval status
    var body = {
      "id": id,
      if (name != null) "name": name,
      if (serialNumber != null && serialNumber != "")
        "serial_number": serialNumber,
      if (installationAddress != null)
        "installation_address": installationAddress,
      if (engineRoomFeature != null) "engine_room_feature": engineRoomFeature,
      if (location != null) "location": location,
      if (organization != null) "organization": organization,
      if (plan != null) "plan": plan,
      if (latLong != null) "lat_long": latLong,
    };

    try {
      final response = await dio.post('/api/shouka/devices/edit', data: body);
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      log("Failed to edit device: ${e.response}");
      return e.response!.statusCode!;
    }
  }

  //
  // Update Device Status (Approve/Reject)
  //
  Future<int> updateDeviceStatus({
    required int deviceId,
    required bool status,
    String? rejectionNote,
  }) async {
    var body = {
      "device": deviceId,
      "status": status,
      if (rejectionNote != null && rejectionNote.isNotEmpty)
        "rejection_note": rejectionNote,
    };

    try {
      final response = await dio.post(
        '/api/shouka/devices/update-status',
        data: body,
      );
      log("Device status updated: ${response.data}");
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      log("Failed to update device status: ${e.response}");
      return e.response?.statusCode ?? -1;
    }
  }

  //
  // Fetch Device Basic Info
  //
  Future<Device> fetchBasicDeviceInfo({required int id}) async {
    try {
      final response = await dio.post(
        '/api/shouka/objects/device/retrieve/',
        data: {"id": id},
      );

      return Device.fromJson(response.data["data"]);
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
        '/api/shouka/device/retrieve-info/',
        data: {"device_id": id},
      );

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
    // Checklist Items
    List<Map<String, dynamic>>? checkListItems,
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
      log("Sending ${images?.length ?? 0} images to backend");
      if (images != null && images.isNotEmpty) {
        log(
          "First image preview (first 100 chars): ${images[0].substring(0, images[0].length > 100 ? 100 : images[0].length)}",
        );
      }
    } else if (objectType == "checklist") {
      body = {"object_type": "checklist", "check_list_items": checkListItems};
      log("Sending ${checkListItems?.length ?? 0} checklist items to backend");
    }

    dynamic sendBody = {
      // DEVICE ID
      "device_id": deviceId,

      ...body,
    };

    try {
      final response = await dio.post(
        '/api/shouka/device/edit-info/',
        data: sendBody,
      );
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

    try {
      final response = await dio.post(
        '/api/shouka/device/delete-images/',
        data: body,
      );
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
      final response = await dio.post('/api/shouka/get_option_for_insert/');

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
    final queryParams = {
      "page": page,
      if (search != null) "search": search,
      "data_per_page": 10,
    };

    try {
      final response = await dio.post(
        '/api/shouka/objects/organization/',
        data: queryParams,
      );

      final List<dynamic> data = response.data["results"];
      final int totalPages = response.data["total_pages"];
      return {
        "pages": totalPages,
        "results": data.map((json) => Organization.fromJson(json)).toList(),
      };
    } on DioException catch (e) {
      throw Exception("Failed to get org: ${e.response?.statusCode}");
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
      "object_type": "Organization",
      "organization": name,
      "administration": administration,
    };

    try {
      final response = await dio.post('/api/shouka/objects/edit', data: body);
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
    var body = {
      "organization": name,
      "administration": administration,
      "object_type": "organization",
    };

    try {
      final response = await dio.post('/api/shouka/objects/add', data: body);
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
    final queryParams = {
      "page": page,
      if (search != null) "search": search,
      "data_per_page": 10,
    };

    try {
      final response = await dio.post(
        '/api/shouka/objects/location/',
        data: queryParams,
      );

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
    var body = {
      "id": id,
      "city": city,
      "province": province,
      "object_type": "location",
    };

    try {
      final response = await dio.post('/api/shouka/objects/edit', data: body);
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
    var body = {"city": city, "province": province, "object_type": "location"};

    try {
      final response = await dio.post('/api/shouka/objects/add', data: body);
      return response.statusCode ?? -1;
    } on DioException catch (e) {
      throw Exception("Failed to add location: ${e.response?.statusCode}");
    }
  }

  //
  // Fetch Events For Export
  //
  Future<List<Event>> fetchEventsForExport({
    int? creator,
    int? device,
    String? start,
    String? end,
    String? title,
    String? search,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? plan,
  }) async {
    final body = {
      "page": 1,
      "data_per_page": 2000,
      if (creator != null) "creator": creator,
      if (device != null) "device": device,
      if (start != null) "start": start,
      if (end != null) "end": end,
      if (title != null) "title": title,
      if (search != null) "search": search,
      if (organization != null) "organization": organization,
      if (administration != null) "administration": administration,
      if (province != null) "province": province,
      if (city != null) "city": city,
      if (plan != null) "plan": plan,
    };

    log("Fetching events for export with params: $body");

    try {
      final response = await dio.post('/api/shouka/events/list/', data: body);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data["results"] ?? response.data["data"] ?? [];
        return data.map((item) => Event.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load events for export');
      }
    } on DioException catch (e) {
      throw Exception(
        "Failed to get events list for export: ${e.response?.statusCode}",
      );
    }
  }

  //
  // Get APK Version
  //
  Future<dynamic> fetchApkVersion() async {
    try {
      final response = await dio.get('/api/shouka/apk-version/');

      log("GET APK VERSION: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw Exception("Failed to get apk version: ${e.response}");
    }
  }

  //
  // Fetch Engineroom Features (3D Views)
  //
  Future<dynamic> fetchEngineroomFeatures({
    required int page,
    String? search,
  }) async {
    final body = {
      "page": page,
      "data_per_page": 1000,
      if (search != null) "search": search,
    };

    try {
      final response = await dio.post(
        '/api/shouka/objects/engineroomfeature/',
        data: body,
      );

      final List<dynamic> data = response.data["results"];
      final int totalPages = response.data["total_pages"];

      return {"pages": totalPages, "results": data};
    } on DioException catch (e) {
      throw Exception(
        "Failed to get engineroom features: ${e.response?.statusCode}",
      );
    }
  }
}
