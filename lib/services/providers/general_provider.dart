import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/location_data_class.dart';
import 'package:shooka_flutter/models/org_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class GeneralProvider with ChangeNotifier {
  final ApiService api;

  // App Version
  String _apkVersion = '';
  String _apkDownloadUrl = '';

  // Filters Variables
  dynamic _filters;
  bool _fetchFiltersIsLoading = false;

  // Engineroom Features Variables
  List<dynamic> _engineroomFeatures = [];
  bool _fetchEngineroomFeaturesLoading = false;
  int _engineroomFeaturesTotalPages = 1;
  int _engineroomFeaturesPage = 1;

  // Locations Variables
  List<Location> _locations = [];
  bool _fetchLocationsLoading = false;
  bool _editLocationLoading = false;
  bool _locationNextPageLoading = false;
  int _locationsTotalPages = 1;
  int _locationsPage = 1;
  String? _lastSearchedLocation;

  // Organizations Variables
  List<Organization> _organizations = [];
  bool _fetchOrganizationsLoading = false;
  bool _editOrganizationLoading = false;
  bool _orgNextPageLoading = false;
  int _orgTotalPages = 1;
  int _orgPage = 1;
  String? _lastSearchedOrg;

  GeneralProvider({required this.api});

  // App Version Getters
  String get apkVersion => _apkVersion;
  String get apkDownloadUrl => _apkDownloadUrl;

  // Filters Getters
  dynamic get filters => _filters;
  bool get isLoading => _fetchFiltersIsLoading;

  // Engineroom Features Getters
  bool get fetchEngineroomFeaturesLoading => _fetchEngineroomFeaturesLoading;
  List<dynamic> get engineroomFeatures => _engineroomFeatures;
  int get engineroomFeaturesTotalPages => _engineroomFeaturesTotalPages;
  int get engineroomFeaturesPage => _engineroomFeaturesPage;

  // Locations Getters
  bool get fetchLocationsLoading => _fetchLocationsLoading;
  bool get editLocationLoading => _editLocationLoading;
  bool get locationNextPageLoading => _locationNextPageLoading;
  List<Location> get locations => _locations;
  int get locationsTotalPages => _locationsTotalPages;
  int get locationsPage => _locationsPage;

  //Organizations Getters
  bool get fetchOrganizationsLoading => _fetchOrganizationsLoading;
  bool get editOrganizationLoading => _editOrganizationLoading;
  bool get orgNextPageLoading => _orgNextPageLoading;

  List<Organization> get organizations => _organizations;
  int get orgTotalPages => _orgTotalPages;
  int get orgPage => _orgPage;

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
    _locationsPage = 1;
    _fetchLocationsLoading = true;

    if (search != null) {
      _lastSearchedLocation = search;
    } else {
      _lastSearchedLocation = null;
    }

    notifyListeners();

    try {
      final result = await api.fetchLocationsList(page: page, search: search);
      _locations = result["results"];
      _locationsTotalPages = result["pages"];
    } catch (e) {
      _locations = [];
      debugPrint("Error fetching locations: $e");
    } finally {
      _fetchLocationsLoading = false;
      notifyListeners();
    }
  }

  //
  // Locations Next Page
  //
  Future<void> locationsNextPage() async {
    if (_locationsPage < _locationsTotalPages) {
      _locationsPage++;
      _locationNextPageLoading = true;
      notifyListeners();

      try {
        final nextPageLocations = await api.fetchLocationsList(
          page: _locationsPage,
          search: _lastSearchedLocation,
        );
        _locations.addAll(
          nextPageLocations["results"],
        ); // append results to existing list
      } catch (e) {
        _locations = [];
        debugPrint("Error fetching locations: $e");
      } finally {
        _locationNextPageLoading = false;
        notifyListeners();
      }
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
      fetchFilters();
      _editLocationLoading = false;
      notifyListeners();
    }
  }

  //
  // Fetch Organizations
  //
  Future<void> fetchOrganizations({required int page, String? search}) async {
    _fetchOrganizationsLoading = true;
    _orgPage = 1;

    if (search != null) {
      _lastSearchedOrg = search;
    } else {
      _lastSearchedOrg = null;
    }

    notifyListeners();

    try {
      final response = await api.fetchOrganizationList(
        page: page,
        search: search,
      );

      _organizations = response["results"];
      _orgTotalPages = response["pages"];
    } catch (e) {
      _organizations = [];
      debugPrint("Error fetching organizations: $e");
    } finally {
      _fetchOrganizationsLoading = false;
      notifyListeners();
    }
  }

  //
  // Organizations Next Page
  //
  Future<void> orgNextPage() async {
    if (_orgPage < _orgTotalPages) {
      _orgPage++;
      _orgNextPageLoading = true;
      notifyListeners();

      try {
        final nextPageOrg = await api.fetchOrganizationList(
          page: _orgPage,
          search: _lastSearchedOrg,
        );
        _organizations.addAll(
          nextPageOrg["results"],
        ); // append results to existing list
      } catch (e) {
        _organizations = [];
        debugPrint("Error fetching orgs: $e");
      } finally {
        _orgNextPageLoading = false;
        notifyListeners();
      }
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
      fetchFilters();
      _editOrganizationLoading = false;
      notifyListeners();
    }
  }

  //
  // Fetch APK Version
  //
  Future<void> fetchApkVersion() async {
    try {
      final response = await api.fetchApkVersion();
      _apkVersion = response['version'];
      _apkDownloadUrl = response['download_url'];
    } catch (e) {
      debugPrint("Error fetching APK version: $e");
    }
  }

  //
  // Fetch Engineroom Features (3D Views)
  //
  Future<void> fetchEngineroomFeatures({
    required int page,
    String? search,
  }) async {
    _fetchEngineroomFeaturesLoading = true;
    _engineroomFeaturesPage = 1;
    notifyListeners();

    try {
      final result = await api.fetchEngineroomFeatures(
        page: page,
        search: search,
      );
      _engineroomFeatures = result["results"];
      _engineroomFeaturesTotalPages = result["pages"];
    } catch (e) {
      _engineroomFeatures = [];
      debugPrint("Error fetching engineroom features: $e");
    } finally {
      _fetchEngineroomFeaturesLoading = false;
      notifyListeners();
    }
  }
}
