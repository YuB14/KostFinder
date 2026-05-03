class KostModel {
  final String id;
  final String namaKost;
  final String? fotoKost;
  final String alamatKost;
  final String kelas;
  final String jenisKost;
  final String status;
  final String? fasilitas;
  final double hargaKost;
  final String? nomorTelepon;
  final double avgRating;
  final int reviewsCount;

  KostModel({
    required this.id,
    required this.namaKost,
    this.fotoKost,
    required this.alamatKost,
    required this.kelas,
    required this.jenisKost,
    required this.status,
    this.fasilitas,
    required this.hargaKost,
    this.nomorTelepon,
    this.avgRating = 0,
    this.reviewsCount = 0,
  });

  factory KostModel.fromJson(Map<String, dynamic> json) {
    return KostModel(
      id: json['id']?.toString() ?? '',
      namaKost: json['nama_kost'] ?? '',
      fotoKost: json['foto_kost'],
      alamatKost: json['alamat_kost'] ?? '',
      kelas: json['kelas'] ?? '',
      jenisKost: json['jenis_kost'] ?? 'Bebas',
      status: json['status'] ?? '',
      fasilitas: json['fasilitas'],
      hargaKost: (json['harga_kost'] ?? 0).toDouble(),
      nomorTelepon: json['nomor_telepon'],
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
    );
  }

  List<String> get fasilitasList {
    if (fasilitas == null || fasilitas!.isEmpty) return [];
    return fasilitas!.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
  }
}