import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService api;
  List<Device> _devices = [];
  int activeDevicesPercentage = 0;
  bool _isLoading = false;
  bool _addLoading = false;
  int? lastSelectedInstaller;
  String? lastSearchedText;
  String? lastSelectedOrg;
  String? lastSelectedAdmin;
  String? lastSelectedProvince;
  String? lastSelectedCity;
  int filterCount = 0;

  DeviceProvider({required this.api});

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  bool get addLoading => _addLoading;

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
    required bool deviceStatus,
    required int createdBy,
    required String latLong,
  }) async {
    _addLoading = true;

    notifyListeners();

    try {
      int status = await api.addDevice(
        createdBy: createdBy,
        engineRoomFeature: engineRoomFeature,
        installationAddress: installationAddress,
        latLong: latLong,
        location: location,
        name: name,
        organization: organization,
        serialNumber: serialNumber,
        status: deviceStatus,
      );
      return status;
    } catch (e) {
      print(e);
      return -1;
    } finally {
      loadDevices(all: true);
      _addLoading = false;
      notifyListeners();
    }
  }
}
