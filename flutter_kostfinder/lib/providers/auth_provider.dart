import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../User/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  /// Cek apakah sudah ada session login tersimpan
  Future<void> checkAuth() async {
    final session = await ApiService.getSession();
    if (session != null) {
      try {
        _user = UserModel.fromJson(session);
      } catch (_) {
        _user = null;
      }
    } else {
      _user = null;
    }
    notifyListeners();
  }

  /// Login dan simpan session + token
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.login(email, password);
      if (result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;
        final token = result['token'] as String?;
        await ApiService.saveSession(userData, token: token);
        _user = UserModel.fromJson(userData);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  /// Logout dan hapus session
  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    notifyListeners();
  }
}