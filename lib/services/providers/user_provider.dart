import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/user_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class UserProvider extends ChangeNotifier {
  final ApiService api;

  UserProvider({required this.api});

  User? _user;
  bool _loadUserLoading = false;
  bool _updateUserLoading = false;
  bool _changePasswordLoading = false;
  String? _error;

  User? get user => _user;
  bool get loadUserLoading => _loadUserLoading;
  bool get updateUserLoading => _updateUserLoading;
  bool get changePasswordLoading => _changePasswordLoading;
  String? get error => _error;

  //
  // Load user profile
  //
  Future<void> loadUserProfile() async {
    _loadUserLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await api.fetchUserProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadUserLoading = false;
      notifyListeners();
    }
  }

  //
  // Update user profile
  //
  Future<void> updateUserProfile({
    required String name,
    required String username,
    required String email,
    required String phoneNumber,
  }) async {
    _updateUserLoading = true;
    _error = null;
    notifyListeners();

    try {
      await api.updateUserProfile(
        name: name,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      loadUserProfile();
      _updateUserLoading = false;
      notifyListeners();
    }
  }

  //
  // ChangePassword
  //
  Future<int> changePassword({
    required String prevPassword,
    required String newPassword,
  }) async {
    _changePasswordLoading = true;
    _error = null;
    notifyListeners();

    try {
      int status = await api.changePassword(
        prevPassword: prevPassword,
        newPassword: newPassword,
      );
      return status;
    } catch (e) {
      _error = e.toString();
      return -1;
    } finally {
      loadUserProfile();
      _changePasswordLoading = false;
      notifyListeners();
    }
  }
}
