import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class PrediksiModel {
  final String id;
  final String namaKost;
  final String? fotoKost;
  final String alamatKost;
  final String kelas;
  final double hargaKost;
  final String fasilitas;
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
    required this.hargaKost,
    required this.fasilitas,
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
      kelas: json['kelas'] ?? '',
      hargaKost: (json['harga_kost'] ?? 0).toDouble(),
      fasilitas: json['fasilitas'] ?? '',
      nomorTelepon: json['nomor_telepon'],
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      skorCocok: (json['skor_cocok'] ?? 0).toDouble(),
    );
  }

  List<String> get fasilitasList {
    if (fasilitas.isEmpty) return [];
    return fasilitas.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
  }
}

class PrediksiService {
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final cookie = await AuthService.getSavedCookie();
      final response = await http.get(
        Uri.parse(ApiConfig.userPrediksiStats),
        headers: ApiConfig.headers(cookie: cookie),
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
      final cookie = await AuthService.getSavedCookie();
      final response = await http.post(
        Uri.parse(ApiConfig.userPrediksi),
        headers: ApiConfig.headers(cookie: cookie),
        body: jsonEncode({
          'harga_max': hargaMax,
          'harga_min': hargaMin,
          'fasilitas': fasilitas,
          'kelas': kelas,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'data': (data['data'] as List).map((k) => PrediksiModel.fromJson(k)).toList(),
          'meta': data['meta'] ?? {},
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Prediksi gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}