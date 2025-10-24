import 'package:app/models/delivery.dart';
import 'package:app/models/response/all_users.dart';
import 'package:app/models/user_information.dart';
import 'package:flutter/material.dart';

class RidyProvider with ChangeNotifier {
  UserInformation? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserInformation? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _currentUser?.id;
  String? get userRole => _currentUser?.role;
  String? get userFullName => _currentUser?.fullname;
  String? get userAvatarUrl => _currentUser?.avatarUrl;
  String? get userPhoneNumber => _currentUser?.phoneNumber;

  // Check user role
  bool get isUser => _currentUser?.role.toLowerCase() == 'user';
  bool get isRider => _currentUser?.role.toLowerCase() == 'rider';
  bool get isAdmin => _currentUser?.role.toLowerCase() == 'admin';

  /// Set user data and mark as authenticated
  void setUser(UserInformation user) {
    _currentUser = user;
    _isAuthenticated = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user profile information
  void updateUser(UserInformation updatedUser) {
    if (_currentUser != null) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  /// Update specific user fields
  // void updateUserProfile({
  //   String? firstname,
  //   String? lastname,
  //   String? avatarUrl,
  //   String? phoneNumber,
  // }) {
  //   if (_currentUser != null) {
  //     _currentUser = _currentUser!.copyWith(
  //       firstname: firstname ?? _currentUser!.firstname,
  //       lastname: lastname ?? _currentUser!.lastname,
  //       avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
  //       phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
  //     );
  //     notifyListeners();
  //   }
  // }

  /// Clear user data and mark as unauthenticated
  void clearUser() {
    _currentUser = null;
    _isAuthenticated = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void setError(String? error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role.toLowerCase() == role.toLowerCase();
  }

  /// Get user initials for avatar
  // String getUserInitials() {
  //   return _currentUser?.initials ?? 'U';
  // }

  /// Get formatted avatar URL
  String getFormattedAvatarUrl() {
    final url = _currentUser?.avatarUrl ?? '';
    return url.replaceAll("localhost", "100.69.213.128");
  }

  // Legacy method for backward compatibility
  // void setUserId(String? userId) {
  //   if (userId != null && _currentUser != null) {
  //     _currentUser = _currentUser!.copyWith(id: userId);
  //     notifyListeners();
  //   }
  // }
}
