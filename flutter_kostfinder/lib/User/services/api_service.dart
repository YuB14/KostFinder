import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class ApiService {
  // ── HEADER (Bearer token) ──────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://localhost')) {
      return path.replaceFirst(
          'http://localhost', ApiConfig.baseUrl);
    }
    if (!path.startsWith('http')) {
      return '${ApiConfig.baseUrl}/storage/$path';
    }
    return path;
  }

  // ── AUTH ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http
        .post(
          Uri.parse('${ApiConfig.apiUrl}/auth/login'),
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
    Uint8List? profilePictureBytes,
    String? profilePictureName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.apiUrl}/auth/register'),
    );
    request.headers['Accept'] = 'application/json';
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    if (profilePictureBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'profile_picture',
        profilePictureBytes,
        filename: profilePictureName ?? 'profile.jpg',
      ));
    } else if (profilePicturePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', profilePicturePath));
    }
    final res = await request.send();
    final body = await res.stream.bytesToString();
    return jsonDecode(body);
  }

  static Future<void> saveSession(Map<String, dynamic> userData, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userData));
    if (token != null) {
      await prefs.setString('token', token);
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

  static Future<void> logout() async {
    try {
      final headers = await _headers();
      await http.post(
        Uri.parse('${ApiConfig.apiUrl}/auth/logout'),
        headers: headers,
      );
    } catch (_) {}
    await clearSession();
  }

  // ── KOST (user hanya read) ──────────────────────────────────────

  static Future<List<dynamic>> getKosts() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/kost'),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> getKostDetail(String id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/kost/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── FAVORITE ────────────────────────────────────────────────────

  static Future<List<dynamic>> getFavorites() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/favorite'),
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
      Uri.parse('${ApiConfig.apiUrl}/favorite'),
      headers: await _headers(),
      body: jsonEncode({'user_id': userId, 'kost_id': kostId}),
    );
    return jsonDecode(res.body);
  }

  static Future<void> deleteFavorite(String id) async {
    await http.delete(
      Uri.parse('${ApiConfig.apiUrl}/favorite/$id'),
      headers: await _headers(),
    );
  }

  // ── REVIEW ──────────────────────────────────────────────────────

  static Future<List<dynamic>> getReviews() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/review'),
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
      Uri.parse('${ApiConfig.apiUrl}/review'),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
        'kost_id': kostId,
        'rating': rating,
        'komentar': komentar,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateReview(
    String id, {
    int? rating,
    String? komentar,
  }) async {
    final Map<String, dynamic> body = {};
    if (rating != null) body['rating'] = rating;
    if (komentar != null) body['komentar'] = komentar;
    final res = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/review/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<void> deleteReview(String id) async {
    await http.delete(
      Uri.parse('${ApiConfig.apiUrl}/review/$id'),
      headers: await _headers(),
    );
  }

  // ── WILAYAH ─────────────────────────────────────────────────────

  static Future<List<dynamic>> getWilayahs() async {
    final res = await http.get(
      Uri.parse(ApiConfig.wilayah),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }
}