import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';

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
  int? _filterKelas;  // null=semua, 1=Ekonomi, 2=Standar, 3=Premium
  int? _filterTipe;   // null=semua, 1=Pria, 2=Wanita, 3=Campur

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
        final tipeInt  = _toInt(k['tipe_kos'], 3);
        final nama   = (k['nama_kost'] ?? '').toString().toLowerCase();
        final alamat = (k['alamat_kost'] ?? '').toString().toLowerCase();
        final wilayah = (k['wilayah_nama'] ?? '').toString().toLowerCase();
        final matchKelas = _filterKelas == null || kelasInt == _filterKelas;
        final matchTipe  = _filterTipe  == null || tipeInt  == _filterTipe;
        final matchSearch = q.isEmpty || nama.contains(q) || alamat.contains(q) || wilayah.contains(q);
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
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.coral,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.coral, AppColors.coral2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Cari Kost', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('Temukan kost impianmu', style: TextStyle(fontSize: 11, color: Colors.white70)),
                        ]),
                      ]),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontSize: 13, color: AppColors.textLight),
                        decoration: InputDecoration(
                          hintText: 'Cari nama, alamat, fasilitas...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedLight),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedLight, size: 18),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              title: const Text('Cari Kost', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Column(children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ..._buildKelasChips(),
                    const SizedBox(width: 8),
                    ..._buildTipeChips(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Row(children: [
                  Text('${_filtered.length} kost ditemukan', style: TextStyle(fontSize: 12, color: muted)),
                ]),
              ),
            ]),
          ),

          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.coral)))
          else if (_filtered.isEmpty)
            SliverFillRemaining(child: Center(child: Text('Tidak ada kost ditemukan', style: TextStyle(color: muted))))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _KostCard(
                    kost: _filtered[i],
                    isDark: isDark, card: card, border: border, muted: muted, textColor: textColor,
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

  List<Widget> _buildKelasChips() {
    final opts = <int?>[null, 1, 2, 3];
    const labels = ['Semua Kelas', 'Ekonomi', 'Standar', 'Premium'];
    return List.generate(opts.length, (i) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(labels[i], style: const TextStyle(fontSize: 12)),
        selected: _filterKelas == opts[i],
        onSelected: (_) => setState(() { _filterKelas = opts[i]; _applyFilter(); }),
        selectedColor: AppColors.coralBg,
        checkmarkColor: AppColors.coral,
        labelStyle: TextStyle(color: _filterKelas == opts[i] ? AppColors.coral : AppColors.mutedLight),
      ),
    ));
  }

  List<Widget> _buildTipeChips() {
    final opts = <int?>[null, 1, 2, 3];
    const labels = ['Semua Tipe', 'Pria', 'Wanita', 'Campur'];
    return List.generate(opts.length, (i) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(labels[i], style: const TextStyle(fontSize: 12)),
        selected: _filterTipe == opts[i],
        onSelected: (_) => setState(() { _filterTipe = opts[i]; _applyFilter(); }),
        selectedColor: AppColors.tealBg,
        checkmarkColor: AppColors.teal,
        labelStyle: TextStyle(color: _filterTipe == opts[i] ? AppColors.teal : AppColors.mutedLight),
      ),
    ));
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

  const _KostCard({required this.kost, required this.isDark, required this.card, required this.border, required this.muted, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foto = kost['foto_kost'] ?? kost['foto'];
    final fotoUrl = foto != null ? ApiService.getImageUrl(foto.toString()) : null;
    final kelasInt = _KostScreenState._toInt(kost['kelas'], 1);
    final kelasStr = kost['kelas_label']?.toString() ?? (kelasInt == 1 ? 'Ekonomi' : kelasInt == 2 ? 'Standar' : 'Premium');
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
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
            Positioned(top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kelasColor.withOpacity(0.15),
                  border: Border.all(color: kelasColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(kelasStr, style: TextStyle(color: kelasColor, fontSize: 10, fontWeight: FontWeight.w700)),
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
                Text('📍 ${kost['alamat_kost'] ?? '-'}',
                    style: TextStyle(fontSize: 10, color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (wilayahNama != null)
                  Text('🏙️ $wilayahNama',
                      style: TextStyle(fontSize: 10, color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _placeholder() => Container(height: 110, color: AppColors.bg2Light, child: const Icon(Icons.home_rounded, color: AppColors.mutedLight, size: 32));
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
      _reviews = all.where((r) => r['kost_id']?.toString() == kostId && r['status'] == 'Disetujui').toList();
    } catch (_) {}
    if (mounted) setState(() => _loadingReviews = false);
  }

  Future<void> _addFavorite() async {
    setState(() => _addingFav = true);
    try {
      final session = await ApiService.getSession();
      final userId = session?['user']?['id']?.toString() ?? session?['id']?.toString() ?? '';
      final res = await ApiService.addFavorite(userId: userId, kostId: widget.kost['id']?.toString() ?? '');
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['success'] == true ? '❤️ Berhasil ditambahkan ke favorit!' : res['message'] ?? 'Gagal'),
        backgroundColor: res['success'] == true ? AppColors.teal : const Color(0xFFE53E3E),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
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
    // Fasilitas dari field binary (0/1)
    final fasilitasList = <String>[];
    if (_KostScreenState._toInt(k['listrik'], 1) == 1) fasilitasList.add('⚡ Listrik');
    if (_KostScreenState._toInt(k['ac'], 0) == 1) fasilitasList.add('❄️ AC');
    if (_KostScreenState._toInt(k['kamar_mandi_dalam'], 0) == 1) fasilitasList.add('🚿 KM Dalam');
    if (_KostScreenState._toInt(k['parkir_motor'], 0) == 1) fasilitasList.add('🏍️ Parkir Motor');
    if (_KostScreenState._toInt(k['laundry'], 0) == 1) fasilitasList.add('👕 Laundry');
    if (_KostScreenState._toInt(k['wifi'], 0) == 1) fasilitasList.add('📶 WiFi');
    // Info tambahan
    final kelasInt = _KostScreenState._toInt(k['kelas'], 1);
    final kelasStr = k['kelas_label']?.toString() ?? (kelasInt == 1 ? 'Ekonomi' : kelasInt == 2 ? 'Standar' : 'Premium');
    final tipeInt = _KostScreenState._toInt(k['tipe_kos'], 3);
    final tipeStr = k['tipe_kos_label']?.toString() ?? (tipeInt == 1 ? 'Pria' : tipeInt == 2 ? 'Wanita' : 'Campur');
    final statusInt = _KostScreenState._toInt(k['status'], 1);
    final statusStr = k['status_label']?.toString() ?? (statusInt == 0 ? 'Penuh' : statusInt == 1 ? 'Tersedia' : '$statusInt Kamar Sisa');
    final luasKamar = (k['luas_kamar'] ?? 0).toString();
    final wilayahNama = k['wilayah_nama']?.toString() ?? '-';
    final kodeLokStr = k['lokasi_label']?.toString() ?? '';
    final deskripsi = k['deskripsi']?.toString() ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(color: card, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
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
                Text(k['nama_kost'] ?? '-', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 4),
                Text('📍 ${k['alamat_kost'] ?? '-'}', style: TextStyle(fontSize: 13, color: muted)),
                if (wilayahNama != '-') Text('🏙️ $wilayahNama', style: TextStyle(fontSize: 12, color: muted)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _infoBox('Harga/Bulan', Helpers.formatRupiah(k['harga_kost'] ?? 0), AppColors.coral, isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoBox('Rating', '${k['avg_rating'] ?? 0} ⭐', AppColors.yellow, isDark)),
                ]),
                const SizedBox(height: 10),
                // Info grid
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _chipInfo('Kelas', kelasStr, isDark, border, muted, textColor),
                  _chipInfo('Tipe', tipeStr, isDark, border, muted, textColor),
                  _chipInfo('Status', statusStr, isDark, border, muted, textColor),
                  if (luasKamar != '0' && luasKamar != '0.0')
                    _chipInfo('Luas', '$luasKamar m²', isDark, border, muted, textColor),
                  if (kodeLokStr.isNotEmpty)
                    _chipInfo('Lokasi', kodeLokStr, isDark, border, muted, textColor),
                ]),
                // Fasilitas
                const SizedBox(height: 14),
                Text('Fasilitas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    _fasBadge('⚡ Listrik', _KostScreenState._toInt(k['listrik'], 1) == 1, isDark, border),
                    _fasBadge('❄️ AC', _KostScreenState._toInt(k['ac'], 0) == 1, isDark, border),
                    _fasBadge('🚿 KM Dalam', _KostScreenState._toInt(k['kamar_mandi_dalam'], 0) == 1, isDark, border),
                    _fasBadge('🏍️ Parkir', _KostScreenState._toInt(k['parkir_motor'], 0) == 1, isDark, border),
                    _fasBadge('👕 Laundry', _KostScreenState._toInt(k['laundry'], 0) == 1, isDark, border),
                    _fasBadge('📶 WiFi', _KostScreenState._toInt(k['wifi'], 0) == 1, isDark, border),
                  ],
                ),
                // Deskripsi
                if (deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Deskripsi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: muted)),
                  const SizedBox(height: 6),
                  Text(deskripsi, style: TextStyle(fontSize: 13, color: muted, height: 1.5)),
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
                        decoration: BoxDecoration(color: AppColors.tealBg, shape: BoxShape.circle),
                        child: const Icon(Icons.phone_rounded, color: AppColors.teal, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(k['nomor_telepon'].toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    ]),
                  ),
                ],
                const SizedBox(height: 16),
                Divider(color: border),
                const SizedBox(height: 8),
                Text('⭐ Ulasan Pengguna', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 10),
                if (_loadingReviews)
                  const Center(child: CircularProgressIndicator(color: AppColors.coral))
                else if (_reviews.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: isDark ? AppColors.bg2Dark : AppColors.bg2Light, borderRadius: BorderRadius.circular(10)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addingFav ? null : _addFavorite,
                  child: _addingFav
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('❤️ Simpan Favorit', style: TextStyle(fontWeight: FontWeight.w700)),
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
      decoration: BoxDecoration(color: isDark ? AppColors.bg2Dark : AppColors.bg2Light, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppColors.mutedDark : AppColors.mutedLight, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _chipInfo(String label, String value, bool isDark, Color border, Color muted, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: muted)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
      ]),
    );
  }

  Widget _fasBadge(String label, bool active, bool isDark, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.tealBg : (isDark ? AppColors.bg2Dark : AppColors.bg2Light),
        border: Border.all(color: active ? AppColors.teal : border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: active ? AppColors.teal : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
      )),
    );
  }

  Widget _reviewItem(dynamic r, Color border, Color muted, Color textColor) {
    final rating = (r['rating'] ?? 0) as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2Light.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.coral,
            child: Text(r['user_initials'] ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r['user_name'] ?? 'Pengguna', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
            Row(children: List.generate(5, (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 12, color: i < rating ? AppColors.yellow : muted,
            ))),
          ])),
          Text(r['created_at'] ?? '-', style: TextStyle(fontSize: 10, color: muted)),
        ]),
        const SizedBox(height: 8),
        Text('"${r['komentar'] ?? ''}"', style: TextStyle(fontSize: 12, color: muted, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _bigPlaceholder() => Container(height: 200, color: AppColors.bg2Light, child: const Icon(Icons.home_rounded, color: AppColors.mutedLight, size: 60));
}