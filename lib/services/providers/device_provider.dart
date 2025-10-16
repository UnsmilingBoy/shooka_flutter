import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/complete_device_info_data_class.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService api;
  DeviceProvider({required this.api});

  // State
  List<Device> _devices = [];
  CompleteDeviceInfo? _completeDeviceInfo;
  Device? _device;
  int activeDevicesPercentage = 0;
  bool _isLoading = false;
  bool _addLoading = false;
  bool _completeInfoLoading = false;
  bool _updateCompleteInfoLoading = false;
  int? lastSelectedInstaller;
  String? lastSearchedText;
  String? lastSelectedOrg;
  String? lastSelectedAdmin;
  String? lastSelectedProvince;
  String? lastSelectedCity;
  int filterCount = 0;

  // Getters
  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  bool get addLoading => _addLoading;
  bool get completeInfoLoading => _completeInfoLoading;
  CompleteDeviceInfo? get completeDeviceInfo => _completeDeviceInfo;
  bool get updateCompleteInfoLoading => _updateCompleteInfoLoading;
  Device? get device => _device;

  Future<void> loadDevices({
    required bool all,
    int? installer,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? search,
  }) async {
    _isLoading = true;

    filterCount = 0;

    // For fitering state
    if (installer != null) {
      lastSelectedInstaller = installer;
      filterCount++;
    } else {
      lastSelectedInstaller = null;
    }

    if (organization != null) {
      lastSelectedOrg = organization;
      filterCount++;
    } else {
      lastSelectedOrg = null;
    }

    if (administration != null) {
      lastSelectedAdmin = administration;
      filterCount++;
    } else {
      lastSelectedAdmin = null;
    }

    if (province != null) {
      lastSelectedProvince = province;
      filterCount++;
    } else {
      lastSelectedProvince = null;
    }

    if (city != null) {
      lastSelectedCity = city;
      filterCount++;
    } else {
      lastSelectedCity = null;
    }

    if (search != null) {
      lastSearchedText = search;
    }

    if (filterCount == 0 && search == null) {
      lastSearchedText = null;
    }
    notifyListeners();

    try {
      final response = await api.fetchDevices(
        all: all,
        administration: administration,
        city: city,
        installer: installer,
        organization: organization,
        province: province,
        search: search,
      );

      _devices = response["data"];
      final percentHeader = response["headers"]?["device-connectivity-percent"];
      if (percentHeader != null && percentHeader.isNotEmpty) {
        activeDevicesPercentage =
            double.tryParse(percentHeader[0])?.round() ?? 0;
      } else {
        activeDevicesPercentage = 0;
      }
    } catch (e) {
      _devices = [];
      debugPrint("Error fetching devices: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
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
    required String latLong,
    required List<String> images,
  }) async {
    _addLoading = true;

    notifyListeners();

    // Prepend the base64 prefix to each image
    final List<String> formattedImages = images
        .map((img) => "data:image/png;base64,$img")
        .toList();

    try {
      int status = await api.addDevice(
        engineRoomFeature: engineRoomFeature,
        installationAddress: installationAddress,
        latLong: latLong,
        location: location,
        name: name,
        organization: organization,
        serialNumber: serialNumber,
        status: true,
        images: formattedImages, // Use the new list here
      );
      return status;
    } on DioException catch (e) {
      print(e);
      return e.response!.statusCode!;
    } finally {
      loadDevices(all: true);
      _addLoading = false;
      notifyListeners();
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
    String? latLong,
  }) async {
    _addLoading = true;

    notifyListeners();

    try {
      int status = await api.editDevice(
        id: id,
        engineRoomFeature: engineRoomFeature,
        installationAddress: installationAddress,
        latLong: latLong,
        location: location,
        name: name,
        organization: organization,
        serialNumber: serialNumber,
        status: true,
      );
      return status;
    } on DioException catch (e) {
      print(e);
      return e.response!.statusCode!;
    } finally {
      loadDevices(all: true);
      loadCompleteDeviceInfo(id: id);
      _addLoading = false;
      notifyListeners();
    }
  }

  //
  // Load Basic Device Info
  //
  Future<void> loadBasicDeviceInfo({required int id}) async {
    _completeInfoLoading = true;
    notifyListeners();

    try {} catch (e) {
      print(e.toString());
    } finally {
      _completeInfoLoading = false;
      notifyListeners();
    }
  }

  //
  // Load Complete Device Info
  //
  Future<void> loadCompleteDeviceInfo({required int id}) async {
    _completeInfoLoading = true;
    notifyListeners();

    try {
      _completeDeviceInfo = await api.fetchDevicePageInfo(id: id);
      _device = await api.fetchBasicDeviceInfo(id: id);
    } catch (e) {
      print(e.toString());
      _completeDeviceInfo = null;
      _device = null;
    } finally {
      _completeInfoLoading = false;
      notifyListeners();
    }
  }

  //
  //  Update Complete Device Info (Location Public Info)
  //
  Future<int> updateLocationPublicInfo({
    // DEVICE ID
    required int deviceId,
    // Location Public Info
    String? phoneNumber1,
    String? phoneNumber2,
    String? linkerPerson1,
    String? linkerPerson2,
    int? buildingMetrage,
    int? meterSubscriptionNumber,
    String? buildingImage, // base64
    int? location,
    String? latLong,
  }) async {
    _updateCompleteInfoLoading = true;
    notifyListeners();

    try {
      if (location != null || latLong != null) {
        await editDevice(id: deviceId, location: location, latLong: latLong);
      }

      int status = await api.updateCompleteDeviceInfo(
        deviceId: deviceId,
        objectType: "locationpublicinfo",
        phoneNumber1: phoneNumber1,
        phoneNumber2: phoneNumber2,
        linkerPerson1: linkerPerson1,
        linkerPerson2: linkerPerson2,
        buildingMetrage: buildingMetrage,
        meterSubscriptionNumber: meterSubscriptionNumber,
        buildingImage: buildingImage,
      );
      return status;
    } on DioException catch (e) {
      print(e);
      return e.response!.statusCode!;
    } finally {
      loadCompleteDeviceInfo(id: deviceId);
      _updateCompleteInfoLoading = false;
      notifyListeners();
    }
  }

  //
  //  Update Complete Device Info (Location Public Info)
  //
  Future<int> updateEngineRoomPublicInfo({
    // DEVICE ID
    required int deviceId,
    // Location Public Info
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
  }) async {
    _updateCompleteInfoLoading = true;
    notifyListeners();

    try {
      int status = await api.updateCompleteDeviceInfo(
        deviceId: deviceId,
        objectType: "engineroompublicinfo",
        // Engineroom Public Info
        usage: usage,
        hasExchanger: hasExchanger,
        numberOfPoolExchangers: numberOfPoolExchangers,
        numberOfJaccuziExchangers: numberOfJaccuziExchangers,
        numberOfFloorHeatingExchangers: numberOfFloorHeatingExchangers,
        numberOfBoilers: numberOfBoilers,
        numberOfCirculatingPumps: numberOfCirculatingPumps,
        numberOfCoilSources: numberOfCoilSources,
        numberOfCoilSourcesPumps: numberOfCoilSourcesPumps,
        numberOfHotWaterPumps: numberOfHotWaterPumps,
      );
      return status;
    } on DioException catch (e) {
      print(e);
      return e.response!.statusCode!;
    } finally {
      loadCompleteDeviceInfo(id: deviceId);
      _updateCompleteInfoLoading = false;
      notifyListeners();
    }
  }

  //
  //  Update Complete Device Info (Location Public Info)
  //
  Future<int> updateInstallationInfo({
    // DEVICE ID
    required int deviceId,
    // Installation Info
    String? installedDeviceModel, // 4relays, 8relays, 16relays
    String? connectionType, // internet, simcard
    String? modemModel,
    bool? hasSimcard,
    String? modemSimcardNumber,
    String? installationDate, // "1404-07-13 12:02:42"
    String? deviceSerialNumberImage, // base64
    String? modemSimcardSerialNumberImage, // base64
  }) async {
    _updateCompleteInfoLoading = true;
    notifyListeners();

    try {
      int status = await api.updateCompleteDeviceInfo(
        deviceId: deviceId,
        objectType: "installationinfo",
        // Engineroom Public Info
        installedDeviceModel: installedDeviceModel,
        connectionType: connectionType,
        modemModel: modemModel,
        hasSimcard: hasSimcard,
        modemSimcardNumber: modemSimcardNumber,
        installationDate: installationDate,
        deviceSerialNumberImage: deviceSerialNumberImage,
        modemSimcardSerialNumberImage: modemSimcardSerialNumberImage,
      );
      return status;
    } on DioException catch (e) {
      print(e);
      return e.response!.statusCode!;
    } finally {
      loadCompleteDeviceInfo(id: deviceId);
      _updateCompleteInfoLoading = false;
      notifyListeners();
    }
  }
}
