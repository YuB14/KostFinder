import '../../config/api_config.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String kostId;
  final String kostNama;
  final String kostAlamat;
  final double kostHarga;
  final String kostKelas;
  final String kostStatus;
  final String? kostFoto;
  final String kostFasilitas;
  final String pillClass;
  final int favCount;
  final String createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.kostId,
    required this.kostNama,
    required this.kostAlamat,
    required this.kostHarga,
    required this.kostKelas,
    required this.kostStatus,
    this.kostFoto,
    required this.kostFasilitas,
    required this.pillClass,
    required this.favCount,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      kostId: json['kost_id']?.toString() ?? '',
      kostNama: json['kost_nama'] ?? '',
      kostAlamat: json['kost_alamat'] ?? '',
      kostHarga: (json['kost_harga'] ?? 0).toDouble(),
      kostKelas: json['kost_kelas'] ?? '',
      kostStatus: json['kost_status'] ?? '',
      kostFoto: _buildImageUrl(json['kost_foto']),
      kostFasilitas: json['kost_fasilitas'] ?? '',
      pillClass: json['pill_class'] ?? 'green',
      favCount: json['fav_count'] ?? 0,
      createdAt: json['created_at'] ?? '-',
    );
  }

  static String? _buildImageUrl(dynamic path) {
    if (path == null || path.toString().isEmpty) return null;
    final str = path.toString();
    if (str.startsWith('http')) return str;
    return '${ApiConfig.baseUrl}/storage/$str';
  }
}