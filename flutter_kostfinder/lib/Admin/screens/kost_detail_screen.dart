import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/api_service.dart';
import '../../utils/helpers.dart';
import 'kost_screen.dart';

class KostDetailScreen extends StatefulWidget {
  final KostData kost;

  const KostDetailScreen({super.key, required this.kost});

  @override
  State<KostDetailScreen> createState() => _KostDetailScreenState();
}

class _KostDetailScreenState extends State<KostDetailScreen> {
  bool _isFav = false;
  bool _favLoading = false;

  static const _kodLokasiMap = {
    1: 'Dekat Kampus', 2: 'Pusat Kota', 3: 'Pinggir Kota',
    4: 'Dekat Transportasi Umum', 5: 'Perumahan', 6: 'Dekat Pasar / Mall',
    7: 'Kawasan Industri', 8: 'Pinggir Jalan Utama', 9: 'Pedesaan / Wisata', 10: 'Lainnya',
  };

  String _kodLokasiLabel(int kode, String apiLabel) {
    if (apiLabel.isNotEmpty) return apiLabel;
    return _kodLokasiMap[kode] ?? 'Kode $kode';
  }

  Future<void> _toggleFavorite() async {
    setState(() => _favLoading = true);
    try {
      final session = await ApiService.getSession();
      final userId = session?['user']?['id']?.toString() ?? session?['id']?.toString() ?? '';
      if (userId.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu')));
        return;
      }
      await ApiService.addFavorite(userId: userId, kostId: widget.kost.id);
      if (mounted) {
        setState(() => _isFav = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❤️ ${widget.kost.name} ditambahkan ke favorit'),
          backgroundColor: AppColors.teal,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menambahkan ke favorit: $e'),
          backgroundColor: AppColors.coral,
        ));
      }
    } finally {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kost = widget.kost;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final text = isDark ? AppColors.textDark : AppColors.textLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.teal,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (kost.foto != null)
                    Image.network(kost.foto!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [AppColors.teal, AppColors.teal.withValues(alpha: 0.5)],
                          ),
                        ),
                        child: Center(child: Icon(kost.iconData, size: 80, color: Colors.white.withValues(alpha: 0.5))),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [AppColors.teal, AppColors.teal.withValues(alpha: 0.5)],
                        ),
                      ),
                      child: Center(child: Icon(kost.iconData, size: 80, color: Colors.white.withValues(alpha: 0.5))),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _isFav ? AppColors.coral : Colors.white),
                onPressed: _favLoading ? null : _toggleFavorite,
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
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(kost.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: text)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.location_on_rounded, size: 14, color: muted),
                            const SizedBox(width: 4),
                            Expanded(child: Text(kost.location, style: TextStyle(fontSize: 14, color: muted))),
                          ]),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.tealBg, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.yellow),
                          const SizedBox(width: 4),
                          Text(kost.rating, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal)),
                          Text(' (${kost.reviews})', style: const TextStyle(fontSize: 12, color: AppColors.teal)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Row(children: [
                    Text(kost.price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.coral)),
                    Text(' / bulan', style: TextStyle(fontSize: 14, color: muted)),
                  ]),
                  const SizedBox(height: 24),

                  // Info Cards Row 1: Tipe + Kelas
                  Row(children: [
                    Expanded(child: _InfoCard(icon: Icons.person_rounded, title: 'Tipe', value: kost.type, isDark: isDark, card: card, border: border, text: text, muted: muted)),
                    const SizedBox(width: 12),
                    Expanded(child: _InfoCard(icon: Icons.meeting_room_rounded, title: 'Kelas', value: kost.roomClass, isDark: isDark, card: card, border: border, text: text, muted: muted)),
                  ]),
                  const SizedBox(height: 12),

                  // Info Cards Row 2: Status + Luas Kamar
                  Row(children: [
                    Expanded(child: _InfoCard(icon: Icons.check_circle_rounded, title: 'Status', value: kost.status, isDark: isDark, card: card, border: border, text: text, muted: muted)),
                    const SizedBox(width: 12),
                    Expanded(child: _InfoCard(icon: Icons.square_foot_rounded, title: 'Luas Kamar', value: '${kost.luasKamar.toStringAsFixed(0)} m²', isDark: isDark, card: card, border: border, text: text, muted: muted)),
                  ]),
                  const SizedBox(height: 12),

                  // Info Cards Row 3: Wilayah + Kode Lokasi
                  Row(children: [
                    Expanded(child: _InfoCard(icon: Icons.location_city_rounded, title: 'Wilayah', value: kost.wilayahNama.isNotEmpty ? kost.wilayahNama : '-', isDark: isDark, card: card, border: border, text: text, muted: muted)),
                    const SizedBox(width: 12),
                    Expanded(child: _InfoCard(icon: Icons.pin_drop_rounded, title: 'Kode Lokasi', value: _kodLokasiLabel(kost.kodeLokasi, kost.lokasiLabel), isDark: isDark, card: card, border: border, text: text, muted: muted)),
                  ]),
                  const SizedBox(height: 24),

                  // Deskripsi
                  if (kost.description.isNotEmpty) ...[
                    Text('Deskripsi Kost', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
                    const SizedBox(height: 8),
                    Text(kost.description, style: TextStyle(fontSize: 14, color: muted, height: 1.5)),
                    const SizedBox(height: 24),
                  ],

                  // Fasilitas
                  Text('Fasilitas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: kost.facilities.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border),
                      ),
                      child: Text(f, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: text)),
                    )).toList(),
                  ),
                  if (kost.facilities.isEmpty)
                    Text('Tidak ada fasilitas tercatat', style: TextStyle(fontSize: 13, color: muted)),
                  const SizedBox(height: 24),

                  // Kontak Pemilik
                  Text('Kontak Pemilik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(color: AppColors.tealBg, shape: BoxShape.circle),
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.teal),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Pemilik Kost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text)),
                          const SizedBox(height: 4),
                          Text(kost.ownerNumber, style: TextStyle(fontSize: 14, color: muted)),
                        ]),
                      ),
                      IconButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await Helpers.launchWhatsApp(
                            kost.ownerNumber,
                            'Halo, saya tertarik dengan kost ${kost.name}. Apakah masih tersedia?',
                          );
                          if (!ok) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Gagal membuka WhatsApp')),
                            );
                          }
                        },
                        icon: const Icon(Icons.phone_rounded, color: AppColors.teal),
                        style: IconButton.styleFrom(backgroundColor: AppColors.tealBg),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: card, border: Border(top: BorderSide(color: border))),
        child: ElevatedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final ok = await Helpers.launchWhatsApp(
              kost.ownerNumber,
              'Halo, saya tertarik dengan kost ${kost.name}. Apakah masih tersedia?',
            );
            if (!ok) {
              messenger.showSnackBar(
                const SnackBar(content: Text('Gagal membuka WhatsApp')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Hubungi Pemilik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final bool isDark;
  final Color card, border, text, muted;

  const _InfoCard({required this.icon, required this.title, required this.value, required this.isDark, required this.card, required this.border, required this.text, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Row(children: [
        Icon(icon, size: 24, color: AppColors.teal),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}
