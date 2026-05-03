import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const _cookieKey = 'session_cookie';
  static const _userKey = 'user_data';

  // Ambil cookie tersimpan
  static Future<String?> getSavedCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  // Simpan cookie dari response
  static Future<void> saveCookie(http.Response response) async {
    final prefs = await SharedPreferences.getInstance();
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Ambil hanya session cookie
      final sessionCookie = rawCookie.split(';').first;
      await prefs.setString(_cookieKey, sessionCookie);
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password, {bool remember = true}) async {
    try {
      // Step 1: Ambil CSRF cookie dulu
      await http.get(Uri.parse('${ApiConfig.baseUrl}/sanctum/csrf-cookie'));

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: ApiConfig.headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'remember': remember,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveCookie(response);

        // Simpan data user
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(data['user']));

        return {'success': true, 'user': UserModel.fromJson(data['user'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final cookie = await getSavedCookie();
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
        headers: ApiConfig.headers(cookie: cookie),
      );
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
    await prefs.remove(_userKey);
  }

  // Cek apakah sudah login
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userData));
    } catch (_) {
      return null;
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: ApiConfig.headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        String msg = data['message'] ?? 'Pendaftaran gagal';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          msg = errors.values.expand((e) => e as List).first.toString();
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}