import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/complete_device_info_data_class.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService api;
  DeviceProvider({required this.api});

  List<Device> _devices = [];
  CompleteDeviceInfo? _completeDeviceInfo;
  Device? _device;
  int activeDevicesPercentage = 0;
  bool _isLoading = false;
  bool _addLoading = false;
  bool _completeInfoLoading = false;
  int? lastSelectedInstaller;
  String? lastSearchedText;
  String? lastSelectedOrg;
  String? lastSelectedAdmin;
  String? lastSelectedProvince;
  String? lastSelectedCity;
  int filterCount = 0;

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  bool get addLoading => _addLoading;
  bool get completeInfoLoading => _completeInfoLoading;
  CompleteDeviceInfo? get completeDeviceInfo => _completeDeviceInfo;
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
  }) async {
    _addLoading = true;

    notifyListeners();

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
}
