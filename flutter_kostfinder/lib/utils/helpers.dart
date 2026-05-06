import 'package:intl/intl.dart';

class Helpers {
  // ── Format Rupiah ────────────────────────────────────────────────────
  static String formatRupiah(dynamic amount) {
    final n = (amount is String) ? double.tryParse(amount) ?? 0 : (amount ?? 0).toDouble();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(n);
  }

  // ── Render Stars ─────────────────────────────────────────────────────
  static String renderStars(dynamic rating) {
    final r = (rating is String) ? double.tryParse(rating) ?? 0 : (rating ?? 0).toDouble();
    final full = r.floor();
    String stars = '';
    for (int i = 1; i <= 5; i++) {
      stars += i <= full ? '★' : '☆';
    }
    return stars;
  }

  // ── Kelas Label ──────────────────────────────────────────────────────
  /// Dari integer (1=Ekonomi, 2=Standar, 3=Premium)
  static String kelasLabelFromInt(int kelas) {
    switch (kelas) {
      case 1: return 'Ekonomi';
      case 2: return 'Standar';
      case 3: return 'Premium';
      default: return 'Ekonomi';
    }
  }

  static String kelasLabel(String kelas) {
    switch (kelas.toLowerCase()) {
      case 'ekonomis':
      case 'ekonomi':
        return '💚 Ekonomi';
      case 'standar':
        return '🔵 Standar';
      case 'premium':
        return '⭐ Premium';
      default:
        return kelas;
    }
  }

  // ── Tipe Kos Label ───────────────────────────────────────────────────
  /// Dari integer (1=Pria, 2=Wanita, 3=Campur)
  static String tipeLabelFromInt(int tipe) {
    switch (tipe) {
      case 1: return 'Pria';
      case 2: return 'Wanita';
      case 3: return 'Campur';
      default: return 'Campur';
    }
  }

  // ── Status Label ─────────────────────────────────────────────────────
  /// 0=Penuh, 1=Tersedia, 2+=sisa kamar
  static String statusLabelFromInt(int status) {
    if (status == 0) return 'Penuh';
    if (status == 1) return 'Tersedia';
    return '$status Kamar Sisa';
  }

  // ── Kode Lokasi Label ────────────────────────────────────────────────
  static const Map<int, String> kodeLokasMap = {
    1: 'Dekat Kampus',
    2: 'Pusat Kota',
    3: 'Pinggir Kota',
    4: 'Dekat Transportasi Umum',
    5: 'Perumahan',
    6: 'Dekat Pasar / Mall',
    7: 'Kawasan Industri',
    8: 'Pinggir Jalan Utama',
    9: 'Pedesaan / Wisata',
    10: 'Lainnya',
  };

  static String kodeLokasLabel(int kode) {
    return kodeLokasMap[kode] ?? 'Lainnya';
  }

  // ── Kelas dari harga ─────────────────────────────────────────────────
  /// Ekonomi < 1jt, Standar 1jt–1.5jt, Premium >= 1.5jt
  static int kelasFromHarga(double harga) {
    if (harga >= 1500000) return 3;
    if (harga >= 1000000) return 2;
    return 1;
  }
}