import 'package:intl/intl.dart';

class Helpers {
  static String formatRupiah(dynamic amount) {
    final n = (amount is String) ? double.tryParse(amount) ?? 0 : (amount ?? 0).toDouble();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(n);
  }

  static String renderStars(dynamic rating) {
    final r = (rating is String) ? double.tryParse(rating) ?? 0 : (rating ?? 0).toDouble();
    final full = r.floor();
    String stars = '';
    for (int i = 1; i <= 5; i++) {
      stars += i <= full ? '★' : '☆';
    }
    return stars;
  }

  static String kelasLabel(String kelas) {
    switch (kelas.toLowerCase()) {
      case 'ekonomis':
        return '💚 Ekonomis';
      case 'standar':
        return '🔵 Standar';
      case 'premium':
        return '⭐ Premium';
      default:
        return kelas;
    }
  }
}