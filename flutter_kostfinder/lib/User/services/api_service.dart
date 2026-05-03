import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Samakan dengan admin Raka
  static const String baseUrl = 'http://10.10.6.153:8000/api';

  // ── HEADER (Bearer token - sama seperti admin) ──────────────────
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://localhost')) {
      return path.replaceFirst(
          'http://localhost', baseUrl.replaceAll('/api', ''));
    }
    if (!path.startsWith('http')) {
      return '${baseUrl.replaceAll('/api', '')}/storage/$path';
    }
    return path;
  }

  // ── AUTH ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? profilePicturePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/register'),
    );
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    if (profilePicturePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', profilePicturePath));
    }
    final res = await request.send();
    final body = await res.stream.bytesToString();
    return jsonDecode(body);
  }

  static Future<void> saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
    if (user['token'] != null) {
      await prefs.setString('token', user['token']);
    }
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    if (user != null) return jsonDecode(user);
    return null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── KOST (user hanya read) ──────────────────────────────────────

  static Future<List<dynamic>> getKosts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/kost'),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> getKostDetail(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/kost/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── FAVORITE ────────────────────────────────────────────────────

  static Future<List<dynamic>> getFavorites() async {
    final res = await http.get(
      Uri.parse('$baseUrl/favorite'),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> addFavorite({
    required String userId,
    required String kostId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorite'),
      headers: await _headers(),
      body: {'user_id': userId, 'kost_id': kostId},
    );
    return jsonDecode(res.body);
  }

  static Future<void> deleteFavorite(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/favorite/$id'),
      headers: await _headers(),
    );
  }

  // ── REVIEW ──────────────────────────────────────────────────────

  static Future<List<dynamic>> getReviews() async {
    final res = await http.get(
      Uri.parse('$baseUrl/review'),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> createReview({
    required String userId,
    required String kostId,
    required int rating,
    required String komentar,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/review'),
      headers: await _headers(),
      body: {
        'user_id': userId,
        'kost_id': kostId,
        'rating': rating.toString(),
        'komentar': komentar,
      },
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateReview(
    String id, {
    int? rating,
    String? komentar,
  }) async {
    final Map<String, String> body = {};
    if (rating != null) body['rating'] = rating.toString();
    if (komentar != null) body['komentar'] = komentar;
    final res = await http.put(
      Uri.parse('$baseUrl/review/$id'),
      headers: await _headers(),
      body: body,
    );
    return jsonDecode(res.body);
  }

  static Future<void> deleteReview(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/review/$id'),
      headers: await _headers(),
    );
  }
}