class ApiConfig {
  // Ganti dengan IP server Laravel kamu
  // Emulator Android: 10.0.2.2
  // Device fisik: IP komputer kamu, contoh: 192.168.1.5
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String apiUrl = '$baseUrl/api';

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';

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

  static Map<String, String> headers({String? cookie}) {
    final h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (cookie != null) h['Cookie'] = cookie;
    return h;
  }
}