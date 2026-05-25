import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../../models/user_model.dart';

class AuthService {
  // ── Token-based auth headers untuk semua service ──────────────
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Backward-compatible: untuk service lama yang pakai getSavedCookie
  // Sekarang return null, service harus pakai getAuthHeaders()
  static Future<String?> getSavedCookie() async {
    return null; // Tidak lagi pakai cookie
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/auth/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Simpan token dan user data
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }
        await prefs.setString('user', jsonEncode(data['user']));

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
      final headers = await getAuthHeaders();
      await http.post(
        Uri.parse('${ApiConfig.apiUrl}/auth/logout'),
        headers: headers,
      );
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Cek apakah sudah login
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
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
    String? profilePicturePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.apiUrl}/auth/register'),
      );
      request.headers['Accept'] = 'application/json';
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      if (profilePicturePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'profile_picture', profilePicturePath));
      }
      final res = await request.send();
      final body = await res.stream.bytesToString();
      final data = jsonDecode(body);

      if ((res.statusCode == 200 || res.statusCode == 201) && data['success'] == true) {
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