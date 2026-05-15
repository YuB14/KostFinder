import '../../config/api_config.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String kostId;
  final int rating;
  final String komentar;
  final String status;
  final String userName;
  final String userInitials;
  final String userColor;
  final String? userPhoto;
  final String kostName;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.kostId,
    required this.rating,
    required this.komentar,
    required this.status,
    required this.userName,
    required this.userInitials,
    required this.userColor,
    this.userPhoto,
    required this.kostName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      kostId: json['kost_id']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      komentar: json['komentar'] ?? '',
      status: json['status'] ?? 'Menunggu',
      userName: json['user_name'] ?? 'Pengguna',
      userInitials: json['user_initials'] ?? 'U',
      userColor: json['user_color'] ?? 'linear-gradient(135deg,#E8430D,#FF6B3D)',
      userPhoto: _buildImageUrl(json['user_photo']),
      kostName: json['kost_name'] ?? '-',
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