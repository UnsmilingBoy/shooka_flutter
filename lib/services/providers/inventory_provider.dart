import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/export_service.dart';

class InventoryProvider extends ChangeNotifier {
  final ApiService api;
  final ExportService exportService;

  InventoryProvider({required this.api}) : exportService = ExportService();

  bool fetchLoading = false;
  bool submitLoading = false;
  String searchValue = '';
  String destinationFilter = '';
  String startFilter = '';
  String endFilter = '';
  int _page = 0;
  int _totalPages = 1;
  int _serverTotalCount = 0;
  bool isLoadingMore = false;
  bool get hasNextPage => _page < _totalPages;

  List<InventoryFormItem> _forms = [];

  List<InventoryFormItem> get forms {
    Iterable<InventoryFormItem> result = _forms;
    if (searchValue.isNotEmpty) {
      final query = searchValue.trim();
      result = result.where(
        (form) => form.searchText.contains(query.toLowerCase()),
      );
    }
    return result.toList();
  }

  int get totalCount =>
      _serverTotalCount == 0 ? _forms.length : _serverTotalCount;

  Future<void> loadForms({
    String? destination,
    String? start,
    String? end,
  }) async {
    fetchLoading = true;
    destinationFilter = destination ?? destinationFilter;
    startFilter = start ?? startFilter;
    endFilter = end ?? endFilter;
    notifyListeners();

    try {
      final response = await api.fetchDeviceItemsList(
        page: 1,
        destination: destinationFilter,
        start: startFilter,
        end: endFilter,
      );
      _forms = List<InventoryFormItem>.from(response['results'] as List);
      _page = response['page'] as int;
      _totalPages = response['pages'] as int;
      _serverTotalCount = response['total_count'] as int;
    } catch (e) {
      log('Error loading inventory forms: $e');
      rethrow;
    } finally {
      fetchLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreForms() async {
    if (fetchLoading || isLoadingMore || !hasNextPage) return;
    isLoadingMore = true;
    notifyListeners();
    try {
      final response = await api.fetchDeviceItemsList(
        page: _page + 1,
        destination: destinationFilter,
        start: startFilter,
        end: endFilter,
      );
      _forms.addAll(List<InventoryFormItem>.from(response['results'] as List));
      _page = response['page'] as int;
      _totalPages = response['pages'] as int;
      _serverTotalCount = response['total_count'] as int;
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void setSearch(String value) {
    searchValue = value;
    notifyListeners();
  }

  void setFilters({String? destination, String? start, String? end}) =>
      loadForms(destination: destination, start: start, end: end);

  Future<List<InventoryInstallItemOption>> fetchInstallItems({
    required String projectName,
    required String deviceType,
  }) => api.fetchInventoryInstallItems(
    projectName: projectName,
    deviceType: deviceType,
  );

  Future<Map<String, dynamic>> submitDevicePack({
    required Map<String, dynamic> data,
  }) async {
    submitLoading = true;
    notifyListeners();
    try {
      final result = await api.addDevicePackForm(data: data);
      await loadForms();
      return result;
    } finally {
      submitLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> submitInventoryItems({
    required Map<String, dynamic> data,
  }) async {
    submitLoading = true;
    notifyListeners();
    try {
      final result = await api.addInventoryItemsForm(data: data);
      await loadForms();
      return result;
    } finally {
      submitLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> submitReturnForm({
    required Map<String, dynamic> data,
  }) async {
    submitLoading = true;
    notifyListeners();
    try {
      final result = await api.addReturnForm(data: data);
      await loadForms();
      return result;
    } finally {
      submitLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> editDevicePack({
    required Map<String, dynamic> data,
  }) async {
    submitLoading = true;
    notifyListeners();
    try {
      final result = await api.editDevicePackForm(data: data);
      await loadForms();
      return result;
    } catch (e) {
      log('Error editing device pack form: $e');
      rethrow;
    } finally {
      submitLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> editInventoryItems({
    required Map<String, dynamic> data,
  }) async {
    submitLoading = true;
    notifyListeners();
    try {
      final result = await api.editInventoryItemsForm(data: data);
      await loadForms();
      return result;
    } catch (e) {
      log('Error editing inventory items form: $e');
      rethrow;
    } finally {
      submitLoading = false;
      notifyListeners();
    }
  }

  bool settlementLoading = false;

  Future<Map<String, dynamic>> submitSettlement({
    required Map<String, dynamic> data,
  }) async {
    settlementLoading = true;
    notifyListeners();
    try {
      final result = await api.addSettlement(data: data);
      await loadForms();
      return result;
    } catch (e) {
      log('Error adding settlement: $e');
      rethrow;
    } finally {
      settlementLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportFormsToExcel() async {
    await exportService.exportInventoryForms(forms);
  }
}
