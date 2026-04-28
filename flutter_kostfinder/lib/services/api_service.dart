import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.10.6.153:8000/api';

  // HEADER
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
      return path.replaceFirst('http://localhost', baseUrl.replaceAll('/api', ''));
    }
    if (!path.startsWith('http')) {
      return '${baseUrl.replaceAll('/api', '')}/storage/$path';
    }
    return path;
  }

  // ================= AUTH =================

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
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
        'profile_picture',
        profilePicturePath,
      ));
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

  if (user != null) {
    return jsonDecode(user);
  }
  return null;
}

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ================= DASHBOARD =================

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/stats'), headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getDashboardTopKosts() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/top-kost'), headers: await _headers());
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<List<dynamic>> getDashboardRecentActivity() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/recent-activity'), headers: await _headers());
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> getDashboardRegistrations() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard/registrations'), headers: await _headers());
    return jsonDecode(res.body);
  }

  // ================= KOST =================

  static Future<List<dynamic>> getKosts() async {
    final res = await http.get(Uri.parse('$baseUrl/kost'));

    print("STATUS GET: ${res.statusCode}");
    print("BODY GET: ${res.body}");

    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> getKostDetail(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/kost/$id'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addKost({
    required String namaKost,
    required String alamatKost,
    required String kelas,
    required String jenisKost,
    required String status,
    required String fasilitas,
    required String hargaKost,
    required String nomorTelepon,
    required String deskripsi,
    required List<String> fotoPaths,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/kost'),
    );

    request.headers.addAll(await _headers());

    request.fields['nama_kost'] = namaKost;
    request.fields['alamat_kost'] = alamatKost;
    request.fields['kelas'] = kelas;
    request.fields['jenis_kost'] = jenisKost;
    request.fields['status'] = status;
    request.fields['fasilitas'] = fasilitas;
    request.fields['harga_kost'] = hargaKost;
    request.fields['nomor_telepon'] = nomorTelepon;
    request.fields['deskripsi'] = deskripsi;

    if (fotoPaths.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_kost',
          fotoPaths.first,
        ),
      );
    }

    print("FIELDS POST: ${request.fields}");
    print("FILES POST: ${request.files.map((e) => e.filename).toList()}");

    final response = await request.send();

    final body = await response.stream.bytesToString();

    print("STATUS POST: ${response.statusCode}");
    print("BODY POST: $body");

    return jsonDecode(body);
  }

  static Future<Map<String, dynamic>> createKost({
    required String namaKost,
    required String alamatKost,
    required String kelas,
    required String jenisKost,
    required String status,
    required String fasilitas,
    required String hargaKost,
    required String nomorTelepon,
    required String deskripsi,
    required List<String> fotoPaths,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/kost'),
      );

      request.headers.addAll(await _headers());

      request.fields.addAll({
        'nama_kost': namaKost,
        'alamat_kost': alamatKost,
        'kelas': kelas,
        'jenis_kost': jenisKost,
        'status': status,
        'fasilitas': fasilitas,
        'harga_kost': hargaKost,
        'nomor_telepon': nomorTelepon,
        'deskripsi': deskripsi,
      });

      if (fotoPaths.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_kost',
            fotoPaths.first,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );

      final responseBody = await streamedResponse.stream.bytesToString();

      print("STATUS POST: ${streamedResponse.statusCode}");
      print("BODY POST: $responseBody");

      if (responseBody.isEmpty) {
        return {
          'success': false,
          'message': 'Response kosong dari server',
        };
      }

      final decoded = jsonDecode(responseBody);

      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        return decoded;
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal menambahkan kost',
        'status_code': streamedResponse.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateKost({
    required String id,
    required String namaKost,
    required String alamatKost,
    required String kelas,
    required String jenisKost,
    required String status,
    required String fasilitas,
    required String hargaKost,
    required String nomorTelepon,
    required String deskripsi,
    List<String> fotoPaths = const [],
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/kost/$id'),
      );

      request.headers.addAll(await _headers());

      request.fields.addAll({
        '_method': 'PUT',
        'nama_kost': namaKost,
        'alamat_kost': alamatKost,
        'kelas': kelas,
        'jenis_kost': jenisKost,
        'status': status,
        'fasilitas': fasilitas,
        'harga_kost': hargaKost,
        'nomor_telepon': nomorTelepon,
        'deskripsi': deskripsi,
      });

      if (fotoPaths.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_kost',
            fotoPaths.first,
          ),
        );
      }

      final res = await request.send().timeout(
        const Duration(seconds: 20),
      );

      final body = await res.stream.bytesToString();

      print("STATUS UPDATE: ${res.statusCode}");
      print("BODY UPDATE: $body");

      if (body.isEmpty) {
        return {
          'success': false,
          'message': 'Response kosong dari server',
        };
      }

      return jsonDecode(body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi error: $e',
      };
    }
  }
  // ================= FAVORITE =================

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
      body: {
        'user_id': userId,
        'kost_id': kostId,
      },
    );

    return jsonDecode(res.body);
  }

  static Future<void> deleteFavorite(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/favorite/$id'),
      headers: await _headers(),
    );
  }

  // ================= REVIEW =================

  static Future<List<dynamic>> getReviews() async {
    final res = await http.get(Uri.parse('$baseUrl/review'));
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }
static Future<Map<String, dynamic>> createReview({
  required String userId,
  required String kostId,
  required int rating,
  required String komentar,
}) async {
  print("=== CREATE REVIEW DIPANGGIL ===");

  final bodyData = {
    'user_id': userId,
    'kost_id': kostId,
    'rating': rating.toString(),
    'komentar': komentar,
  };

  print("REQUEST BODY: $bodyData");

  final res = await http.post(
    Uri.parse('$baseUrl/review'),
    headers: await _headers(),
    body: bodyData,
  );

  print("POST STATUS: ${res.statusCode}");
  print("POST BODY: ${res.body}");

  return jsonDecode(res.body);
}

  static Future<Map<String, dynamic>> updateReview(String id, {
    String? status,
    int? rating,
    String? komentar,
  }) async {
    final Map<String, String> body = {};
    if (status != null) body['status'] = status;
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

  // ================= USER =================

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> updateUser(String id, {
    String? name,
    String? email,
    String? password,
    String? role,
    String? profilePicturePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/users/$id'),
    );
    
    // Add method spoofing for Laravel
    request.fields['_method'] = 'PUT';
    
    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    if (password != null && password.isNotEmpty) request.fields['password'] = password;
    if (role != null) request.fields['role'] = role;

    if (profilePicturePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        profilePicturePath,
      ));
    }
    
    final headers = await _headers();
    request.headers.addAll(headers);

    final res = await request.send();
    final body = await res.stream.bytesToString();
    return jsonDecode(body);
  }

  static Future<void> deleteUser(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: await _headers(),
    );
  }
}