import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/complete_device_info_data_class.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService api;
  GeneralProvider? _generalProvider;

  DeviceProvider({required this.api, GeneralProvider? generalProvider})
    : _generalProvider = generalProvider;

  // Setter used by ProxyProvider or manual wiring to inject the GeneralProvider later
  void setGeneralProvider(GeneralProvider general) =>
      _generalProvider = general;

  // State
  List<Device> _devices = [];
  CompleteDeviceInfo? _completeDeviceInfo;
  Device? _device;
  int activeDevicesPercentage = 0;
  bool _isLoading = false;
  bool _addLoading = false;
  bool _completeInfoLoading = false;
  bool _updateCompleteInfoLoading = false;
  bool removeImageLoading = false;
  int? lastSelectedInstaller;
  String? lastSearchedText;
  String? lastSelectedOrg;
  String? lastSelectedAdmin;
  String? lastSelectedProvince;
  String? lastSelectedCity;
  String? lastSelectedPlan;
  String? lastStartDate;
  String? lastEndDate;
  int filterCount = 0;
  int _devicesPage = 1;
  int _devicesTotalPages = 1;
  bool _devicesNextPageLoading = false;

  // Getters
  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  bool get addLoading => _addLoading;
  bool get completeInfoLoading => _completeInfoLoading;
  CompleteDeviceInfo? get completeDeviceInfo => _completeDeviceInfo;
  bool get updateCompleteInfoLoading => _updateCompleteInfoLoading;
  Device? get device => _device;
  int get devicesPage => _devicesPage;
  int get devicesTotalPages => _devicesTotalPages;
  bool get devicesNextPageLoading => _devicesNextPageLoading;

  Future<void> loadDevices({
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
  }) async {
    _isLoading = true;
    _devicesPage = 1; // Reset page counter when loading devices

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

    if (plan != null) {
      lastSelectedPlan = plan;
      filterCount++;
    } else {
      lastSelectedPlan = null;
    }

    if (start != null) {
      lastStartDate = start;
      filterCount++;
    } else {
      lastStartDate = null;
    }

    if (end != null) {
      lastEndDate = end;
      // Don't increment filterCount for end date if start is already counted
      // as they represent a single date range filter
    } else {
      lastEndDate = null;
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
        page: page,
        administration: administration,
        city: city,
        installer: installer,
        organization: organization,
        province: province,
        search: search,
        plan: plan,
        start: start,
        end: end,
      );

      _devices = response["data"];
      _devicesTotalPages = response["pages"];

      // Get percent from response
      final percentValue = response["percent"];

      if (percentValue != null) {
        // Handle both string and numeric types
        if (percentValue is String) {
          activeDevicesPercentage = double.tryParse(percentValue)?.round() ?? 0;
        } else if (percentValue is num) {
          activeDevicesPercentage = percentValue.round();
        } else {
          activeDevicesPercentage = 0;
        }
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
  // Device Next Page
  //
  Future<void> devicesNextPage() async {
    if (_devicesPage < _devicesTotalPages) {
      _devicesPage++;
      _devicesNextPageLoading = true;
      notifyListeners();

      try {
        final nextPageDevices = await api.fetchDevices(
          all: false,
          page: _devicesPage,
          search: lastSearchedText,
          administration: lastSelectedAdmin,
          installer: lastSelectedInstaller,
          organization: lastSelectedOrg,
          province: lastSelectedProvince,
          city: lastSelectedCity,
          plan: lastSelectedPlan,
          start: lastStartDate,
          end: lastEndDate,
        );
        _devices.addAll(
          nextPageDevices["data"],
        ); // append results to existing list
      } catch (e) {
        _devices = [];
        debugPrint("Error fetching devices: $e");
      } finally {
        _devicesNextPageLoading = false;
        notifyListeners();
      }
    }
  }

  //
  // Clear All Filters
  //
  void clearFilters() {
    lastSelectedInstaller = null;
    lastSelectedOrg = null;
    lastSelectedAdmin = null;
    lastSelectedProvince = null;
    lastSelectedCity = null;
    lastSelectedPlan = null;
    lastStartDate = null;
    lastEndDate = null;
    filterCount = 0;
    notifyListeners();
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
  }) async {
    _addLoading = true;

    notifyListeners();

    // Prepend the base64 prefix to each image
    final List<String> formattedImages = images
        .map((img) => "data:image/jpeg;base64,$img")
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
        plan: plan,
        images: formattedImages, // Use the new list here
      );
      return status;
    } on DioException catch (e) {
      log(e.toString());
      return e.response!.statusCode!;
    } finally {
      loadDevices(all: false, page: 1);
      _generalProvider?.fetchFilters();
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
    String? plan,
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
        plan: plan,
      );
      return status;
    } on DioException catch (e) {
      log(e.toString());
      return e.response!.statusCode!;
    } finally {
      loadDevices(all: false, page: 1);
      loadCompleteDeviceInfo(id: id);
      _addLoading = false;
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

  //
  //  Add Engineroom Picture
  //
  Future<int> addEngineroomPicture({
    // DEVICE ID
    required int deviceId,
    // Installation Info
    required List<String> images, // base64
  }) async {
    _updateCompleteInfoLoading = true;
    notifyListeners();

    log("Adding ${images.length} images for device $deviceId");

    // Prepend the base64 prefix to each image
    final List<String> formattedImages = images
        .map((img) => "data:image/jpeg;base64,$img")
        .toList();

    log("Formatted images count: ${formattedImages.length}");

    try {
      int status = await api.updateCompleteDeviceInfo(
        deviceId: deviceId,
        objectType: "engineroomimages",
        images: formattedImages,
      );
      log("Add images status: $status");
      return status;
    } on DioException catch (e) {
      log("Error adding images: ${e.response?.data}");
      print(e);
      return e.response!.statusCode!;
    } finally {
      // Add a small delay to allow backend to process
      await Future.delayed(Duration(milliseconds: 500));
      await loadCompleteDeviceInfo(id: deviceId);
      log(
        "Reloaded device info, images count: ${_completeDeviceInfo?.engineroomImages.length ?? 0}",
      );
      _updateCompleteInfoLoading = false;
      notifyListeners();
    }
  }

  //
  //  Remove Engineroom Pictures
  //
  Future<int> removeEngineroomPictures({
    // DEVICE ID
    required int deviceId,
    // Installation Info
    required List<int> imageId, // base64
  }) async {
    removeImageLoading = true;
    notifyListeners();

    try {
      int status = await api.deleteEngineroomImages(
        deviceId: deviceId,
        idList: imageId,
      );
      return status;
    } on DioException catch (e) {
      print(e);
      return e.response!.statusCode!;
    } finally {
      loadCompleteDeviceInfo(id: deviceId);
      removeImageLoading = false;
      notifyListeners();
    }
  }
}
