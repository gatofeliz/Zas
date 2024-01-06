import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic> _userData = {};

  Map<String, dynamic> get userData => _userData;

  void setUserData(Map<String, dynamic> data) {
    _userData = data;
    notifyListeners();
  }

  int? get userId => _userData['data']['id'] as int?;

  String get userName => _userData['data']['name'] ?? '';

  String get userLastname => _userData['data']['lastname'] ?? '';

  String get userToken => _userData['token'] ?? '';

  String get userEmail => _userData['data']['email'] ?? '';


}
