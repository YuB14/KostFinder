import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/kost_model.dart';
import '../../models/review_model.dart';
import '../../services/kost_service.dart';
import '../../services/favorite_service.dart';
import '../../utils/helpers.dart';
import '../../Admin/theme/app_theme.dart';

class KostScreen extends StatefulWidget {
  const KostScreen({super.key});
  @override
  State<KostScreen> createState() => _KostScreenState();
}

class _KostScreenState extends State<KostScreen> {
  List<KostModel> _all = [];
  List<KostModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  int? _filterKelas;   // null=semua, 1=Ekonomi, 2=Standar, 3=Premium
  int? _filterTipe;    // null=semua, 1=Pria, 2=Wanita, 3=Campur

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _all = await KostService.getKosts();
    _filter();
    if (mounted) setState(() => _loading = false);
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((k) {
        final okKelas = _filterKelas == null || k.kelas == _filterKelas;
        final okTipe  = _filterTipe  == null || k.tipeKos == _filterTipe;
        final okQ = q.isEmpty ||
            k.namaKost.toLowerCase().contains(q) ||
            k.alamatKost.toLowerCase().contains(q) ||
            (k.wilayahNama ?? '').toLowerCase().contains(q) ||
            k.kelasLabelDisplay.toLowerCase().contains(q);
        return okKelas && okTipe && okQ;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Cari Kost'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari nama, alamat, wilayah...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: AppColors.bgLight,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        // ── Filter chips ────────────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [..._kelasChips(), const SizedBox(width: 8), ..._tipeChips()],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Text('${_filtered.length} kost ditemukan',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedLight)),
          ]),
        ),
        // ── Grid ────────────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.coral,
                  child: _filtered.isEmpty
                      ? const Center(child: Text('Tidak ada kost ditemukan'))
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.70,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _KostCard(
                            kost: _filtered[i],
                            onTap: () => _showDetail(_filtered[i]),
                          ),
                        ),
                ),
        ),
      ]),
    );
  }

  // ── Filter chip builders ──────────────────────────────────────────────

  List<Widget> _kelasChips() {
    const opts = <int?>[null, 1, 2, 3];
    const labels = ['Semua Kelas', 'Ekonomi', 'Standar', 'Premium'];
    return List.generate(opts.length, (i) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(labels[i], style: const TextStyle(fontSize: 12)),
        selected: _filterKelas == opts[i],
        onSelected: (_) { setState(() => _filterKelas = opts[i]); _filter(); },
        selectedColor: AppColors.coralBg,
        checkmarkColor: AppColors.coral,
        labelStyle: TextStyle(
          color: _filterKelas == opts[i] ? AppColors.coral : AppColors.mutedLight,
        ),
      ),
    ));
  }

  List<Widget> _tipeChips() {
    const opts = <int?>[null, 1, 2, 3];
    const labels = ['Semua Tipe', 'Pria', 'Wanita', 'Campur'];
    return List.generate(opts.length, (i) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(labels[i], style: const TextStyle(fontSize: 12)),
        selected: _filterTipe == opts[i],
        onSelected: (_) { setState(() => _filterTipe = opts[i]); _filter(); },
        selectedColor: AppColors.tealBg,
        checkmarkColor: AppColors.teal,
        labelStyle: TextStyle(
          color: _filterTipe == opts[i] ? AppColors.teal : AppColors.mutedLight,
        ),
      ),
    ));
  }

  void _showDetail(KostModel k) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _KostDetailSheet(kost: k),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Kost Card
// ══════════════════════════════════════════════════════════════════════════════

