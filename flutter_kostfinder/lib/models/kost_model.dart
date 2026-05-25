/// Model Kost — sesuai schema MongoDB & KostResource Laravel
/// Field mapping:
///   tipe_kos  : 1=Pria, 2=Wanita, 3=Campur
///   kelas     : 1=Ekonomi, 2=Standar, 3=Premium
///   status    : 0=Penuh, 1=Tersedia, 2+=sisa kamar
///   kode_lokasi: 1–10 (lihat [kodeLokasLabel])
///   fasilitas : listrik, ac, kamar_mandi_dalam, parkir_motor, laundry, wifi (0/1)
import '../config/api_config.dart';

class KostModel {
  final String id;
  final String namaKost;
  final String? fotoKost;
  final String alamatKost;
  final double hargaKost;
  final double luasKamar;

  // Integer mappings (sesuai Laravel)
  final int tipeKos;      // 1=Pria, 2=Wanita, 3=Campur
  final int kelas;        // 1=Ekonomi, 2=Standar, 3=Premium
  final int status;       // 0=Penuh, 1=Tersedia, 2+=sisa kamar
  final int kodeLokasi;   // 1–10
  final String wilayahId;
  final String? wilayahNama;

  // Fasilitas binary (0/1)
  final int listrik;
  final int ac;
  final int kamarMandiDalam;
  final int parkirMotor;
  final int laundry;
  final int wifi;

  // Info tambahan (nullable)
  final String? nomorTelepon;
  final String? deskripsi;

  // Rating
  final double avgRating;
  final int reviewsCount;

  // Label display (dari API atau dihitung lokal)
  final String? kelasLabel;
  final String? tipeKosLabel;
  final String? statusLabel;
  final String? lokasiLabel;

  KostModel({
    required this.id,
    required this.namaKost,
    this.fotoKost,
    required this.alamatKost,
    required this.hargaKost,
    this.luasKamar = 0,
    this.tipeKos = 3,
    this.kelas = 1,
    this.status = 1,
    this.kodeLokasi = 1,
    this.wilayahId = '',
    this.wilayahNama,
    this.listrik = 1,
    this.ac = 0,
    this.kamarMandiDalam = 0,
    this.parkirMotor = 0,
    this.laundry = 0,
    this.wifi = 0,
    this.nomorTelepon,
    this.deskripsi,
    this.avgRating = 0,
    this.reviewsCount = 0,
    this.kelasLabel,
    this.tipeKosLabel,
    this.statusLabel,
    this.lokasiLabel,
  });

  factory KostModel.fromJson(Map<String, dynamic> json) {
    return KostModel(
      id: json['id']?.toString() ?? '',
      namaKost: json['nama_kost']?.toString() ?? '',
      fotoKost: _buildImageUrl(json['foto_kost']),
      alamatKost: json['alamat_kost']?.toString() ?? '',
      hargaKost: _toDouble(json['harga_kost']),
      luasKamar: _toDouble(json['luas_kamar']),
      tipeKos: _toInt(json['tipe_kos'], 3),
      kelas: _toInt(json['kelas'], 1),
      status: _toInt(json['status'], 1),
      kodeLokasi: _toInt(json['kode_lokasi'], 1),
      wilayahId: json['wilayah_id']?.toString() ?? '',
      wilayahNama: json['wilayah_nama'] as String?,
      listrik: _toInt(json['listrik'], 1),
      ac: _toInt(json['ac'], 0),
      kamarMandiDalam: _toInt(json['kamar_mandi_dalam'], 0),
      parkirMotor: _toInt(json['parkir_motor'], 0),
      laundry: _toInt(json['laundry'], 0),
      wifi: _toInt(json['wifi'], 0),
      nomorTelepon: json['nomor_telepon'] as String?,
      deskripsi: json['deskripsi'] as String?,
      avgRating: _toDouble(json['avg_rating']),
      reviewsCount: _toInt(json['reviews_count'], 0),
      kelasLabel: json['kelas_label'] as String?,
      tipeKosLabel: json['tipe_kos_label'] as String?,
      statusLabel: json['status_label'] as String?,
      lokasiLabel: json['lokasi_label'] as String?,
    );
  }

  // ── Computed labels (fallback jika tidak ada dari API) ──────────────

  String get kelasLabelDisplay {
    if (kelasLabel != null && kelasLabel!.isNotEmpty) return kelasLabel!;
    switch (kelas) {
      case 1: return 'Ekonomi';
      case 2: return 'Standar';
      case 3: return 'Premium';
      default: return 'Ekonomi';
    }
  }

  String get tipeKosLabelDisplay {
    if (tipeKosLabel != null && tipeKosLabel!.isNotEmpty) return tipeKosLabel!;
    switch (tipeKos) {
      case 1: return 'Pria';
      case 2: return 'Wanita';
      case 3: return 'Campur';
      default: return 'Campur';
    }
  }

  String get statusLabelDisplay {
    if (statusLabel != null && statusLabel!.isNotEmpty) return statusLabel!;
    if (status == 0) return 'Penuh';
    if (status == 1) return 'Tersedia';
    return '$status Kamar Sisa';
  }

  String get kodeLokasLabelDisplay {
    if (lokasiLabel != null && lokasiLabel!.isNotEmpty) return lokasiLabel!;
    const map = {
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
    return map[kodeLokasi] ?? 'Lainnya';
  }

  /// Daftar fasilitas aktif sebagai string label
  List<String> get fasilitasList {
    final list = <String>[];
    if (listrik == 1) list.add('⚡ Listrik');
    if (ac == 1) list.add('❄️ AC');
    if (kamarMandiDalam == 1) list.add('🚿 KM Dalam');
    if (parkirMotor == 1) list.add('🏍️ Parkir Motor');
    if (laundry == 1) list.add('👕 Laundry');
    if (wifi == 1) list.add('📶 WiFi');
    return list;
  }

  // ── Helpers ────────────────────────────────────────────────────────

  static String? _buildImageUrl(dynamic path) {
    if (path == null || path.toString().isEmpty) return null;
    final str = path.toString();
    if (str.startsWith('http')) return str;
    return '${ApiConfig.baseUrl}/storage/$str';
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }
}