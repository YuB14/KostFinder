import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../theme/theme_notifier.dart';

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
  final _scrollCtrl = ScrollController();
  bool _scrolled = false;
  String _filterKelas = 'Semua';
  String _filterJenis = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadKosts();
    _searchCtrl.addListener(_applyFilter);
    _scrollCtrl.addListener(() {
      final isScrolled = _scrollCtrl.offset > 60;
      if (isScrolled != _scrolled) setState(() => _scrolled = isScrolled);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
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
        final kelas = k['kelas'] ?? '';
        final jenis = k['jenis_kost'] ?? '';
        final nama = (k['nama_kost'] ?? '').toLowerCase();
        final alamat = (k['alamat_kost'] ?? '').toLowerCase();
        final fasilitas = (k['fasilitas'] ?? '').toLowerCase();
        final matchKelas = _filterKelas == 'Semua' || kelas == _filterKelas;
        final matchJenis = _filterJenis == 'Semua' || jenis == _filterJenis;
        final matchSearch = q.isEmpty || nama.contains(q) || alamat.contains(q) || fasilitas.contains(q);
        return matchKelas && matchJenis && matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: card,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.home_work_rounded, color: AppColors.coral, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Cari Kost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
            ]),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: border),
            ),
            actions: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) {
                  final isDarkMode = mode == ThemeMode.dark ||
                      (mode == ThemeMode.system &&
                          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
                  return IconButton(
                    icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20, color: muted),
                    onPressed: () => themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(fontSize: 13, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Cari nama, alamat, fasilitas...',
                  hintStyle: TextStyle(fontSize: 13, color: muted),
                  prefixIcon: Icon(Icons.search_rounded, color: muted, size: 18),
                  filled: true,
                  fillColor: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.coral)),
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Column(children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ..._buildChips(['Semua', 'Ekonomis', 'Standar', 'Premium'], _filterKelas,
                        (v) => setState(() { _filterKelas = v; _applyFilter(); }), AppColors.coral),
                    const SizedBox(width: 8),
                    ..._buildChips(['Semua', 'Pria', 'Wanita', 'Bebas'], _filterJenis,
                        (v) => setState(() { _filterJenis = v; _applyFilter(); }), AppColors.teal),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(children: [
                  Text('${_filtered.length} kost ditemukan',
                      style: TextStyle(fontSize: 12, color: muted)),
                ]),
              ),
            ]),
          ),

          if (_loading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.coral)))
          else if (_filtered.isEmpty)
            SliverFillRemaining(
                child: Center(
                    child: Text('Tidak ada kost ditemukan',
                        style: TextStyle(color: muted))))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _KostCard(
                    kost: _filtered[i],
                    isDark: isDark,
                    card: card,
                    border: border,
                    muted: muted,
                    textColor: textColor,
                    onTap: () => _showDetail(_filtered[i]),
                  ),
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildChips(
      List<String> opts, String selected, Function(String) onSelect, Color activeColor) {
    return opts.map((o) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(o, style: const TextStyle(fontSize: 12)),
        selected: selected == o,
        onSelected: (_) => onSelect(o),
        selectedColor: activeColor.withValues(alpha: 0.12),
        checkmarkColor: activeColor,
        labelStyle: TextStyle(color: selected == o ? activeColor : AppColors.mutedLight),
      ),
    )).toList();
  }

  void _showDetail(dynamic kost) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KostDetailSheet(kost: kost),
    );
  }
}

// ── Kost Card ──────────────────────────────────────────────────────────────
class _KostCard extends StatelessWidget {
  final dynamic kost;
  final bool isDark;
  final Color card, border, muted, textColor;
  final VoidCallback onTap;

