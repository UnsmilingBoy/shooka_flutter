import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/factor_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class AccountingProvider with ChangeNotifier {
  final ApiService api;

  List<Factor> _factors = [];
  bool _fetchLoading = false;
  bool _actionLoading = false;
  bool _nextPageLoading = false;
  int _totalPages = 1;
  int _page = 1;

  // Preserved filter state
  String? lastSearchedText;
  int? lastFactorId;
  String? lastFactorNumber;
  bool? lastIsPrinted;
  String? lastStartDate;
  String? lastEndDate;

  AccountingProvider({required this.api});

  List<Factor> get factors => _factors;
  bool get fetchLoading => _fetchLoading;
  bool get actionLoading => _actionLoading;
  bool get nextPageLoading => _nextPageLoading;
  int get totalPages => _totalPages;
  int get page => _page;

  //
  // Load Factors
  //
  Future<void> loadFactors({
    String? search,
    int? factorId,
    String? factorNumber,
    bool? isPrinted,
    String? start,
    String? end,
  }) async {
    _fetchLoading = true;
    _page = 1;

    lastSearchedText = search;
    lastFactorId = factorId;
    lastFactorNumber = factorNumber;
    lastIsPrinted = isPrinted;
    lastStartDate = start;
    lastEndDate = end;

    Future.microtask(() => notifyListeners());

    try {
      final result = await api.fetchFactorList(
        page: 1,
        search: search,
        factorId: factorId,
        factorNumber: factorNumber,
        isPrinted: isPrinted,
        start: start,
        end: end,
      );
      _factors = result['results'];
      _totalPages = result['pages'];
    } catch (e) {
      _factors = [];
      debugPrint('Error fetching factors: $e');
    } finally {
      _fetchLoading = false;
      notifyListeners();
    }
  }

  //
  // Next Page
  //
  Future<void> nextPage() async {
    if (_page < _totalPages) {
      _page++;
      _nextPageLoading = true;
      notifyListeners();

      try {
        final result = await api.fetchFactorList(
          page: _page,
          search: lastSearchedText,
          factorId: lastFactorId,
          factorNumber: lastFactorNumber,
          isPrinted: lastIsPrinted,
          start: lastStartDate,
          end: lastEndDate,
        );
        _factors.addAll(result['results']);
      } catch (e) {
        debugPrint('Error fetching factors next page: $e');
      } finally {
        _nextPageLoading = false;
        notifyListeners();
      }
    }
  }

  //
  // Set / Update Factor ID on an event group
  //
  Future<int> setFactorId({
    required int eventGroupId,
    required String factorId,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final status = await api.setFactorId(
        eventGroupId: eventGroupId,
        factorId: factorId,
      );
      return status;
    } catch (e) {
      debugPrint('Error setting factor id: $e');
      return -1;
    } finally {
      // Reload with preserved filters
      loadFactors(
        search: lastSearchedText,
        factorId: lastFactorId,
        factorNumber: lastFactorNumber,
        isPrinted: lastIsPrinted,
        start: lastStartDate,
        end: lastEndDate,
      );
      _actionLoading = false;
      notifyListeners();
    }
  }

  //
  // Complete / Update Factor
  //
  Future<Map<String, dynamic>?> completeFactor({
    required int factorId,
    required String factorNumber,
    String? note,
    bool? isPrinted,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await api.completeFactor(
        factorId: factorId,
        factorNumber: factorNumber,
        note: note,
        isPrinted: isPrinted,
      );
      return result;
    } catch (e) {
      debugPrint('Error completing factor: $e');
      return null;
    } finally {
      // Reload with preserved filters
      loadFactors(
        search: lastSearchedText,
        factorId: lastFactorId,
        factorNumber: lastFactorNumber,
        isPrinted: lastIsPrinted,
        start: lastStartDate,
        end: lastEndDate,
      );
      _actionLoading = false;
      notifyListeners();
    }
  }
}
