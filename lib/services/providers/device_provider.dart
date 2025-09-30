import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService api;
  List<Device> _devices = [];
  bool _isLoading = false;

  DeviceProvider({required this.api});

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;

  Future<void> loadDevices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _devices = await api.fetchDevices();
    } catch (e) {
      _devices = [];
      debugPrint("Error fetching devices: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
