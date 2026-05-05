import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class PrediksiModel {
  final String id;
  final String namaKost;
  final String? fotoKost;
  final String alamatKost;
  final int kelas;
  final String kelasLabel;
  final int tipeKos;
  final String tipeKosLabel;
  final int status;
  final String statusLabel;
  final int kodeLokasi;
  final String lokasiLabel;
  final double luasKamar;
  final double hargaKost;
  final int listrik;
  final int ac;
  final int kamarMandiDalam;
  final int parkirMotor;
  final int laundry;
  final int wifi;
  final String? nomorTelepon;
  final double avgRating;
  final int reviewsCount;
  final double skorCocok;

  PrediksiModel({
    required this.id,
    required this.namaKost,
    this.fotoKost,
    required this.alamatKost,
    required this.kelas,
    required this.kelasLabel,
    required this.tipeKos,
    required this.tipeKosLabel,
    required this.status,
    required this.statusLabel,
    required this.kodeLokasi,
    required this.lokasiLabel,
    required this.luasKamar,
    required this.hargaKost,
    this.listrik = 0,
    this.ac = 0,
    this.kamarMandiDalam = 0,
    this.parkirMotor = 0,
    this.laundry = 0,
    this.wifi = 0,
    this.nomorTelepon,
    required this.avgRating,
    required this.reviewsCount,
    required this.skorCocok,
  });

  factory PrediksiModel.fromJson(Map<String, dynamic> json) {
    return PrediksiModel(
      id: json['id']?.toString() ?? '',
      namaKost: json['nama_kost'] ?? '',
      fotoKost: json['foto_kost'],
      alamatKost: json['alamat_kost'] ?? '',
      kelas: json['kelas'] ?? 1,
      kelasLabel: json['kelas_label'] ?? 'Ekonomi',
      tipeKos: json['tipe_kos'] ?? 3,
      tipeKosLabel: json['tipe_kos_label'] ?? 'Campur',
      status: json['status'] ?? 1,
      statusLabel: json['status_label'] ?? 'Tersedia',
      kodeLokasi: json['kode_lokasi'] ?? 1,
      lokasiLabel: json['lokasi_label'] ?? '',
      luasKamar: (json['luas_kamar'] ?? 0).toDouble(),
      hargaKost: (json['harga_kost'] ?? 0).toDouble(),
      listrik: json['listrik'] ?? 0,
      ac: json['ac'] ?? 0,
      kamarMandiDalam: json['kamar_mandi_dalam'] ?? 0,
      parkirMotor: json['parkir_motor'] ?? 0,
      laundry: json['laundry'] ?? 0,
      wifi: json['wifi'] ?? 0,
      nomorTelepon: json['nomor_telepon'],
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      skorCocok: (json['skor_cocok'] ?? 0).toDouble(),
    );
  }

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
}

class PrediksiService {
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.userPrediksiStats),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> predict({
    required double hargaMax,
    double hargaMin = 0,
    List<String> fasilitas = const [],
    String kelas = '',
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.userPrediksi),
        headers: headers,
        body: jsonEncode({
          'harga': hargaMax,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'data': (data['data'] as List).map((k) => PrediksiModel.fromJson(k)).toList(),
          'meta': data['meta'] ?? {},
          'prediksi': data['prediksi'],
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Prediksi gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}