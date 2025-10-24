import 'package:flutter/material.dart';

class RidyProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUserId(String? userId) {
    _userId = userId;
    notifyListeners();
  }
}