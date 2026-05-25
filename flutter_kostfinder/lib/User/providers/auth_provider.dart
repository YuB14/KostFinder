import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<void> checkAuth() async {
    _user = await AuthService.getCurrentUser();
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.login(email, password);
    if (result['success'] == true) {
      _user = result['user'];
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}