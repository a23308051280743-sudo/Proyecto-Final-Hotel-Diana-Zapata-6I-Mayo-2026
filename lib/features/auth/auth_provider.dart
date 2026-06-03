import 'package:flutter/material.dart';

enum UserRole { guest, user, admin }

class AuthProvider with ChangeNotifier {
  UserRole _role = UserRole.guest;
  bool _isAuthenticated = false;

  UserRole get role => _role;
  bool get isAuthenticated => _isAuthenticated;

  void setRole(UserRole newRole) {
    _role = newRole;
    _isAuthenticated = newRole != UserRole.guest;
    notifyListeners();
  }

  void login(String email, String password) {
    // Mock login logic
    if (email == 'admin@hotel.com') {
      setRole(UserRole.admin);
    } else {
      setRole(UserRole.user);
    }
  }

  void register(String email, String password) {
    // Mock register logic
    setRole(UserRole.user);
  }

  void logout() {
    setRole(UserRole.guest);
  }
}
