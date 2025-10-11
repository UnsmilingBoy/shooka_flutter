import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/user_data_class.dart';
import 'package:shooka_flutter/services/dio_requests.dart';

class UserProvider extends ChangeNotifier {
  final ApiService api;

  UserProvider({required this.api});

  // User / Users Variables
  User? _user;
  bool _loadUserLoading = false;
  bool _updateUserLoading = false;
  bool _changePasswordLoading = false;
  bool _addLoading = false;
  bool _deleteUserLoading = false;
  List<User> _users = [];
  bool _fetchUsersLoading = false;
  final bool _editUserLoading = false;
  bool _usersNextPageLoading = false;
  String? _error;
  int _usersTotalPages = 1;
  int _usersPage = 1;
  String? lastSearchedUser;
  String? lastSelectedRole;
  String? lastSelectedStatus;

  // User / Users Getters
  User? get user => _user;
  bool get loadUserLoading => _loadUserLoading;
  bool get updateUserLoading => _updateUserLoading;
  bool get changePasswordLoading => _changePasswordLoading;
  String? get error => _error;
  List<User> get users => _users;
  bool get fetchUsersLoading => _fetchUsersLoading;
  bool get editUserLoading => _editUserLoading;
  bool get usersNextPageLoading => _usersNextPageLoading;
  bool get deleteUserLoading => _deleteUserLoading;
  int get usersTotalPages => _usersTotalPages;
  int get usersPage => _usersPage;
  bool get addLoading => _addLoading;

  //
  // Fetch Locations
  //
  Future<void> fetchUsers({
    required int page,
    String? search,
    String? role,
    String? status,
  }) async {
    _usersPage = 1;
    _fetchUsersLoading = true;

    if (search != null) {
      lastSearchedUser = search;
    } else {
      lastSearchedUser = null;
    }

    if (role != null) {
      lastSelectedRole = role;
    } else {
      lastSelectedRole = null;
    }

    if (status != null) {
      lastSelectedStatus = status;
    } else {
      lastSelectedStatus = null;
    }

    notifyListeners();

    try {
      final result = await api.fetchUsersList(
        page: page,
        search: search,
        role: role,
        status: status,
      );
      _users = result["results"];
      _usersTotalPages = result["pages"];
    } catch (e) {
      _users = [];
      debugPrint("Error fetching users: $e");
    } finally {
      _fetchUsersLoading = false;
      notifyListeners();
    }
  }

  //
  // Users Next Page
  //
  Future<void> usersNextPage() async {
    if (_usersPage < _usersTotalPages) {
      _usersPage++;
      _usersNextPageLoading = true;
      notifyListeners();

      try {
        final nextPageUsers = await api.fetchLocationsList(
          page: _usersPage,
          search: lastSearchedUser,
        );
        _users.addAll(
          nextPageUsers["results"],
        ); // append results to existing list
      } catch (e) {
        _users = [];
        debugPrint("Error fetching users: $e");
      } finally {
        _usersNextPageLoading = false;
        notifyListeners();
      }
    }
  }

  //
  // Add User
  //
  Future<int> addUser({
    required String name,
    required String username,
    required String password,
    required String phoneNumber,
    String? email,
    String? profilePic,
    required bool isActive,
    required String role,
  }) async {
    _addLoading = true;

    notifyListeners();

    try {
      int status = await api.addUser(
        name: name,
        isActive: true,
        role: role,
        password: password,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        profilePic: profilePic,
      );
      return status;
    } catch (e) {
      print(e);
      return -1;
    } finally {
      fetchUsers(page: 1);
      _addLoading = false;
      notifyListeners();
    }
  }

  //
  // Delete User
  //
  Future<int> deleteUser({required int id}) async {
    _deleteUserLoading = true;
    notifyListeners();

    try {
      int status = await api.deleteUser(id: id);
      return status;
    } catch (e) {
      _error = e.toString();
      return -1;
    } finally {
      fetchUsers(page: 1);
      _deleteUserLoading = false;
      notifyListeners();
    }
  }

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
  Future<int> updateUserProfile({
    required String name,
    required String username,
    required String email,
    required String phoneNumber,
    String? profilePic,
    int? id,
    String? role,
  }) async {
    _updateUserLoading = true;
    _error = null;
    notifyListeners();

    try {
      int status = await api.updateUserProfile(
        name: name,
        id: id,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        profilePic: profilePic,
        role: role,
      );
      return status;
    } catch (e) {
      _error = e.toString();
      return -1;
    } finally {
      if (id == null) {
        loadUserProfile();
      } else {
        fetchUsers(page: 1);
      }

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
