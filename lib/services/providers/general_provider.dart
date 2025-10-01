import 'package:flutter/material.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class GeneralProvider with ChangeNotifier {
  final ApiService api;
  dynamic _filters;
  bool _isLoading = false;

  GeneralProvider({required this.api});

  dynamic get filters => _filters;
  bool get isLoading => _isLoading;

  Future<dynamic> fetchFilters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _filters = await api.fetchFilters();
    } catch (e) {
      _filters = null;
      debugPrint("Error fetching filters: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
