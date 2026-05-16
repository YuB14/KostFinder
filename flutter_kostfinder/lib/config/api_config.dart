class ApiConfig {
  // ── Ganti baseUrl sesuai environment ──────────────────────────
  // Emulator Android  : http://10.0.2.2:8000
  // Device fisik      : http://<IP_KOMPUTER>:8000 (jalankan: php artisan serve --host=0.0.0.0)
  // IP komputer saat ini: 192.168.1.8
  static const String baseUrl = 'http://192.168.1.8:8000';
  static const String apiUrl = '$baseUrl/api';

  // User API endpoints
  static const String userStats = '$apiUrl/user/stats';
  static const String userKost = '$apiUrl/user/kost';
  static const String userReview = '$apiUrl/user/review';
  static const String userFavorite = '$apiUrl/user/favorite';
  static const String userPrediksi = '$apiUrl/user/prediksi';
  static const String userPrediksiStats = '$apiUrl/user/prediksi/stats';

  static String kostReviews(String kostId) => '$apiUrl/user/kost/$kostId/reviews';
  static String deleteReview(String id) => '$apiUrl/user/review/$id';
  static String deleteFavorite(String id) => '$apiUrl/user/favorite/$id';
}