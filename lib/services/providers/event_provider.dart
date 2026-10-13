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
  bool _sendLoading = false;
  bool _eventsNextPageLoading = false;
  int _eventsTotalPages = 1;
  int _eventsTotalCount = 0;
  int _eventsPage = 1;
  bool _preserveScrollAfterReload = false;

  /// Comma-separated installer ids for multi-select (e.g. "1,2,3").
  String? lastSelectedCreator;
  String? lastSelectedDevice;
  String? lastSearchedText;
  String? lastSelectedTitle;
  String? lastSelectedOrganization;
  String? lastSelectedAdministration;
  String? lastSelectedProvince;
  String? lastSelectedCity;
  String? lastSelectedPlan;
  String? lastSelectedStart;
  String? lastSelectedEnd;
  int filterCount = 0;

  EventProvider({required this.api});

  List<Event> get events => _events;
  bool get fetchLoading => _fetchLoading;
  bool get addLoading => _addLoading;
  bool get sendLoading => _sendLoading;
  bool get eventsNextPageLoading => _eventsNextPageLoading;
  int get eventsTotalPages => _eventsTotalPages;
  int get eventsTotalCount => _eventsTotalCount;
  int get eventsPage => _eventsPage;
  bool get preserveScrollAfterReload => _preserveScrollAfterReload;

  //
  // Load Events
  //
  Future<void> loadEvents({
    String? creator,
    String? device,
    String? start,
    String? end,
    String? title,
    String? search,
    String? organization,
    String? administration,
    String? province,
    String? city,
    String? plan,
    bool preserveScroll = false,
  }) async {
    _preserveScrollAfterReload = preserveScroll;
    _fetchLoading = true;
    _eventsPage = 1;
    filterCount = 0;

    // For filtering state (multi-select values are comma-separated strings)
    if (creator != null && creator.trim().isNotEmpty) {
      lastSelectedCreator = creator.trim();
      filterCount++;
    } else {
      lastSelectedCreator = null;
    }
    if (device != null && device.trim().isNotEmpty) {
      lastSelectedDevice = device.trim();
      filterCount++;
    } else {
      lastSelectedDevice = null;
    }
    if (title != null && title.trim().isNotEmpty) {
      lastSelectedTitle = title.trim();
      filterCount++;
    } else {
      lastSelectedTitle = null;
    }
    if (organization != null && organization.trim().isNotEmpty) {
      lastSelectedOrganization = organization.trim();
      filterCount++;
    } else {
      lastSelectedOrganization = null;
    }
    if (administration != null && administration.trim().isNotEmpty) {
      lastSelectedAdministration = administration.trim();
      filterCount++;
    } else {
      lastSelectedAdministration = null;
    }
    if (province != null && province.trim().isNotEmpty) {
      lastSelectedProvince = province.trim();
      filterCount++;
    } else {
      lastSelectedProvince = null;
    }
    if (city != null && city.trim().isNotEmpty) {
      lastSelectedCity = city.trim();
      filterCount++;
    } else {
      lastSelectedCity = null;
    }
    if (plan != null && plan.trim().isNotEmpty) {
      lastSelectedPlan = plan.trim();
      filterCount++;
    } else {
      lastSelectedPlan = null;
    }
    if (start != null && start.trim().isNotEmpty) {
      lastSelectedStart = start.trim();
      filterCount++;
    } else {
      lastSelectedStart = null;
    }
    if (end != null && end.trim().isNotEmpty) {
      lastSelectedEnd = end.trim();
    } else {
      lastSelectedEnd = null;
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
      _eventsTotalCount = result["total_count"] ?? 0;
    } catch (e) {
      _events = [];
      debugPrint("Error fetching events: $e");
    } finally {
      _fetchLoading = false;
      _preserveScrollAfterReload = false;
      notifyListeners();
    }
  }

  //
  // Events Next Page
  //
  Future<void> eventsNextPage() async {
    // Guard against concurrent page requests
    if (_eventsNextPageLoading) return;

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
          start: lastSelectedStart,
          end: lastSelectedEnd,
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
  /// Category whose text gets the auto checklist appended silently.
  static const _generalVisitCategory = 'بازدید کلی';

  /// Auto-appended to the text of [_generalVisitCategory]; never shown in UI.
  static const _generalVisitAutoItems = [
    'بررسی اتصال سنسور ها به کلکتور',
    'بازدید از تابلو برق موتورخانه',
    'اطمینان از ارتباط دستگاه با سرور',
    'بررسی وضعیت کنترل دستگاه',
    'بررسی سلامت سنسور ها',
  ];

  Future<int> addEvent({
    required String device,
    required String title,
    required List<dynamic> events,
  }) async {
    _addLoading = true;

    notifyListeners();

    try {
      final payload = events.map((e) {
        if (e is Map &&
            e['category']?.toString().trim() == _generalVisitCategory) {
          final entry = Map<String, dynamic>.from(e);
          final userText = (entry['text']?.toString() ?? '').trim();
          final numbered = [
            for (var i = 0; i < _generalVisitAutoItems.length; i++)
              '${i + 1}- ${_generalVisitAutoItems[i]}',
          ].join('\n');
          entry['text'] = userText.isEmpty ? numbered : '$userText\n$numbered';
          return entry;
        }
        return e;
      }).toList();

      int status = await api.addEvent(
        device: device,
        events: payload,
        title: title,
      );
      return status;
    } catch (e) {
      print(e);
      return -1;
    } finally {
      // Reload events with preserved filters
      loadEvents(
        creator: lastSelectedCreator,
        device: lastSelectedDevice,
        title: lastSelectedTitle,
        search: lastSearchedText,
        organization: lastSelectedOrganization,
        administration: lastSelectedAdministration,
        province: lastSelectedProvince,
        city: lastSelectedCity,
        plan: lastSelectedPlan,
        start: lastSelectedStart,
        end: lastSelectedEnd,
      );
      _addLoading = false;
      notifyListeners();
    }
  }

  //
  // Edit Event
  //
  Future<int> editEvent({
    required int? eventGroupId,
    required String? factorId,
    required List<dynamic> events,
  }) async {
    _addLoading = true;

    notifyListeners();

    try {
      int status = await api.editEvent(
        eventGroupId: eventGroupId,
        factorId: factorId,
        events: events,
      );
      return status;
    } catch (e) {
      print(e);
      return -1;
    } finally {
      // Reload events with preserved filters, preserving the user's viewport
      loadEvents(
        creator: lastSelectedCreator,
        device: lastSelectedDevice,
        title: lastSelectedTitle,
        search: lastSearchedText,
        organization: lastSelectedOrganization,
        administration: lastSelectedAdministration,
        province: lastSelectedProvince,
        city: lastSelectedCity,
        plan: lastSelectedPlan,
        start: lastSelectedStart,
        end: lastSelectedEnd,
        preserveScroll: true,
      );
      _addLoading = false;
      notifyListeners();
    }
  }

  //
  // Send Invoice
  //
  Future<String?> sendInvoice(List<Map<String, dynamic>> eventGroupIds) async {
    _sendLoading = true;
    notifyListeners();
    try {
      final result = await api.sendInvoice(eventGroupIds: eventGroupIds);
      if (result != null && result['result'] == 'ok') {
        return result['message'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint("Error sending invoice: $e");
      return null;
    } finally {
      _sendLoading = false;
      loadEvents(
        creator: lastSelectedCreator,
        device: lastSelectedDevice,
        title: lastSelectedTitle,
        search: lastSearchedText,
        organization: lastSelectedOrganization,
        administration: lastSelectedAdministration,
        province: lastSelectedProvince,
        city: lastSelectedCity,
        plan: lastSelectedPlan,
        start: lastSelectedStart,
        end: lastSelectedEnd,
      );
      notifyListeners();
    }
  }

  //
  // Export Events to Word
  //
  Future<void> exportEventsToWord({
    bool isDeviceEvents = false,
    bool isSoftwareEvents = false,
  }) async {
    try {
      log('Starting events export...');
      final events = await api.fetchEventsForSupportExport(
        isDeviceEvents: isDeviceEvents,
        isSoftwareEvents: isSoftwareEvents,
        search: lastSearchedText,
        creator: lastSelectedCreator,
        device: lastSelectedDevice,
        title: lastSelectedTitle,
        organization: lastSelectedOrganization,
        administration: lastSelectedAdministration,
        province: lastSelectedProvince,
        city: lastSelectedCity,
        plan: lastSelectedPlan,
        start: lastSelectedStart,
        end: lastSelectedEnd,
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
