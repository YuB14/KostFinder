import 'package:flutter/foundation.dart';

class ApiConfig {
  // ── Ganti baseUrl sesuai environment ──────────────────────────
  // Emulator Android  : http://10.0.2.2:8000
  // Device fisik      : http://<IP_KOMPUTER>:8000 (jalankan: php artisan serve --host=0.0.0.0)
  // Flutter Web/Edge  : http://127.0.0.1:8000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      return 'http://10.10.187.99:8000'; // IP komputer Anda untuk Device Fisik
    }
  }

  static String get apiUrl => '$baseUrl/api';

  // User API endpoints
  static String get userStats => '$apiUrl/user/stats';
  static String get userKost => '$apiUrl/user/kost';
  static String get userReview => '$apiUrl/user/review';
  static String get userFavorite => '$apiUrl/user/favorite';
  static String get userPrediksi => '$apiUrl/user/prediksi';
  static String get userPrediksiStats => '$apiUrl/user/prediksi/stats';
  static String get userPrediksiHealth => '$apiUrl/user/prediksi/health';

  // Wilayah endpoints
  static String get wilayah => '$apiUrl/wilayah';

  static String kostReviews(String kostId) => '$apiUrl/user/kost/$kostId/reviews';
  static String deleteReview(String id) => '$apiUrl/user/review/$id';
  static String deleteFavorite(String id) => '$apiUrl/user/favorite/$id';
}