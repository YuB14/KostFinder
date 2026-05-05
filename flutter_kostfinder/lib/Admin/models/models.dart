class KostModel {
  final int id;
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

  const KostModel({
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

  factory KostModel.fromJson(Map<String, dynamic> json) => KostModel(
    id: json['id'] ?? 0,
    namaKost: json['nama_kost'] ?? '',
    alamat: json['alamat'] ?? '',
    wifi: json['wifi'] ?? '',
    listrik: json['listrik'] ?? '',
    fasilitas: json['fasilitas'] ?? '',
    pendinginRuangan: json['pendingin_ruangan'] ?? '',
    kamarMandi: json['kamar_mandi'] ?? '',
    parkirMotor: json['parkir_motor'] ?? '',
    ukuranKamar: json['ukuran_kamar'] ?? '',
    harga: double.tryParse(json['harga'].toString()) ?? 0,
  );

  String get hargaFormatted {
    final n = harga.toInt();
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  List<String> get tags {
    final list = <String>[];
    if (wifi == 'ya' || wifi == 'Ada') list.add('WiFi');
    if (pendinginRuangan == 'ya' || pendinginRuangan == 'Ada') list.add('AC');
    if (kamarMandi == 'dalam') list.add('KM Dalam');
    if (parkirMotor == 'ya' || parkirMotor == 'Ada') list.add('Parkir');
    return list.take(3).toList();
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? 'user',
    profilePicture: json['profile_picture'],
  );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'U';
  }
}
