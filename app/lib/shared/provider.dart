import 'package:flutter/material.dart';

class UserData {
  final String id;
  final String role;
  final String? phoneNumber;
  final String? firstname;
  final String? lastname;

  UserData({
    required this.id,
    required this.role,
    this.phoneNumber,
    this.firstname,
    this.lastname,
  });

  String get fullName {
    if (firstname != null && lastname != null && lastname!.isNotEmpty) {
      return '$firstname $lastname';
    }
    return firstname ?? '';
  }
}

class RidyProvider with ChangeNotifier {
  UserData? _currentUser;
  bool _isAuthenticated = false;

  UserData? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _currentUser?.id;

  void setUser(UserData user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Legacy method for backward compatibility
  void setUserId(String? userId) {
    if (userId != null && _currentUser != null) {
      _currentUser = UserData(
        id: userId,
        role: _currentUser!.role,
        phoneNumber: _currentUser!.phoneNumber,
        firstname: _currentUser!.firstname,
        lastname: _currentUser!.lastname,
      );
      notifyListeners();
    }
  }
}
