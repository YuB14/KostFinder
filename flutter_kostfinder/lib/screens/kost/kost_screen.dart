import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/kost_model.dart';
import '../../models/review_model.dart';
import '../../services/kost_service.dart';
import '../../services/favorite_service.dart';
import '../../utils/helpers.dart';

class KostScreen extends StatefulWidget {
  const KostScreen({super.key});

  @override
  State<KostScreen> createState() => _KostScreenState();
}

class _KostScreenState extends State<KostScreen> {
  List<KostModel> _allKosts = [];
  List<KostModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _filterKelas = 'semua';
  String _filterJenis = 'semua';

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
    _allKosts = await KostService.getKosts();
    _applyFilter();
    if (mounted) setState(() => _loading = false);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allKosts.where((k) {
        final matchKelas = _filterKelas == 'semua' || k.kelas == _filterKelas;
        final matchJenis = _filterJenis == 'semua' || k.jenisKost == _filterJenis;
        final matchSearch = q.isEmpty ||
            k.namaKost.toLowerCase().contains(q) ||
            k.alamatKost.toLowerCase().contains(q) ||
            (k.fasilitas ?? '').toLowerCase().contains(q);
        return matchKelas && matchJenis && matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Cari Kost', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama, alamat, fasilitas...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7E94), size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._buildKelasChips(),
                const SizedBox(width: 8),
                ..._buildJenisChips(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text('${_filtered.length} kost ditemukan', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7E94))),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8430D)))
                : RefreshIndicator(
                    onRefresh: _loadKosts,
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Tidak ada kost ditemukan', style: TextStyle(color: Color(0xFF6B7E94))))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _KostCard(
                              kost: _filtered[i],
                              onTap: () => _showDetail(_filtered[i]),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKelasChips() {
    final opts = ['semua', 'Ekonomis', 'Standar', 'Premium'];
    return opts.map((o) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(o == 'semua' ? 'Semua Kelas' : o, style: const TextStyle(fontSize: 12)),
        selected: _filterKelas == o,
        onSelected: (_) { _filterKelas = o; _applyFilter(); },
        selectedColor: const Color(0xFFE8430D).withOpacity(0.1),
        checkmarkColor: const Color(0xFFE8430D),
        labelStyle: TextStyle(color: _filterKelas == o ? const Color(0xFFE8430D) : const Color(0xFF6B7E94)),
      ),
    )).toList();
  }

  List<Widget> _buildJenisChips() {
    final opts = ['semua', 'Pria', 'Wanita', 'Bebas'];
    return opts.map((o) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(o == 'semua' ? 'Semua Jenis' : o, style: const TextStyle(fontSize: 12)),
        selected: _filterJenis == o,
        onSelected: (_) { _filterJenis = o; _applyFilter(); },
        selectedColor: const Color(0xFF008F78).withOpacity(0.1),
        checkmarkColor: const Color(0xFF008F78),
        labelStyle: TextStyle(color: _filterJenis == o ? const Color(0xFF008F78) : const Color(0xFF6B7E94)),
      ),
    )).toList();
  }

  void _showDetail(KostModel kost) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KostDetailSheet(kost: kost),
    );
  }
}

class _KostCard extends StatelessWidget {
  final KostModel kost;
  final VoidCallback onTap;

