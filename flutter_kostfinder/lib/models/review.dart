class Review {
  final String id;
  final dynamic userId;
  final String kostId;
  final int rating;
  final String komentar;

  Review({
    required this.id,
    required this.userId,
    required this.kostId,
    required this.rating,
    required this.komentar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'],
      kostId: json['kost_id']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toInt(),
      komentar: json['komentar'] ?? '',
    );
  }
}
