import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Model for prediction characteristics returned by Flask ML
class PrediksiKarakteristik {
  final int kelas;
  final String kelasLabel;
  final int tipeKos;
  final String tipeKosLabel;
  final int status;
  final String statusLabel;
  final double luasKamar;
  final int listrik;
  final int ac;
  final int kamarMandiDalam;
  final int parkirMotor;
  final int laundry;
  final int wifi;
  final String source;

  PrediksiKarakteristik({
    required this.kelas,
    required this.kelasLabel,
    required this.tipeKos,
    required this.tipeKosLabel,
    required this.status,
    required this.statusLabel,
    required this.luasKamar,
    required this.listrik,
    required this.ac,
    required this.kamarMandiDalam,
    required this.parkirMotor,
    required this.laundry,
    required this.wifi,
    required this.source,
  });

  factory PrediksiKarakteristik.fromJson(Map<String, dynamic> json) {
    return PrediksiKarakteristik(
      kelas: json['kelas'] ?? 1,
      kelasLabel: json['kelas_label'] ?? 'Ekonomi',
      tipeKos: json['tipe_kos'] ?? 3,
      tipeKosLabel: json['tipe_kos_label'] ?? 'Campur',
      status: json['status'] ?? 1,
      statusLabel: json['status_label'] ?? 'Tersedia',
      luasKamar: (json['luas_kamar'] ?? 0).toDouble(),
      listrik: json['listrik'] ?? 0,
      ac: json['ac'] ?? 0,
      kamarMandiDalam: json['kamar_mandi_dalam'] ?? 0,
      parkirMotor: json['parkir_motor'] ?? 0,
      laundry: json['laundry'] ?? 0,
      wifi: json['wifi'] ?? 0,
      source: json['source'] ?? 'unknown',
    );
  }

  /// Get list of active facility labels
  List<String> get fasilitasAktif {
    final map = <String, int>{
      '⚡ Listrik': listrik,
      '❄️ AC': ac,
      '🚿 KM Dalam': kamarMandiDalam,
      '🏍️ Parkir': parkirMotor,
      '👕 Laundry': laundry,
      '📶 WiFi': wifi,
    };
    return map.entries.where((e) => e.value == 1).map((e) => e.key).toList();
  }
}

/// Model for recommended kost items
class PrediksiKostModel {
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

  PrediksiKostModel({
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
    required this.luasKamar,
    required this.hargaKost,
    required this.listrik,
    required this.ac,
    required this.kamarMandiDalam,
    required this.parkirMotor,
    required this.laundry,
    required this.wifi,
    this.nomorTelepon,
    required this.avgRating,
    required this.reviewsCount,
    required this.skorCocok,
  });

  factory PrediksiKostModel.fromJson(Map<String, dynamic> json) {
    return PrediksiKostModel(
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

  /// Get list of active facility labels
  List<String> get fasilitasAktif {
    final map = <String, int>{
      '⚡ Listrik': listrik,
      '❄️ AC': ac,
      '🚿 KM Dalam': kamarMandiDalam,
      '🏍️ Parkir': parkirMotor,
      '👕 Laundry': laundry,
      '📶 WiFi': wifi,
    };
    return map.entries.where((e) => e.value == 1).map((e) => e.key).toList();
  }
}

class PrediksiService {
  /// Check ML (Flask) server health status
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.userPrediksiHealth),
        headers: headers,
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'flask_status': 'offline'};
    } catch (e) {
      return {'success': false, 'flask_status': 'offline', 'message': '$e'};
    }
  }

  /// Get dataset statistics
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

  /// Run prediction — sends only { harga } to match Laravel API
  static Future<Map<String, dynamic>> predict({required double harga}) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.userPrediksi),
        headers: headers,
        body: jsonEncode({'harga': harga}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Parse prediction characteristics
        final prediksi = PrediksiKarakteristik.fromJson(data['prediksi'] ?? {});
        // Parse kost recommendation list
        final kostList = (data['data'] as List? ?? [])
            .map((k) => PrediksiKostModel.fromJson(k))
            .toList();

        return {
          'success': true,
          'prediksi': prediksi,
          'sumber': data['sumber'] ?? 'unknown',
          'data': kostList,
          'meta': data['meta'] ?? {},
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Prediksi gagal',
        'status': response.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}