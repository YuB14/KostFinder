import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

/// Full-page Kost Detail Screen for User role.
/// Layout matches Admin's KostDetailScreen style.
class UserKostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> kost;

  const UserKostDetailScreen({super.key, required this.kost});

  @override
  State<UserKostDetailScreen> createState() => _UserKostDetailScreenState();
}

class _UserKostDetailScreenState extends State<UserKostDetailScreen> {
  List<dynamic> _reviews = [];
  bool _loadingReviews = true;
  bool _addingFav = false;
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final all = await ApiService.getReviews();
      final kostId = widget.kost['id']?.toString();
      _reviews = all
          .where((r) =>
              r['kost_id']?.toString() == kostId &&
              r['status'] == 'Disetujui')
          .toList();
    } catch (_) {}
    if (mounted) setState(() => _loadingReviews = false);
  }

  Future<void> _addFavorite() async {
    setState(() => _addingFav = true);
    try {
      final session = await ApiService.getSession();
      final userId = session?['user']?['id']?.toString() ??
          session?['id']?.toString() ?? '';
      final res = await ApiService.addFavorite(
        userId: userId,
        kostId: widget.kost['id']?.toString() ?? '',
      );
      if (!mounted) return;
      setState(() => _isFav = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['success'] == true
            ? '❤️ Berhasil ditambahkan ke favorit!'
            : res['message'] ?? 'Gagal'),
        backgroundColor:
            res['success'] == true ? AppColors.teal : const Color(0xFFE53E3E),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
    if (mounted) setState(() => _addingFav = false);
  }

  static int _toInt(dynamic v, int fb) {
    if (v == null) return fb;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fb;
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kost;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final text = isDark ? AppColors.textDark : AppColors.textLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final foto = k['foto_kost'] ?? k['foto'];
    final fotoUrl = foto != null ? ApiService.getImageUrl(foto.toString()) : null;
    final validFoto = fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.contains('default');

    // Labels
    final kelasInt = _toInt(k['kelas'], 1);
    final kelasStr = k['kelas_label']?.toString() ??
        (kelasInt == 1 ? 'Ekonomi' : kelasInt == 2 ? 'Standar' : 'Premium');
    final tipeInt = _toInt(k['tipe_kos'], 3);
    final tipeStr = k['tipe_kos_label']?.toString() ??
        (tipeInt == 1 ? 'Pria' : tipeInt == 2 ? 'Wanita' : 'Campur');
    final statusInt = _toInt(k['status'], 1);
    final statusStr = k['status_label']?.toString() ??
        (statusInt == 0
            ? 'Penuh'
            : statusInt == 1
                ? 'Tersedia'
                : '$statusInt Kamar Sisa');
    final luasKamar = (k['luas_kamar'] ?? 0).toString();
    final wilayahNama = k['wilayah_nama']?.toString() ?? '-';
    final kodeLokStr = k['lokasi_label']?.toString() ?? '';
    final deskripsi = k['deskripsi']?.toString() ?? '';
    final avgRating = k['avg_rating'] ?? 0;
    final reviewsCount = k['reviews_count'] ?? 0;

    // Facilities
    final List<String> fasList = [];
    if (_toInt(k['listrik'], 1) == 1) fasList.add('⚡ Listrik');
    if (_toInt(k['ac'], 0) == 1) fasList.add('❄️ AC');
    if (_toInt(k['kamar_mandi_dalam'], 0) == 1) fasList.add('🚿 KM Dalam');
    if (_toInt(k['parkir_motor'], 0) == 1) fasList.add('🏍️ Parkir Motor');
    if (_toInt(k['laundry'], 0) == 1) fasList.add('👕 Laundry');
    if (_toInt(k['wifi'], 0) == 1) fasList.add('📶 WiFi');

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.coral,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (validFoto)
                    Image.network(fotoUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _gradientPlaceholder())
                  else
                    _gradientPlaceholder(),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFav ? AppColors.coral : Colors.white,
                ),
                onPressed: _addingFav ? null : _addFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k['nama_kost'] ?? '-',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: text)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.location_on_rounded,
                                  size: 14, color: muted),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(k['alamat_kost'] ?? '-',
                                      style: TextStyle(
                                          fontSize: 14, color: muted))),
                            ]),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.tealBg,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: AppColors.yellow),
                          const SizedBox(width: 4),
                          Text('$avgRating',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal)),
                          Text(' ($reviewsCount)',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.teal)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Row(children: [
                    Text(Helpers.formatRupiah(k['harga_kost'] ?? 0),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.coral)),
                    Text(' / bulan',
                        style: TextStyle(fontSize: 14, color: muted)),
                  ]),
                  const SizedBox(height: 24),

                  // Info Cards Row 1: Tipe + Kelas
                  Row(children: [
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.person_rounded,
                            title: 'Tipe',
                            value: tipeStr,
                            isDark: isDark,
                            card: card,
                            border: border,
                            text: text,
                            muted: muted)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.meeting_room_rounded,
                            title: 'Kelas',
                            value: kelasStr,
                            isDark: isDark,
                            card: card,
                            border: border,
                            text: text,
                            muted: muted)),
                  ]),
                  const SizedBox(height: 12),

                  // Info Cards Row 2: Status + Luas Kamar
                  Row(children: [
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.check_circle_rounded,
                            title: 'Status',
                            value: statusStr,
                            isDark: isDark,
                            card: card,
                            border: border,
                            text: text,
                            muted: muted)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.square_foot_rounded,
                            title: 'Luas Kamar',
                            value: '$luasKamar m²',
                            isDark: isDark,
                            card: card,
                            border: border,
                            text: text,
                            muted: muted)),
                  ]),
                  const SizedBox(height: 12),

                  // Info Cards Row 3: Wilayah + Kode Lokasi
                  Row(children: [
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.location_city_rounded,
                            title: 'Wilayah',
                            value: wilayahNama.isNotEmpty ? wilayahNama : '-',
                            isDark: isDark,
                            card: card,
                            border: border,
                            text: text,
                            muted: muted)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.pin_drop_rounded,
                            title: 'Kode Lokasi',
                            value: kodeLokStr.isNotEmpty ? kodeLokStr : '-',
                            isDark: isDark,
                            card: card,
                            border: border,
                            text: text,
                            muted: muted)),
                  ]),
                  const SizedBox(height: 24),

                  // Deskripsi
                  if (deskripsi.isNotEmpty) ...[
                    Text('Deskripsi Kost',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: text)),
                    const SizedBox(height: 8),
                    Text(deskripsi,
                        style: TextStyle(
                            fontSize: 14, color: muted, height: 1.5)),
                    const SizedBox(height: 24),
                  ],

                  // Fasilitas
                  Text('Fasilitas',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: text)),
                  const SizedBox(height: 12),
                  fasList.isNotEmpty
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: fasList
                              .map((f) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.bg2Dark
                                          : AppColors.bg2Light,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: border),
                                    ),
                                    child: Text(f,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: text)),
                                  ))
                              .toList(),
                        )
                      : Text('Tidak ada fasilitas tercatat',
                          style: TextStyle(fontSize: 13, color: muted)),
                  const SizedBox(height: 24),

                  // Kontak Pemilik
                  if ((k['nomor_telepon'] ?? '').toString().isNotEmpty) ...[
                    Text('Kontak Pemilik',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: text)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border)),
                      child: Row(children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                              color: AppColors.tealBg,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.person_outline_rounded,
                              color: AppColors.teal),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pemilik Kost',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: text)),
                                const SizedBox(height: 4),
                                Text(k['nomor_telepon'].toString(),
                                    style: TextStyle(
                                        fontSize: 14, color: muted)),
                              ]),
                        ),
                        IconButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final phone = (k['nomor_telepon'] ?? '').toString();
                            final name = (k['nama_kost'] ?? '').toString();
                            final ok = await Helpers.launchWhatsApp(
                              phone,
                              'Halo, saya tertarik dengan kost $name. Apakah masih tersedia?',
                            );
                            if (!ok) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Gagal membuka WhatsApp')),
                              );
                            }
                          },
                          icon: const Icon(Icons.phone_rounded,
                              color: AppColors.teal),
                          style: IconButton.styleFrom(
                              backgroundColor: AppColors.tealBg),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reviews section
                  Divider(color: border),
                  const SizedBox(height: 8),
                  Text('⭐ Ulasan Pengguna',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: text)),
                  const SizedBox(height: 12),
                  if (_loadingReviews)
                    const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.coral))
                  else if (_reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.bg2Dark
                              : AppColors.bg2Light,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('Belum ada ulasan',
                          style: TextStyle(color: muted, fontSize: 13)),
                    )
                  else
                    ..._reviews.map((r) => _reviewItem(r, border, muted, text)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: card, border: Border(top: BorderSide(color: border))),
        child: ElevatedButton(
          onPressed: _addingFav ? null : _addFavorite,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _addingFav
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('❤️ Simpan ke Favorit',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
        ),
      ),
    );
  }

  Widget _gradientPlaceholder() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.coral, AppColors.coral.withValues(alpha: 0.5)],
          ),
        ),
        child: Center(
            child: Icon(Icons.home_work_rounded,
                size: 80, color: Colors.white.withValues(alpha: 0.5))),
      );

  Widget _reviewItem(dynamic r, Color border, Color muted, Color textColor) {
    final rating = (r['rating'] ?? 0) as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg2Light.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.coral,
            child: Text(r['user_initials'] ?? 'U',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(r['user_name'] ?? 'Pengguna',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
                Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 13,
                              color:
                                  i < rating ? AppColors.yellow : muted,
                            ))),
              ])),
          Text(r['created_at'] ?? '-',
              style: TextStyle(fontSize: 10, color: muted)),
        ]),
        const SizedBox(height: 8),
        Text('"${r['komentar'] ?? ''}"',
            style: TextStyle(
                fontSize: 12, color: muted, fontStyle: FontStyle.italic)),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final bool isDark;
  final Color card, border, text, muted;

  const _InfoCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.isDark,
      required this.card,
      required this.border,
      required this.text,
      required this.muted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border)),
      child: Row(children: [
        Icon(icon, size: 24, color: AppColors.teal),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title, style: TextStyle(fontSize: 12, color: muted)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ])),
      ]),
    );
  }
}