  const _KostCard({required this.kost, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: kost.fotoKost != null
                      ? CachedNetworkImage(
                          imageUrl: kost.fotoKost!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(height: 110, color: const Color(0xFFEAEFF5)),
                          errorWidget: (_, __, ___) => Container(height: 110, color: const Color(0xFFEAEFF5), child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94))),
                        )
                      : Container(height: 110, color: const Color(0xFFEAEFF5), child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94), size: 32)),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kelasColor(kost.kelas),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(kost.kelas, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kost.namaKost, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('📍 ${kost.alamatKost}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Text(
                      Helpers.formatRupiah(kost.hargaKost),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFE8430D)),
                    ),
                    Text('/bulan', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(Helpers.renderStars(kost.avgRating), style: const TextStyle(color: Color(0xFFD48D00), fontSize: 11)),
                        const SizedBox(width: 4),
                        Text('(${kost.reviewsCount})', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _kelasColor(String kelas) {
    switch (kelas.toLowerCase()) {
      case 'ekonomis': return const Color(0xFFE8430D);
      case 'standar': return const Color(0xFF008F78);
      case 'premium': return const Color(0xFFD48D00);
      default: return const Color(0xFF2563EB);
    }
  }
}

// Detail Bottom Sheet
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
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await KostService.getKostReviews(widget.kost.id);
    if (mounted) setState(() { _reviews = reviews; _loadingReviews = false; });
  }

  Future<void> _addFavorite() async {
    setState(() => _addingFav = true);
    final result = await FavoriteService.addFavorite(widget.kost.id);
    if (!mounted) return;
    setState(() => _addingFav = false);
    String msg;
    if (result['status'] == 409) {
      msg = 'Sudah ada di favorit ⚠️';
    } else if (result['success'] == true) {
      msg = 'Berhasil ditambahkan ke favorit! ❤️';
    } else {
      msg = result['message'] ?? 'Gagal menambahkan';
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kost;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  // Foto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: k.fotoKost != null
                        ? CachedNetworkImage(imageUrl: k.fotoKost!, height: 200, width: double.infinity, fit: BoxFit.cover)
                        : Container(height: 200, color: const Color(0xFFEAEFF5), child: const Icon(Icons.home_rounded, size: 60, color: Color(0xFF6B7E94))),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.namaKost, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('📍 ${k.alamatKost}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7E94))),
                        ],
                      )),
                      _pilBadge(k.kelas),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _infoBox('Harga/Bulan', Helpers.formatRupiah(k.hargaKost), const Color(0xFFE8430D))),
                      const SizedBox(width: 10),
                      Expanded(child: _infoBox('Rating', '${Helpers.renderStars(k.avgRating)} ${k.avgRating.toStringAsFixed(1)}', const Color(0xFFD48D00))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (k.fasilitasList.isNotEmpty) ...[
                    const Text('Fasilitas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7E94))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: k.fasilitasList.map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF5F7FA), border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(100)),
                        child: Text(f, style: const TextStyle(fontSize: 11)),
                      )).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (k.nomorTelepon != null && k.nomorTelepon!.isNotEmpty) ...[
                    const Text('Telepon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7E94))),
                    const SizedBox(height: 4),
                    Text(k.nomorTelepon!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 14),
                  ],
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('⭐ Ulasan Pengguna', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (_loadingReviews)
                    const Center(child: CircularProgressIndicator(color: Color(0xFFE8430D)))
                  else if (_reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                      child: const Text('💭 Belum ada ulasan untuk kost ini', style: TextStyle(color: Color(0xFF6B7E94), fontSize: 12)),
                    )
                  else
                    ..._reviews.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFFE8430D),
                                child: Text(r.userInitials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.userName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  Text(Helpers.renderStars(r.rating), style: const TextStyle(color: Color(0xFFD48D00), fontSize: 12)),
                                ],
                              )),
                              Text(r.createdAt, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('"${r.komentar}"', style: const TextStyle(fontSize: 12, color: Color(0xFF3D5166))),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            // Bottom actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addingFav ? null : _addFavorite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8430D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _addingFav
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('❤️ Simpan Favorit', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pilBadge(String kelas) {
    Color c;
    switch (kelas.toLowerCase()) {
      case 'ekonomis': c = const Color(0xFFE8430D); break;
      case 'standar': c = const Color(0xFF008F78); break;
      case 'premium': c = const Color(0xFFD48D00); break;
      default: c = const Color(0xFF2563EB);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Text(kelas, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7E94), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}