import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../../widgets/shared_app_bar.dart';
import 'user_kost_detail_screen.dart';

class KostScreen extends StatefulWidget {
  const KostScreen({super.key});

  @override
  State<KostScreen> createState() => _KostScreenState();
}

class _KostScreenState extends State<KostScreen> {
  List<dynamic> _allKosts = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  int? _filterKelas; // null=semua, 1=Ekonomi, 2=Standar, 3=Premium
  int? _filterTipe; // null=semua, 1=Pria, 2=Wanita, 3=Campur

  @override
  void initState() {
    super.initState();
    _loadKosts();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadKosts() async {
    setState(() => _loading = true);
    try {
      _allKosts = await ApiService.getKosts();
      _applyFilter();
    } catch (e) {
      debugPrint('Kost error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allKosts.where((k) {
        final kelasInt = _toInt(k['kelas'], 1);
        final tipeInt = _toInt(k['tipe_kos'], 3);
        final nama = (k['nama_kost'] ?? '').toString().toLowerCase();
        final alamat = (k['alamat_kost'] ?? '').toString().toLowerCase();
        final wilayah = (k['wilayah_nama'] ?? '').toString().toLowerCase();
        final matchKelas = _filterKelas == null || kelasInt == _filterKelas;
        final matchTipe = _filterTipe == null || tipeInt == _filterTipe;
        final matchSearch = q.isEmpty ||
            nama.contains(q) ||
            alamat.contains(q) ||
            wilayah.contains(q);
        return matchKelas && matchTipe && matchSearch;
      }).toList();
    });
  }

  static int _toInt(dynamic v, int fb) {
    if (v == null) return fb;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fb;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Scaffold(
      appBar: const SharedAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.coral))
          : RefreshIndicator(
              onRefresh: _loadKosts,
              color: AppColors.coral,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Header ──
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: 'Cari ',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textColor),
                      ),
                      const TextSpan(
                        text: 'Kost',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.coral,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  Text('Temukan kost impianmu',
                      style: TextStyle(fontSize: 13, color: muted)),
                  const SizedBox(height: 16),

                  // ── Search Bar ──
                  TextField(
                    controller: _searchCtrl,
                    style: TextStyle(fontSize: 13, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, alamat, wilayah...',
                      hintStyle: TextStyle(fontSize: 13, color: muted),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: muted, size: 20),
                      filled: true,
                      fillColor: card,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.coral)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Filters ──
                  Row(
                    children: [
                      // Kelas filter dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: _filterKelas,
                              isExpanded: true,
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down_rounded,
                                  size: 20, color: muted),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor),
                              dropdownColor: card,
                              hint: Text('Semua Kelas',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: muted)),
                              onChanged: (v) => setState(() {
                                _filterKelas = v;
                                _applyFilter();
                              }),
                              items: const [
                                DropdownMenuItem(
                                    value: null,
                                    child: Text('📋 Semua Kelas')),
                                DropdownMenuItem(
                                    value: 1, child: Text('💚 Ekonomi')),
                                DropdownMenuItem(
                                    value: 2, child: Text('🔵 Standar')),
                                DropdownMenuItem(
                                    value: 3, child: Text('⭐ Premium')),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tipe filter dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: _filterTipe,
                              isExpanded: true,
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down_rounded,
                                  size: 20, color: muted),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor),
                              dropdownColor: card,
                              hint: Text('Semua Tipe',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: muted)),
                              onChanged: (v) => setState(() {
                                _filterTipe = v;
                                _applyFilter();
                              }),
                              items: const [
                                DropdownMenuItem(
                                    value: null,
                                    child: Text('📋 Semua Tipe')),
                                DropdownMenuItem(
                                    value: 1, child: Text('👨 Pria')),
                                DropdownMenuItem(
                                    value: 2, child: Text('👩 Wanita')),
                                DropdownMenuItem(
                                    value: 3, child: Text('👥 Campur')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Result count
                  Text('${_filtered.length} kost ditemukan',
                      style: TextStyle(fontSize: 12, color: muted)),
                  const SizedBox(height: 12),

                  // ── Grid ──
                  if (_filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(children: [
                        const Text('🏠', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('Tidak ada kost ditemukan',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor)),
                        const SizedBox(height: 4),
                        Text('Coba ubah filter atau kata kunci',
                            style: TextStyle(fontSize: 12, color: muted)),
                      ]),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _KostCard(
                        kost: _filtered[i],
                        isDark: isDark,
                        card: card,
                        border: border,
                        muted: muted,
                        textColor: textColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserKostDetailScreen(
                                kost: _filtered[i]),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

// ── Kost Card ──────────────────────────────────────────────────────────────
class _KostCard extends StatelessWidget {
  final dynamic kost;
  final bool isDark;
  final Color card, border, muted, textColor;
  final VoidCallback onTap;

  const _KostCard(
      {required this.kost,
      required this.isDark,
      required this.card,
      required this.border,
      required this.muted,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foto = kost['foto_kost'] ?? kost['foto'];
    final fotoUrl =
        foto != null ? ApiService.getImageUrl(foto.toString()) : null;
    final kelasInt = _KostScreenState._toInt(kost['kelas'], 1);
    final kelasStr = kost['kelas_label']?.toString() ??
        (kelasInt == 1
            ? 'Ekonomi'
            : kelasInt == 2
                ? 'Standar'
                : 'Premium');
    final avgRating = (kost['avg_rating'] ?? 0).toDouble();
    final reviewsCount = kost['reviews_count'] ?? 0;
    final wilayahNama = kost['wilayah_nama']?.toString();

    Color kelasColor = AppColors.teal;
    if (kelasInt == 1) kelasColor = AppColors.coral;
    if (kelasInt == 3) kelasColor = AppColors.yellow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: (fotoUrl != null &&
                      fotoUrl.isNotEmpty &&
                      !fotoUrl.contains('default'))
                  ? Image.network(fotoUrl,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kelasColor.withValues(alpha: 0.15),
                  border:
                      Border.all(color: kelasColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(kelasStr,
                    style: TextStyle(
                        color: kelasColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kost['nama_kost'] ?? '-',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('📍 ${kost['alamat_kost'] ?? '-'}',
                        style: TextStyle(fontSize: 10, color: muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (wilayahNama != null)
                      Text('🏙️ $wilayahNama',
                          style: TextStyle(fontSize: 10, color: muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Text(Helpers.formatRupiah(kost['harga_kost'] ?? 0),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.coral)),
                    Text('/bulan',
                        style: TextStyle(fontSize: 10, color: muted)),
                    const SizedBox(height: 4),
                    Row(children: [
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < avgRating.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 11,
                                color: i < avgRating.floor()
                                    ? AppColors.yellow
                                    : muted,
                              )),
                      const SizedBox(width: 4),
                      Text('($reviewsCount)',
                          style: TextStyle(fontSize: 10, color: muted)),
                    ]),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
      height: 110,
      color: AppColors.bg2Light,
      child: const Icon(Icons.home_rounded,
          color: AppColors.mutedLight, size: 32));
}