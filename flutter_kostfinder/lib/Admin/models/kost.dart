class Kost {
  final String id;
  final String namaKost;
  final String alamat;
  final String wifi;
  final String listrik;
  final String fasilitas;
  final String pendinginRuangan;
  final String kamarMandi;
  final String parkirMotor;
  final String ukuranKamar;
  final double harga;

  Kost({
    required this.id,
    required this.namaKost,
    required this.alamat,
    required this.wifi,
    required this.listrik,
    required this.fasilitas,
    required this.pendinginRuangan,
    required this.kamarMandi,
    required this.parkirMotor,
    required this.ukuranKamar,
    required this.harga,
  });

  factory Kost.fromJson(Map<String, dynamic> json) {
    return Kost(
      id: json['id']?.toString() ?? '',
      namaKost: json['nama_kost'] ?? '',
      alamat: json['alamat'] ?? '',
      wifi: json['wifi'] ?? '',
      listrik: json['listrik'] ?? '',
      fasilitas: json['fasilitas'] ?? '',
      pendinginRuangan: json['pendingin_ruangan'] ?? '',
      kamarMandi: json['kamar_mandi'] ?? '',
      parkirMotor: json['parkir_motor'] ?? '',
      ukuranKamar: json['ukuran_kamar'] ?? '',
      harga: (json['harga'] ?? 0).toDouble(),
    );
  }
}
