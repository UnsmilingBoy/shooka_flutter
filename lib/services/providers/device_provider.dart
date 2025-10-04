import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService api;
  List<Device> _devices = [];
  int activeDevicesPercentage = 0;
  bool _isLoading = false;

  DeviceProvider({required this.api});

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;

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
}
