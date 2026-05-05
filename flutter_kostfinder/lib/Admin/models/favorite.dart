class Favorite {
  final String id;
  final dynamic userId;
  final String kostId;

  Favorite({
    required this.id,
    required this.userId,
    required this.kostId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'],
      kostId: json['kost_id']?.toString() ?? '',
    );
  }
}
