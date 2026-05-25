import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../../models/kost_model.dart';
import '../../models/review_model.dart';
import 'auth_service.dart';

class KostService {
  static Future<List<KostModel>> getKosts() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.userKost),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((k) => KostModel.fromJson(k)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<ReviewModel>> getKostReviews(String kostId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.kostReviews(kostId)),
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
}