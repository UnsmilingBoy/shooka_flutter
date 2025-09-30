import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class EventProvider with ChangeNotifier {
  final ApiService api;
  List<Event> _events = [];
  bool _isLoading = false;

  EventProvider({required this.api});

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> loadEvents({
    required bool all,
    int? creator,
    int? device,
    String? start,
    String? end,
    String? title,
    String? search,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await api.fetchEventList(
        all: all,
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
      _isLoading = false;
      notifyListeners();
    }
  }
}
