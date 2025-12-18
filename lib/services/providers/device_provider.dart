import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/complete_device_info_data_class.dart';
import 'package:shooka_flutter/models/device_data_class.dart';
import 'package:shooka_flutter/models/device_filter_state.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/export_service.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService api;
  GeneralProvider? _generalProvider;

  DeviceProvider({required this.api, GeneralProvider? generalProvider})
    : _generalProvider = generalProvider {
    // Initialize filter state for each mode
    _filterStates = {
      DeviceListMode.all: DeviceFilterState(),
      DeviceListMode.rejected: DeviceFilterState(),
      DeviceListMode.suspended: DeviceFilterState(),
    };
  }

  // Setter used by ProxyProvider or manual wiring to inject the GeneralProvider later
  void setGeneralProvider(GeneralProvider general) =>
      _generalProvider = general;

  // Filter states for each mode
  late final Map<DeviceListMode, DeviceFilterState> _filterStates;

  // Device lists for each mode
  final Map<DeviceListMode, List<Device>> _deviceLists = {
    DeviceListMode.all: [],
    DeviceListMode.rejected: [],
    DeviceListMode.suspended: [],
  };

  // Loading states for each mode
  final Map<DeviceListMode, bool> _loadingStates = {
    DeviceListMode.all: false,
    DeviceListMode.rejected: false,
    DeviceListMode.suspended: false,
  };

  // Other state
  CompleteDeviceInfo? _completeDeviceInfo;
  Device? _device;
  int activeDevicesPercentage = 0;
  int _rejectedDevicesCount = 0;
  bool _addLoading = false;
  bool _completeInfoLoading = false;
  bool _updateCompleteInfoLoading = false;
  bool removeImageLoading = false;

  // Getters for filter state by mode
  DeviceFilterState getFilterState(DeviceListMode mode) => _filterStates[mode]!;

  // Getters
  List<Device> get devices => _deviceLists[DeviceListMode.all]!;
  List<Device> get rejectedDevices => _deviceLists[DeviceListMode.rejected]!;
  List<Device> get suspendedDevices => _deviceLists[DeviceListMode.suspended]!;

  List<Device> getDevices(DeviceListMode mode) => _deviceLists[mode]!;
  bool getLoading(DeviceListMode mode) => _loadingStates[mode]!;

  bool get isLoading => _loadingStates[DeviceListMode.all]!;
  bool get rejectedLoading => _loadingStates[DeviceListMode.rejected]!;
  bool get suspendedLoading => _loadingStates[DeviceListMode.suspended]!;

  bool get addLoading => _addLoading;
  bool get completeInfoLoading => _completeInfoLoading;
  CompleteDeviceInfo? get completeDeviceInfo => _completeDeviceInfo;
  bool get updateCompleteInfoLoading => _updateCompleteInfoLoading;
  Device? get device => _device;

  // Pagination getters (for backward compatibility)
  int get devicesPage => _filterStates[DeviceListMode.all]!.page;
  int get devicesTotalPages => _filterStates[DeviceListMode.all]!.totalPages;
  bool get devicesNextPageLoading =>
      _filterStates[DeviceListMode.all]!.isNextPageLoading;
  int get rejectedDevicesPage => _filterStates[DeviceListMode.rejected]!.page;
  int get rejectedDevicesTotalPages =>
      _filterStates[DeviceListMode.rejected]!.totalPages;
  bool get rejectedDevicesNextPageLoading =>
      _filterStates[DeviceListMode.rejected]!.isNextPageLoading;
  int get suspendedDevicesPage => _filterStates[DeviceListMode.suspended]!.page;
  int get suspendedDevicesTotalPages =>
      _filterStates[DeviceListMode.suspended]!.totalPages;
  bool get suspendedDevicesNextPageLoading =>
      _filterStates[DeviceListMode.suspended]!.isNextPageLoading;

  int get rejectedDevicesCount => _rejectedDevicesCount;

  // Filter count getters (for backward compatibility)
  int get filterCount => _filterStates[DeviceListMode.all]!.filterCount;
  int get rejectedFilterCount =>
      _filterStates[DeviceListMode.rejected]!.filterCount;
  int get suspendedFilterCount =>
      _filterStates[DeviceListMode.suspended]!.filterCount;

  // Legacy filter getters for backward compatibility
  int? get lastSelectedInstaller =>
      _filterStates[DeviceListMode.all]!.selectedInstaller;
  String? get lastSearchedText =>
      _filterStates[DeviceListMode.all]!.searchedText;
  String? get lastSelectedOrg => _filterStates[DeviceListMode.all]!.selectedOrg;
  String? get lastSelectedAdmin =>
      _filterStates[DeviceListMode.all]!.selectedAdmin;
  String? get lastSelectedProvince =>
      _filterStates[DeviceListMode.all]!.selectedProvince;
  String? get lastSelectedCity =>
      _filterStates[DeviceListMode.all]!.selectedCity;
  String? get lastSelectedPlan =>
      _filterStates[DeviceListMode.all]!.selectedPlan;
  String? get lastStartDate => _filterStates[DeviceListMode.all]!.startDate;
  String? get lastEndDate => _filterStates[DeviceListMode.all]!.endDate;

  int? get lastRejectedSelectedInstaller =>
      _filterStates[DeviceListMode.rejected]!.selectedInstaller;
  String? get lastRejectedSearchedText =>
      _filterStates[DeviceListMode.rejected]!.searchedText;
  String? get lastRejectedSelectedOrg =>
      _filterStates[DeviceListMode.rejected]!.selectedOrg;
  String? get lastRejectedSelectedAdmin =>
      _filterStates[DeviceListMode.rejected]!.selectedAdmin;
  String? get lastRejectedSelectedProvince =>
      _filterStates[DeviceListMode.rejected]!.selectedProvince;
  String? get lastRejectedSelectedCity =>
      _filterStates[DeviceListMode.rejected]!.selectedCity;
  String? get lastRejectedSelectedPlan =>
      _filterStates[DeviceListMode.rejected]!.selectedPlan;
  String? get lastRejectedStartDate =>
      _filterStates[DeviceListMode.rejected]!.startDate;
  String? get lastRejectedEndDate =>
      _filterStates[DeviceListMode.rejected]!.endDate;

  int? get lastSuspendedSelectedInstaller =>
      _filterStates[DeviceListMode.suspended]!.selectedInstaller;
  String? get lastSuspendedSearchedText =>
      _filterStates[DeviceListMode.suspended]!.searchedText;
  String? get lastSuspendedSelectedOrg =>
      _filterStates[DeviceListMode.suspended]!.selectedOrg;
  String? get lastSuspendedSelectedAdmin =>
      _filterStates[DeviceListMode.suspended]!.selectedAdmin;
  String? get lastSuspendedSelectedProvince =>
      _filterStates[DeviceListMode.suspended]!.selectedProvince;
  String? get lastSuspendedSelectedCity =>
      _filterStates[DeviceListMode.suspended]!.selectedCity;
  String? get lastSuspendedSelectedPlan =>
      _filterStates[DeviceListMode.suspended]!.selectedPlan;
  String? get lastSuspendedStartDate =>
      _filterStates[DeviceListMode.suspended]!.startDate;
  String? get lastSuspendedEndDate =>
      _filterStates[DeviceListMode.suspended]!.endDate;

  /// Unified method to load devices for any mode
  Future<void> loadDevicesForMode({
    required DeviceListMode mode,
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
    final filterState = _filterStates[mode]!;

    _loadingStates[mode] = true;
    filterState.resetPagination();

    filterState.updateFilters(
      installer: installer,
      organization: organization,
      administration: administration,
      province: province,
      city: city,
      plan: plan,
      start: start,
      end: end,
      search: search,
    );
    // Use Future.microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());

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
        isRejected: mode == DeviceListMode.rejected ? true : null,
        isSuspended: mode == DeviceListMode.suspended ? true : null,
      );

      _deviceLists[mode] = response["data"];
      filterState.totalPages = response["pages"];

      // Get rejected devices count from response (only for normal mode)
      if (mode == DeviceListMode.all) {
        final rejectedCount = response["rejected_count"];
        if (rejectedCount != null) {
          if (rejectedCount is int) {
            _rejectedDevicesCount = rejectedCount;
          } else if (rejectedCount is num) {
            _rejectedDevicesCount = rejectedCount.toInt();
          } else {
            _rejectedDevicesCount = 0;
          }
        }

        // Get percent from response
        final percentValue = response["percent"];
        if (percentValue != null) {
          if (percentValue is String) {
            activeDevicesPercentage =
                double.tryParse(percentValue)?.round() ?? 0;
          } else if (percentValue is num) {
            activeDevicesPercentage = percentValue.round();
          } else {
            activeDevicesPercentage = 0;
          }
        } else {
          activeDevicesPercentage = 0;
        }
      }
    } catch (e) {
      _deviceLists[mode] = [];
      debugPrint("Error fetching devices for mode $mode: $e");
    } finally {
      _loadingStates[mode] = false;
      notifyListeners();
    }
  }

  /// Load all devices (backward compatibility)
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
    await loadDevicesForMode(
      mode: DeviceListMode.all,
      all: all,
      page: page,
      installer: installer,
      organization: organization,
      administration: administration,
      province: province,
      city: city,
      search: search,
      plan: plan,
      start: start,
      end: end,
    );
  }

  /// Load rejected devices (backward compatibility)
  Future<void> loadRejectedDevices({
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
    await loadDevicesForMode(
      mode: DeviceListMode.rejected,
      all: all,
      page: page,
      installer: installer,
      organization: organization,
      administration: administration,
      province: province,
      city: city,
      search: search,
      plan: plan,
      start: start,
      end: end,
    );
  }

  /// Load suspended devices
  Future<void> loadSuspendedDevices({
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
    await loadDevicesForMode(
      mode: DeviceListMode.suspended,
      all: all,
      page: page,
      installer: installer,
      organization: organization,
      administration: administration,
      province: province,
      city: city,
      search: search,
      plan: plan,
      start: start,
      end: end,
    );
  }

  //
  // Unified Next Page for any mode
  //
  Future<void> nextPageForMode(DeviceListMode mode) async {
    final filterState = _filterStates[mode]!;

    if (filterState.page < filterState.totalPages) {
      filterState.page++;
      filterState.isNextPageLoading = true;
      notifyListeners();

      try {
        final nextPageDevices = await api.fetchDevices(
          all: false,
          page: filterState.page,
          search: filterState.searchedText,
          administration: filterState.selectedAdmin,
          installer: filterState.selectedInstaller,
          organization: filterState.selectedOrg,
          province: filterState.selectedProvince,
          city: filterState.selectedCity,
          plan: filterState.selectedPlan,
          start: filterState.startDate,
          end: filterState.endDate,
          isRejected: mode == DeviceListMode.rejected ? true : null,
          isSuspended: mode == DeviceListMode.suspended ? true : null,
        );
        _deviceLists[mode]!.addAll(nextPageDevices["data"]);
      } catch (e) {
        debugPrint("Error fetching next page for mode $mode: $e");
      } finally {
        filterState.isNextPageLoading = false;
        notifyListeners();
      }
    }
  }

  //
  // Device Next Page (backward compatibility)
  //
  Future<void> devicesNextPage() async {
    await nextPageForMode(DeviceListMode.all);
  }

  //
  // Clear All Filters
  //
  void clearFilters() {
    _filterStates[DeviceListMode.all]!.clearFilters();
    notifyListeners();
  }

  //
  // Clear Rejected Filters
  //
  void clearRejectedFilters() {
    _filterStates[DeviceListMode.rejected]!.clearFilters();
    notifyListeners();
  }

  //
  // Clear Suspended Filters
  //
  void clearSuspendedFilters() {
    _filterStates[DeviceListMode.suspended]!.clearFilters();
    notifyListeners();
  }

  //
  // Clear Filters for mode
  //
  void clearFiltersForMode(DeviceListMode mode) {
    _filterStates[mode]!.clearFilters();
    notifyListeners();
  }

  //
  // Rejected Devices Next Page (backward compatibility)
  //
  Future<void> rejectedDevicesNextPage() async {
    await nextPageForMode(DeviceListMode.rejected);
  }

  //
  // Suspended Devices Next Page
  //
  Future<void> suspendedDevicesNextPage() async {
    await nextPageForMode(DeviceListMode.suspended);
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
    // Use Future.microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());

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
  // Update Safety Parameters (Checklist)
  //
  Future<int> updateSafetyParameters({
    required int deviceId,
    required List<Map<String, dynamic>> checkListItems,
  }) async {
    _updateCompleteInfoLoading = true;
    notifyListeners();

    try {
      int status = await api.updateCompleteDeviceInfo(
        deviceId: deviceId,
        objectType: "checklist",
        checkListItems: checkListItems,
      );
      log("Update safety parameters status: $status");
      return status;
    } on DioException catch (e) {
      log("Error updating safety parameters: ${e.response?.data}");
      print(e);
      return e.response?.statusCode ?? -1;
    } finally {
      // Reload device info to get updated checklist data
      await Future.delayed(Duration(milliseconds: 500));
      await loadCompleteDeviceInfo(id: deviceId);
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

  //
  //  Export Devices to Excel
  //
  Future<void> exportDevicesToExcel() async {
    try {
      log('Starting device export with current filters...');
      final devices = await api.fetchDevicesForExport(
        installer: lastSelectedInstaller,
        organization: lastSelectedOrg,
        administration: lastSelectedAdmin,
        province: lastSelectedProvince,
        city: lastSelectedCity,
        search: lastSearchedText,
        plan: lastSelectedPlan,
        start: lastStartDate,
        end: lastEndDate,
      );
      log('Fetched ${devices.length} devices for export');

      final exportService = ExportService();
      await exportService.exportDevices(devices);
      log('Export completed successfully');
    } catch (e) {
      log('Error exporting devices: $e');
      rethrow;
    }
  }

  //
  //  Update Device Status (Approve/Reject)
  //
  Future<int> updateDeviceStatus({
    required int deviceId,
    required bool status,
    String? rejectionNote,
  }) async {
    try {
      log('Updating device $deviceId status to: $status');
      int result = await api.updateDeviceStatus(
        deviceId: deviceId,
        status: status,
        rejectionNote: rejectionNote,
      );

      if (result == 200) {
        // Reload all device lists since status change can move device between lists
        // Reload in parallel for better performance
        await Future.wait([
          _reloadListWithCurrentFilters(DeviceListMode.all),
          _reloadListWithCurrentFilters(DeviceListMode.rejected),
          _reloadListWithCurrentFilters(DeviceListMode.suspended),
        ]);
        log('Device status updated successfully');
      }

      return result;
    } catch (e) {
      log('Error updating device status: $e');
      rethrow;
    }
  }

  /// Helper method to reload a device list with its current filters
  Future<void> _reloadListWithCurrentFilters(DeviceListMode mode) async {
    final filterState = _filterStates[mode]!;
    await loadDevicesForMode(
      mode: mode,
      all: false,
      page: 1,
      search: filterState.searchedText,
      installer: filterState.selectedInstaller,
      organization: filterState.selectedOrg,
      administration: filterState.selectedAdmin,
      province: filterState.selectedProvince,
      city: filterState.selectedCity,
      plan: filterState.selectedPlan,
      start: filterState.startDate,
      end: filterState.endDate,
    );
  }
}
