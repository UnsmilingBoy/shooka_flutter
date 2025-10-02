import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/location_data_class.dart';
import 'package:shooka_flutter/models/org_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class GeneralProvider with ChangeNotifier {
  final ApiService api;
  dynamic _filters;
  List<Location> _locations = [];
  List<Organization> _organizations = [];
  bool _fetchLocationsLoading = false;
  bool _editLocationLoading = false;
  bool _fetchOrganizationsLoading = false;
  bool _fetchFiltersIsLoading = false;
  bool _editOrganizationLoading = false;

  GeneralProvider({required this.api});

  dynamic get filters => _filters;
  bool get isLoading => _fetchFiltersIsLoading;
  bool get fetchLocationsLoading => _fetchLocationsLoading;
  bool get fetchOrganizationsLoading => _fetchOrganizationsLoading;
  bool get editOrganizationLoading => _editOrganizationLoading;
  bool get editLocationLoading => _editLocationLoading;

  List<Location> get locations => _locations;
  List<Organization> get organizations => _organizations;

  //
  // Fetch Filters
  //
  Future<dynamic> fetchFilters() async {
    _fetchFiltersIsLoading = true;
    notifyListeners();

    try {
      _filters = await api.fetchFilters();
    } catch (e) {
      _filters = null;
      debugPrint("Error fetching filters: $e");
    } finally {
      _fetchFiltersIsLoading = false;
      notifyListeners();
    }
  }

  //
  // Fetch Locations
  //
  Future<void> fetchLocations({required int page, String? search}) async {
    _fetchLocationsLoading = true;
    notifyListeners();

    try {
      _locations = await api.fetchLocationsList(page: page, search: search);
    } catch (e) {
      _locations = [];
      debugPrint("Error fetching locations: $e");
    } finally {
      _fetchLocationsLoading = false;
      notifyListeners();
    }
  }

  //
  // Edit/Add Locations
  //
  Future<int> addAndEditLocation({
    int? id,
    String? city,
    String? province,
  }) async {
    _editLocationLoading = true;
    notifyListeners();

    try {
      int statusCode = -1;
      if (id != null) {
        statusCode = await api.editLocation(
          id: id,
          city: city,
          province: province,
        );
      } else {
        statusCode = await api.addLocaiton(
          city: city ?? "",
          province: province ?? "",
        );
      }

      return statusCode;
    } on DioException catch (e) {
      debugPrint("Error editing/adding location: $e");
      return -1;
    } finally {
      fetchLocations(page: 1);
      _editLocationLoading = false;
      notifyListeners();
    }
  }

  //
  // Fetch Organizations
  //
  Future<void> fetchOrganizations({required int page, String? search}) async {
    _fetchOrganizationsLoading = true;
    notifyListeners();

    try {
      _organizations = await api.fetchOrganizationList(
        page: page,
        search: search,
      );
    } catch (e) {
      _organizations = [];
      debugPrint("Error fetching organizations: $e");
    } finally {
      _fetchOrganizationsLoading = false;
      notifyListeners();
    }
  }

  //
  // Edit/Add Organization
  //
  Future<int> addAndEditOrganization({
    int? id,
    String? name,
    String? administration,
  }) async {
    _editOrganizationLoading = true;
    notifyListeners();

    try {
      int statusCode = -1;
      if (id != null) {
        statusCode = await api.editOrganization(
          id: id,
          name: name,
          administration: administration,
        );
      } else {
        statusCode = await api.addOrganization(
          name: name ?? "",
          administration: administration ?? "",
        );
      }

      return statusCode;
    } on DioException catch (e) {
      debugPrint("Error editing/adding organizations: $e");
      return -1;
    } finally {
      fetchOrganizations(page: 1);
      _editOrganizationLoading = false;
      notifyListeners();
    }
  }
}