  const _KostCard({
    required this.kost, required this.isDark,
    required this.card, required this.border,
    required this.muted, required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foto = kost['foto_kost'] ?? kost['foto'];
    final fotoUrl = foto != null ? ApiService.getImageUrl(foto.toString()) : null;
    final kelas = kost['kelas'] ?? '';
    final avgRating = (kost['avg_rating'] ?? 0).toDouble();
    final reviewsCount = kost['reviews_count'] ?? 0;

    Color kelasColor = AppColors.teal;
    if (kelas == 'Ekonomis') kelasColor = AppColors.coral;
    if (kelas == 'Premium') kelasColor = AppColors.yellow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: (fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.contains('default'))
                  ? Image.network(fotoUrl, height: 110, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            if (kelas.isNotEmpty)
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: kelasColor, borderRadius: BorderRadius.circular(100)),
                  child: Text(kelas,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(kost['nama_kost'] ?? '-',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on_rounded, size: 10, color: muted),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(kost['alamat_kost'] ?? '-',
                        style: TextStyle(fontSize: 10, color: muted),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const Spacer(),
                Text(Helpers.formatRupiah(kost['harga_kost'] ?? 0),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.coral)),
                Text('/bulan', style: TextStyle(fontSize: 10, color: muted)),
                const SizedBox(height: 4),
                Row(children: [
                  ...List.generate(5, (i) => Icon(
                    i < avgRating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 11, color: i < avgRating.floor() ? AppColors.yellow : muted,
                  )),
                  const SizedBox(width: 4),
                  Text('($reviewsCount)', style: TextStyle(fontSize: 10, color: muted)),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
      height: 110, color: AppColors.bg2Light,
      child: const Icon(Icons.home_rounded, color: AppColors.mutedLight, size: 32));
}

// ── Detail Bottom Sheet ────────────────────────────────────────────────────
class _KostDetailSheet extends StatefulWidget {
  final dynamic kost;
  const _KostDetailSheet({required this.kost});

  @override
  State<_KostDetailSheet> createState() => _KostDetailSheetState();
}

class _KostDetailSheetState extends State<_KostDetailSheet> {
  List<dynamic> _reviews = [];
  bool _loadingReviews = true;
  bool _addingFav = false;

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
          .where((r) => r['kost_id']?.toString() == kostId && r['status'] == 'Disetujui')
          .toList();
    } catch (_) {}
    if (mounted) setState(() => _loadingReviews = false);
  }

  Future<void> _addFavorite() async {
    setState(() => _addingFav = true);
    try {
      final session = await ApiService.getSession();
      final userId =
          session?['user']?['id']?.toString() ?? session?['id']?.toString() ?? '';
      final res = await ApiService.addFavorite(
          userId: userId, kostId: widget.kost['id']?.toString() ?? '');
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['success'] == true
            ? 'Berhasil ditambahkan ke favorit'
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final k = widget.kost;
    final foto = k['foto_kost'] ?? k['foto'];
    final fotoUrl = foto != null ? ApiService.getImageUrl(foto.toString()) : null;
    final fasilitas = (k['fasilitas'] ?? '') as String;
    final fasilitasList = fasilitas.isNotEmpty
        ? fasilitas.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList()
        : <String>[];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: (fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.contains('default'))
                      ? Image.network(fotoUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _bigPlaceholder())
                      : _bigPlaceholder(),
                ),
                const SizedBox(height: 16),
                Text(k['nama_kost'] ?? '-',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_rounded, size: 13, color: muted),
                  const SizedBox(width: 4),
                  Expanded(child: Text(k['alamat_kost'] ?? '-',
                      style: TextStyle(fontSize: 13, color: muted))),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _infoBox('Harga/Bulan',
                      Helpers.formatRupiah(k['harga_kost'] ?? 0), AppColors.coral, isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoBox('Rating',
                      '${k['avg_rating'] ?? 0} bintang', AppColors.yellow, isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoBox('Kelas', k['kelas'] ?? '-', AppColors.teal, isDark)),
                ]),
                if (fasilitasList.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Fasilitas',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: muted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: fasilitasList.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(f, style: TextStyle(fontSize: 11, color: textColor)),
                    )).toList(),
                  ),
                ],
                if ((k['nomor_telepon'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.tealBg, shape: BoxShape.circle),
                        child: const Icon(Icons.phone_rounded, color: AppColors.teal, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(k['nomor_telepon'].toString(),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    ]),
                  ),
                ],
                const SizedBox(height: 16),
                Divider(color: border),
                const SizedBox(height: 8),
                Text('Ulasan Pengguna',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 10),
                if (_loadingReviews)
                  const Center(child: CircularProgressIndicator(color: AppColors.coral))
                else if (_reviews.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('Belum ada ulasan', style: TextStyle(color: muted, fontSize: 12)),
                  )
                else
                  ..._reviews.map((r) => _reviewItem(r, border, muted, textColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: card,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addingFav ? null : _addFavorite,
                  child: _addingFav
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Favorit',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
          borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.mutedLight, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  Widget _reviewItem(dynamic r, Color border, Color muted, Color textColor) {
    final rating = (r['rating'] ?? 0) as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2Light.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.coral,
            child: Text(r['user_initials'] ?? 'U',
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r['user_name'] ?? 'Pengguna',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
            Row(children: List.generate(5, (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 12, color: i < rating ? AppColors.yellow : muted,
            ))),
          ])),
          Text(r['created_at'] ?? '-', style: TextStyle(fontSize: 10, color: muted)),
        ]),
        const SizedBox(height: 8),
        Text('"${r['komentar'] ?? ''}"',
            style: TextStyle(fontSize: 12, color: muted, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _bigPlaceholder() => Container(
      height: 200, color: AppColors.bg2Light,
      child: const Icon(Icons.home_rounded, color: AppColors.mutedLight, size: 60));
}