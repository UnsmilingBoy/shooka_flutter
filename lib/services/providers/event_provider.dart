import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/export_service.dart';

class EventProvider with ChangeNotifier {
  final ApiService api;
  List<Event> _events = [];
  bool _fetchLoading = false;
  bool _addLoading = false;
  bool _eventsNextPageLoading = false;
  int _eventsTotalPages = 1;
  int _eventsPage = 1;
  int? lastSelectedCreator;
  int? lastSelectedDevice;
  String? lastSearchedText;
  String? lastSelectedTitle;
  String? lastSelectedOrganization;
  String? lastSelectedAdministration;
  String? lastSelectedProvince;
  String? lastSelectedCity;
  String? lastSelectedPlan;
  int filterCount = 0;

  EventProvider({required this.api});

  List<Event> get events => _events;
  bool get fetchLoading => _fetchLoading;
  bool get addLoading => _addLoading;
  bool get eventsNextPageLoading => _eventsNextPageLoading;
  int get eventsTotalPages => _eventsTotalPages;
  int get eventsPage => _eventsPage;

  //
  // Load Events
  //
  Future<void> loadEvents({
    int? creator,
    int? device,
    String? start,
    String? end,
    String? title,
    String? search,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? plan,
  }) async {
    _fetchLoading = true;
    _eventsPage = 1;
    filterCount = 0;

    // For filtering state
    if (creator != null) {
      lastSelectedCreator = creator;
      filterCount++;
    } else {
      lastSelectedCreator = null;
    }
    if (device != null) {
      lastSelectedDevice = device;
      filterCount++;
    } else {
      lastSelectedDevice = null;
    }
    if (title != null) {
      lastSelectedTitle = title;
      filterCount++;
    } else {
      lastSelectedTitle = null;
    }
    if (organization != null) {
      lastSelectedOrganization = organization;
      filterCount++;
    } else {
      lastSelectedOrganization = null;
    }
    if (administration != null) {
      lastSelectedAdministration = administration;
      filterCount++;
    } else {
      lastSelectedAdministration = null;
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

    if (search != null) {
      lastSearchedText = search;
    }

    if (filterCount == 0 && search == null) {
      lastSearchedText = null;
    }

    // Use Future.microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());

    try {
      final result = await api.fetchEventList(
        page: 1,
        search: search,
        creator: creator,
        device: device,
        end: end,
        start: start,
        title: title,
        organization: organization,
        administration: administration,
        province: province,
        city: city,
        plan: plan,
      );
      _events = result["results"];
      _eventsTotalPages = result["pages"];
    } catch (e) {
      _events = [];
      debugPrint("Error fetching events: $e");
    } finally {
      _fetchLoading = false;
      notifyListeners();
    }
  }

  //
  // Events Next Page
  //
  Future<void> eventsNextPage() async {
    if (_eventsPage < _eventsTotalPages) {
      _eventsPage++;
      _eventsNextPageLoading = true;
      notifyListeners();

      try {
        final nextPageEvents = await api.fetchEventList(
          page: _eventsPage,
          search: lastSearchedText,
          creator: lastSelectedCreator,
          device: lastSelectedDevice,
          title: lastSelectedTitle,
          organization: lastSelectedOrganization,
          administration: lastSelectedAdministration,
          province: lastSelectedProvince,
          city: lastSelectedCity,
          plan: lastSelectedPlan,
        );
        _events.addAll(
          nextPageEvents["results"],
        ); // append results to existing list
      } catch (e) {
        debugPrint("Error fetching events next page: $e");
      } finally {
        _eventsNextPageLoading = false;
        notifyListeners();
      }
    }
  }

  //
  // Add Event
  //
  Future<int> addEvent({
    required String device,
    required String title,
    required List<dynamic> events,
  }) async {
    _addLoading = true;

    notifyListeners();

    try {
      int status = await api.addEvent(
        device: device,
        events: events,
        title: title,
      );
      return status;
    } catch (e) {
      print(e);
      return -1;
    } finally {
      loadEvents();
      _addLoading = false;
      notifyListeners();
    }
  }

  //
  // Export Events to Word
  //
  Future<void> exportEventsToWord() async {
    try {
      log('Starting events export with current filters...');
      final events = await api.fetchEventsForExport(
        creator: lastSelectedCreator,
        device: lastSelectedDevice,
        title: lastSelectedTitle,
        search: lastSearchedText,
        organization: lastSelectedOrganization,
        administration: lastSelectedAdministration,
        province: lastSelectedProvince,
        city: lastSelectedCity,
        plan: lastSelectedPlan,
      );
      log('Fetched ${events.length} events for export');

      final exportService = ExportService();
      await exportService.exportEvents(events);
      log('Export completed successfully');
    } catch (e) {
      log('Error exporting events: $e');
      rethrow;
    }
  }
}
