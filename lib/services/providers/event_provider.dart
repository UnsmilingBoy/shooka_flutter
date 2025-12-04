import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class EventProvider with ChangeNotifier {
  final ApiService api;
  List<Event> _events = [];
  bool _fetchLoading = false;
  bool _addLoading = false;
  int? lastSelectedCreator;
  int? lastSelectedDevice;
  String? lastSearchedText;
  String? lastSelectedTitle;
  int filterCount = 0;

  EventProvider({required this.api});

  List<Event> get events => _events;
  bool get fetchLoading => _fetchLoading;
  bool get addLoading => _addLoading;

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
  }) async {
    _fetchLoading = true;
    filterCount = 0;

    // For fitering state
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

    if (search != null) {
      lastSearchedText = search;
    }

    if (filterCount == 0 && search == null) {
      lastSearchedText = null;
    }

    // Use Future.microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());

    try {
      _events = await api.fetchEventList(
        search: search,
        creator: creator,
        device: device,
        end: end,
        start: start,
        title: title,
      );
    } catch (e) {
      _events = [];
      debugPrint("Error fetching events: $e");
    } finally {
      _fetchLoading = false;
      notifyListeners();
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
}
