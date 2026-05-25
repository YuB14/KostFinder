import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../../models/review_model.dart';
import 'auth_service.dart';

class ReviewService {
  static Future<List<ReviewModel>> getMyReviews() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.userReview),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((r) => ReviewModel.fromJson(r)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addReview({
    required String kostId,
    required int rating,
    required String komentar,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.userReview),
        headers: headers,
        body: jsonEncode({
          'kost_id': kostId,
          'rating': rating,
          'komentar': komentar,
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true || response.statusCode == 201,
        'message': data['message'] ?? '',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal'};
    }
  }

  static Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required int rating,
    required String komentar,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.userReview}/$reviewId'),
        headers: headers,
        body: jsonEncode({
          'rating': rating,
          'komentar': komentar,
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? '',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal'};
    }
  }
}