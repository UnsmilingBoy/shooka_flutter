import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/models/software_support_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';
import 'package:shooka_flutter/services/export_service.dart';

class SoftwareSupportProvider with ChangeNotifier {
  final ApiService api;
  List<Event> _events = [];
  List<SupportEventUser> _users = [];
  bool _fetchLoading = false;
  bool _addLoading = false;
  bool _editLoading = false;
  bool _eventsNextPageLoading = false;
  bool _usersLoading = false;
  int _eventsTotalPages = 1;
  int _eventsTotalCount = 0;
  int _eventsPage = 1;

  /// Comma-separated ids for multi-select (e.g. "1,2,3").
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

  SoftwareSupportProvider({required this.api});

  List<Event> get events => _events;
  List<SupportEventUser> get users => _users;
  bool get fetchLoading => _fetchLoading;
  bool get addLoading => _addLoading;
  bool get editLoading => _editLoading;
  bool get usersLoading => _usersLoading;
  bool get eventsNextPageLoading => _eventsNextPageLoading;
  int get eventsTotalPages => _eventsTotalPages;
  int get eventsTotalCount => _eventsTotalCount;
  int get eventsPage => _eventsPage;

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
      final result = await api.fetchSupportEventList(
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
      debugPrint("Error fetching support events: $e");
    } finally {
      _fetchLoading = false;
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
        final nextPageEvents = await api.fetchSupportEventList(
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
        _events.addAll(nextPageEvents["results"]);
      } catch (e) {
        debugPrint("Error fetching support events next page: $e");
      } finally {
        _eventsNextPageLoading = false;
        notifyListeners();
      }
    }
  }

  //
  // Fetch Support Event Users
  //
  Future<List<SupportEventUser>> fetchUsers({String? search}) async {
    _usersLoading = true;
    // Avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());

    try {
      final result = await api.fetchSupportEventUsers(page: 1, search: search);
      _users = result["results"];
    } catch (e) {
      _users = [];
      debugPrint("Error fetching support event users: $e");
    } finally {
      _usersLoading = false;
      notifyListeners();
    }
    return _users;
  }

  /// Searches the support-user directory without replacing the cached page
  /// used by the other user pickers — used to resolve a single user (e.g.
  /// the recipient of an inventory form) that is not on the first page.
  Future<List<SupportEventUser>> searchUsers({String? search}) async {
    try {
      final result = await api.fetchSupportEventUsers(page: 1, search: search);
      return (result["results"] as List).cast<SupportEventUser>();
    } catch (e) {
      debugPrint("Error searching support event users: $e");
      return [];
    }
  }

  //
  // Add Event
  //
  Future<Map<String, dynamic>?> addEvent({
    required String projectName,
    required int device,
    required String title,
    required String text,
    required String requesterPhoneType,
    int? requesterUserId,
    String? phoneNumber,
    String? externalRequesterName,
  }) async {
    _addLoading = true;
    notifyListeners();

    try {
      return await api.addSupportEvent(
        projectName: projectName,
        device: device,
        title: title,
        text: text,
        requesterPhoneType: requesterPhoneType,
        requesterUserId: requesterUserId,
        phoneNumber: phoneNumber,
        externalRequesterName: externalRequesterName,
      );
    } catch (e) {
      debugPrint("Error adding support event: $e");
      return null;
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
  Future<Map<String, dynamic>?> editEvent({
    required int? eventGroupId,
    required int? eventId,
    required String title,
    required String text,
    required String requesterPhoneType,
    int? requesterUserId,
    String? phoneNumber,
    String? externalRequesterName,
  }) async {
    _editLoading = true;
    notifyListeners();

    try {
      return await api.editSupportEvent(
        eventGroupId: eventGroupId,
        eventId: eventId,
        title: title,
        text: text,
        requesterPhoneType: requesterPhoneType,
        requesterUserId: requesterUserId,
        phoneNumber: phoneNumber,
        externalRequesterName: externalRequesterName,
      );
    } catch (e) {
      debugPrint("Error editing support event: $e");
      return null;
    } finally {
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
      _editLoading = false;
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

      final exportService = ExportService();
      await exportService.exportEvents(events);
    } catch (e) {
      debugPrint("Error exporting support events: $e");
      rethrow;
    }
  }
}
