import 'package:flutter/material.dart';

class UserData {
  final String id;
  final String role;
  final String phoneNumber;
  final String firstname;
  final String lastname;
  final String avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserData({
    required this.id,
    required this.role,
    required this.phoneNumber,
    required this.firstname,
    required this.lastname,
    required this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    if (firstname.isNotEmpty && lastname.isNotEmpty) {
      return '$firstname $lastname';
    }
    return firstname.isNotEmpty ? firstname : phoneNumber;
  }

  String get displayName => fullName;

  String get initials {
    if (firstname.isNotEmpty) {
      final first = firstname.substring(0, 1).toUpperCase();
      final last = lastname.isNotEmpty
          ? lastname.substring(0, 1).toUpperCase()
          : '';
      return '$first$last';
    }
    return phoneNumber.isNotEmpty ? phoneNumber.substring(0, 2) : 'U';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'phoneNumber': phoneNumber,
      'firstname': firstname,
      'lastname': lastname,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Copy with method for updates
  UserData copyWith({
    String? id,
    String? role,
    String? phoneNumber,
    String? firstname,
    String? lastname,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserData(
      id: id ?? this.id,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RidyProvider with ChangeNotifier {
  UserData? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserData? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _currentUser?.id;
  String? get userRole => _currentUser?.role;
  String? get userFullName => _currentUser?.fullName;
  String? get userAvatarUrl => _currentUser?.avatarUrl;
  String? get userPhoneNumber => _currentUser?.phoneNumber;

  // Check user role
  bool get isUser => _currentUser?.role.toLowerCase() == 'user';
  bool get isRider => _currentUser?.role.toLowerCase() == 'rider';
  bool get isAdmin => _currentUser?.role.toLowerCase() == 'admin';

  /// Set user data and mark as authenticated
  void setUser(UserData user) {
    _currentUser = user;
    _isAuthenticated = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user profile information
  void updateUser(UserData updatedUser) {
    if (_currentUser != null) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  /// Update specific user fields
  void updateUserProfile({
    String? firstname,
    String? lastname,
    String? avatarUrl,
    String? phoneNumber,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        firstname: firstname,
        lastname: lastname,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

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
  String getUserInitials() {
    return _currentUser?.initials ?? 'U';
  }

  /// Get formatted avatar URL
  String getFormattedAvatarUrl() {
    final url = _currentUser?.avatarUrl ?? '';
    return url.replaceAll("localhost", "10.0.2.2");
  }

  // Legacy method for backward compatibility
  void setUserId(String? userId) {
    if (userId != null && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(id: userId);
      notifyListeners();
    }
  }
}