class _KostCard extends StatelessWidget {
  final KostModel kost;
  final VoidCallback onTap;
  const _KostCard({required this.kost, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final k = kost;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Foto + badge kelas ──────────────────────────────────
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: k.fotoKost != null
                  ? CachedNetworkImage(
                      imageUrl: k.fotoKost!,
                      height: 110, width: double.infinity, fit: BoxFit.cover,
                      placeholder: (_, __) => _imgPlaceholder(110),
                      errorWidget: (_, __, ___) => _imgPlaceholder(110),
                    )
                  : _imgPlaceholder(110),
            ),
            Positioned(
              top: 8, left: 8,
              child: _KelasChip(kelas: k.kelas, label: k.kelasLabelDisplay),
            ),
            // Badge status
            Positioned(
              top: 8, right: 8,
              child: _StatusDot(status: k.status),
            ),
          ]),
          // ── Info ────────────────────────────────────────────────
          Expanded(child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k.namaKost,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('📍 ${k.alamatKost}',
                style: const TextStyle(fontSize: 10, color: AppColors.mutedLight),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              if (k.wilayahNama != null) ...[
                const SizedBox(height: 1),
                Text('🏙️ ${k.wilayahNama}',
                  style: const TextStyle(fontSize: 10, color: AppColors.mutedLight),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
              const Spacer(),
              Text(Helpers.formatRupiah(k.hargaKost),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.coral)),
              Text('/bulan', style: const TextStyle(fontSize: 10, color: AppColors.mutedLight)),
              const SizedBox(height: 4),
              Row(children: [
                Text(Helpers.renderStars(k.avgRating),
                  style: const TextStyle(color: AppColors.yellow, fontSize: 11)),
                const SizedBox(width: 4),
                Text('(${k.reviewsCount})',
                  style: const TextStyle(fontSize: 10, color: AppColors.mutedLight)),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _imgPlaceholder(double h) => Container(
    height: h, width: double.infinity, color: AppColors.bg2Light,
    child: const Icon(Icons.home_rounded, color: AppColors.mutedLight, size: 32),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Kelas Badge Chip
// ══════════════════════════════════════════════════════════════════════════════

class _KelasChip extends StatelessWidget {
  final int kelas;
  final String label;
  const _KelasChip({required this.kelas, required this.label});

  @override
  Widget build(BuildContext context) {
    Color c;
    Color bg;
    switch (kelas) {
      case 2: c = AppColors.blue;   bg = AppColors.blueBg;   break;
      case 3: c = AppColors.yellow; bg = AppColors.yellowBg; break;
      default: c = AppColors.coral; bg = AppColors.coralBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Status Dot
// ══════════════════════════════════════════════════════════════════════════════

class _StatusDot extends StatelessWidget {
  final int status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c = status == 0
        ? const Color(0xFFE53E3E)
        : status == 1 ? AppColors.teal : AppColors.yellow;
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Kost Detail Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════

class _KostDetailSheet extends StatefulWidget {
  final KostModel kost;
  const _KostDetailSheet({required this.kost});
  @override
  State<_KostDetailSheet> createState() => _KostDetailSheetState();
}

class _KostDetailSheetState extends State<_KostDetailSheet> {
  List<ReviewModel> _reviews = [];
  bool _loadingReviews = true;
  bool _addingFav = false;

  @override
  void initState() { super.initState(); _loadReviews(); }

  Future<void> _loadReviews() async {
    final r = await KostService.getKostReviews(widget.kost.id);
    if (mounted) setState(() { _reviews = r; _loadingReviews = false; });
  }

  Future<void> _addFav() async {
    setState(() => _addingFav = true);
    final r = await FavoriteService.addFavorite(widget.kost.id);
    if (!mounted) return;
    setState(() => _addingFav = false);
    final msg = r['status'] == 409
        ? 'Sudah ada di favorit ⚠️'
        : r['success'] == true ? 'Berhasil ditambahkan ke favorit! ❤️'
        : r['message'] ?? 'Gagal menambahkan';
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kost;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            children: [
              // Foto
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: k.fotoKost != null
                    ? CachedNetworkImage(imageUrl: k.fotoKost!, height: 200, width: double.infinity, fit: BoxFit.cover)
                    : Container(height: 200, color: AppColors.bg2Light,
                        child: const Icon(Icons.home_rounded, size: 60, color: AppColors.mutedLight)),
              ),
              const SizedBox(height: 16),

              // Nama + Kelas badge
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(k.namaKost,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textLight)),
                  const SizedBox(height: 4),
                  Text('📍 ${k.alamatKost}',
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedLight)),
                ])),
                _KelasChip(kelas: k.kelas, label: k.kelasLabelDisplay),
              ]),
              const SizedBox(height: 14),

              // Harga + Rating
              Row(children: [
                Expanded(child: _infoBox('Harga/Bulan', Helpers.formatRupiah(k.hargaKost), AppColors.coral)),
                const SizedBox(width: 10),
                Expanded(child: _infoBox('Rating',
                  '${Helpers.renderStars(k.avgRating)} ${k.avgRating.toStringAsFixed(1)}',
                  AppColors.yellow)),
              ]),
              const SizedBox(height: 10),

              // Info grid
              _sectionTitle('Informasi Kost'),
              const SizedBox(height: 8),
              _infoGrid([
                _InfoItem('Tipe Kost', _tipeIcon(k.tipeKos) + ' ' + k.tipeKosLabelDisplay),
                _InfoItem('Status', _statusIcon(k.status) + ' ' + k.statusLabelDisplay),
                _InfoItem('Kelas', k.kelasLabelDisplay),
                _InfoItem('Luas Kamar', k.luasKamar > 0 ? '${k.luasKamar.toStringAsFixed(0)} m²' : '-'),
                _InfoItem('Kode Lokasi', k.kodeLokasLabelDisplay),
                _InfoItem('Wilayah', k.wilayahNama ?? '-'),
              ]),
              const SizedBox(height: 14),

              // Fasilitas
              _sectionTitle('Fasilitas'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _FasBadge(label: '⚡ Listrik', active: k.listrik == 1),
                  _FasBadge(label: '❄️ AC', active: k.ac == 1),
                  _FasBadge(label: '🚿 KM Dalam', active: k.kamarMandiDalam == 1),
                  _FasBadge(label: '🏍️ Parkir Motor', active: k.parkirMotor == 1),
                  _FasBadge(label: '👕 Laundry', active: k.laundry == 1),
                  _FasBadge(label: '📶 WiFi', active: k.wifi == 1),
                ],
              ),
              const SizedBox(height: 14),

              // Nomor Telepon
              if (k.nomorTelepon != null && k.nomorTelepon!.isNotEmpty) ...[
                _sectionTitle('No. Telepon Pemilik'),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.phone_rounded, size: 16, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Text(k.nomorTelepon!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 14),
              ],

              // Deskripsi
              if (k.deskripsi != null && k.deskripsi!.isNotEmpty) ...[
                _sectionTitle('Deskripsi'),
                const SizedBox(height: 6),
                Text(k.deskripsi!,
                  style: const TextStyle(fontSize: 13, color: AppColors.text2Light, height: 1.6)),
                const SizedBox(height: 14),
              ],

              const Divider(),
              const SizedBox(height: 10),

              // Reviews
              const Text('⭐ Ulasan Pengguna',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (_loadingReviews)
                const Center(child: CircularProgressIndicator(color: AppColors.coral))
              else if (_reviews.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
                  child: const Text('💭 Belum ada ulasan untuk kost ini',
                    style: TextStyle(color: AppColors.mutedLight, fontSize: 12)),
                )
              else
                ..._reviews.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 14, backgroundColor: AppColors.coral,
                        child: Text(r.userInitials,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.userName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(Helpers.renderStars(r.rating),
                          style: const TextStyle(color: AppColors.yellow, fontSize: 12)),
                      ])),
                      Text(r.createdAt,
                        style: const TextStyle(fontSize: 10, color: AppColors.mutedLight)),
                    ]),
                    const SizedBox(height: 8),
                    Text('"${r.komentar}"',
                      style: const TextStyle(fontSize: 12, color: AppColors.text2Light)),
                  ]),
                )),
            ],
          )),

          // Bottom actions
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: _addingFav ? null : _addFav,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _addingFav
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('❤️ Simpan Favorit', style: TextStyle(fontWeight: FontWeight.w700)),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  String _tipeIcon(int tipe) {
    switch (tipe) { case 1: return '👨'; case 2: return '👩'; default: return '👥'; }
  }
  String _statusIcon(int status) {
    if (status == 0) return '🔴';
    if (status == 1) return '✅';
    return '🛏️';
  }

  Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mutedLight));

  Widget _infoBox(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedLight, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
    ]),
  );

  Widget _infoGrid(List<_InfoItem> items) => GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3.2,
    children: items.map((item) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.label, style: const TextStyle(fontSize: 10, color: AppColors.mutedLight)),
          Text(item.value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
    )).toList(),
  );
}

class _InfoItem {
  final String label, value;
  const _InfoItem(this.label, this.value);
}

// ══════════════════════════════════════════════════════════════════════════════
// Fasilitas Badge (aktif/tidak)
// ══════════════════════════════════════════════════════════════════════════════

class _FasBadge extends StatelessWidget {
  final String label;
  final bool active;
  const _FasBadge({required this.label, required this.active});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: active ? AppColors.tealBg : AppColors.bg2Light,
      border: Border.all(color: active ? AppColors.teal : AppColors.borderLight),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: active ? AppColors.teal : AppColors.mutedLight,
      )),
  );
}