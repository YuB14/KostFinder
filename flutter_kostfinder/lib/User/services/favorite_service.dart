import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../../models/favorite_model.dart';
import 'auth_service.dart';

class FavoriteService {
  static Future<List<FavoriteModel>> getFavorites() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.userFavorite),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((f) => FavoriteModel.fromJson(f)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addFavorite(String kostId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.userFavorite),
        headers: headers,
        body: jsonEncode({'kost_id': kostId}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true || response.statusCode == 201,
        'message': data['message'] ?? '',
        'status': response.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal'};
    }
  }

  static Future<bool> deleteFavorite(String favId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteFavorite(favId)),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}