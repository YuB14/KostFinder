import 'package:intl/intl.dart';

class Helpers {
  static String formatRupiah(dynamic amount) {
    final n = (amount is String)
        ? double.tryParse(amount) ?? 0
        : (amount ?? 0).toDouble();
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(n);
  }

  static String initials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}