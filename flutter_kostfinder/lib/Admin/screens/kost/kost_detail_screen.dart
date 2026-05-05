import 'package:flutter/material.dart';
import '../../models/kost.dart';
import '../../models/review.dart';
import '../../services/api_service.dart';

class KostDetailScreen extends StatefulWidget {
  final String kostId;
  const KostDetailScreen({super.key, required this.kostId});

  @override
  State<KostDetailScreen> createState() => _KostDetailScreenState();
}

class _KostDetailScreenState extends State<KostDetailScreen> {
  Kost? _kost;
  List<Review> _reviews = [];
  bool _loading = true;
  bool _isFavorite = false;
  String? _favoriteId;
  Map<String, dynamic>? _session;

  final _komentarCtrl = TextEditingController();
  int _rating = 5;
  bool _submittingReview = false;
  bool _togglingFav = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    _session = await ApiService.getSession();
    await Future.wait([_loadKost(), _loadReviews(), _loadFavorites()]);
    setState(() => _loading = false);
  }

  Future<void> _loadKost() async {
    try {
      final res = await ApiService.getKostDetail(widget.kostId);
      if (res['success'] == true) {
        _kost = Kost.fromJson(res['data']);
      }
    } catch (_) {}
  }

  Future<void> _loadReviews() async {
    try {
      final raw = await ApiService.getReviews();
      _reviews = raw
          .map((e) => Review.fromJson(e))
          .where((r) => r.kostId == widget.kostId)
          .toList();
    } catch (_) {}
  }

  Future<void> _loadFavorites() async {
    try {
      final raw = await ApiService.getFavorites();
      for (final e in raw) {
        if (e['kost_id']?.toString() == widget.kostId) {
          _isFavorite = true;
          _favoriteId = e['id']?.toString();
          break;
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (_session == null || _session!['id']!.isEmpty) {
      _showSnack('Silakan login terlebih dahulu');
      return;
    }
    setState(() => _togglingFav = true);
    try {
      if (_isFavorite && _favoriteId != null) {
        await ApiService.deleteFavorite(_favoriteId!);
        setState(() {
          _isFavorite = false;
          _favoriteId = null;
        });
        _showSnack('Dihapus dari favorit');
      } else {
        final res = await ApiService.addFavorite(
          userId: _session!['id']!,
          kostId: widget.kostId,
        );
        if (res['success'] == true) {
          setState(() {
            _isFavorite = true;
            _favoriteId = res['data']['id']?.toString();
          });
          _showSnack('Ditambahkan ke favorit! ❤️');
        }
      }
    } catch (e) {
      _showSnack('Gagal: $e');
    }
    setState(() => _togglingFav = false);
  }

  Future<void> _submitReview() async {
    if (_session == null || _session!['id']!.isEmpty) {
      _showSnack('Silakan login terlebih dahulu');
      return;
    }
    if (_komentarCtrl.text.trim().isEmpty) {
      _showSnack('Komentar tidak boleh kosong');
      return;
    }
    setState(() => _submittingReview = true);
    try {
      final res = await ApiService.createReview(
        userId: _session!['id']!,
        kostId: widget.kostId,
        rating: _rating,
        komentar: _komentarCtrl.text.trim(),
      );
      if (res['success'] == true) {
        _komentarCtrl.clear();
        setState(() => _rating = 5);
        _showSnack('Review berhasil dikirim! ⭐');
        await _loadReviews();
        setState(() {});
      } else {
        _showSnack(res['message'] ?? 'Gagal mengirim review');
      }
    } catch (e) {
      _showSnack('Gagal: $e');
    }
    setState(() => _submittingReview = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82))));
    }
    if (_kost == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Kost tidak ditemukan')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildFasilitasCard(),
                  const SizedBox(height: 16),
                  _buildReviewSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF4CAF82),
      foregroundColor: Colors.white,
      actions: [
        _togglingFav
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
            : IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white),
                onPressed: _toggleFavorite,
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF82), Color(0xFF2D8A5F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: Icon(Icons.home_work, color: Colors.white38, size: 90)),
        ),
        title: Text(_kost!.namaKost,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_kost!.namaKost,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_on, size: 16, color: Color(0xFF4CAF82)),
          const SizedBox(width: 4),
          Expanded(child: Text(_kost!.alamat, style: TextStyle(color: Colors.grey[600]))),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF82).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Harga/bulan', style: TextStyle(color: Colors.grey)),
            Text('Rp ${_formatHarga(_kost!.harga)}',
                style: const TextStyle(
                    color: Color(0xFF4CAF82), fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFasilitasCard() {
    final items = [
      {'label': 'WiFi', 'value': _kost!.wifi, 'icon': Icons.wifi},
      {'label': 'Listrik', 'value': _kost!.listrik, 'icon': Icons.bolt},
      {'label': 'AC', 'value': _kost!.pendinginRuangan, 'icon': Icons.ac_unit},
      {'label': 'Kamar Mandi', 'value': _kost!.kamarMandi, 'icon': Icons.bathtub_outlined},
      {'label': 'Parkir', 'value': _kost!.parkirMotor, 'icon': Icons.two_wheeler},
      {'label': 'Ukuran', 'value': _kost!.ukuranKamar, 'icon': Icons.square_foot},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Fasilitas & Info',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(_kost!.fasilitas, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: items.map((item) {
            final ada = item['value'].toString().toLowerCase() == 'ada';
            return Container(
              decoration: BoxDecoration(
                color: ada ? const Color(0xFF4CAF82).withOpacity(0.08) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: ada
                        ? const Color(0xFF4CAF82).withOpacity(0.3)
                        : Colors.grey.shade200),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(item['icon'] as IconData,
                    color: ada ? const Color(0xFF4CAF82) : Colors.grey, size: 22),
                const SizedBox(height: 4),
                Text(item['label'] as String,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                Text(item['value'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        color: ada ? const Color(0xFF4CAF82) : Colors.grey)),
              ]),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _buildReviewSection() {
    final avg = _reviews.isEmpty
        ? 0.0
        : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Ulasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_reviews.isNotEmpty) ...[
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(avg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(' (${_reviews.length})',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ]),
        const SizedBox(height: 16),
        const Text('Tulis Ulasan', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Rating: '),
          ...List.generate(
              5,
              (i) => GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Icon(i < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 30),
                  )),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _komentarCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Bagikan pengalamanmu di kost ini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4CAF82)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _submittingReview ? null : _submitReview,
            icon: _submittingReview
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send, size: 18),
            label: const Text('Kirim Ulasan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF82),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        if (_reviews.isNotEmpty) ...[
          const Divider(height: 28),
          ..._reviews.map((r) => _buildReviewItem(r)),
        ] else ...[
          const SizedBox(height: 12),
          Center(
            child: Text('Belum ada ulasan. Jadilah yang pertama!',
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ),
        ],
      ]),
    );
  }

  Widget _buildReviewItem(Review r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4CAF82).withOpacity(0.2),
              child: const Icon(Icons.person, size: 18, color: Color(0xFF4CAF82)),
            ),
            const SizedBox(width: 8),
            Text('User', style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Row(
                children: List.generate(
                    5,
                    (i) => Icon(i < r.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 14))),
          ]),
          const SizedBox(height: 6),
          Text(r.komentar, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: _togglingFav
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82)))
              : OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : const Color(0xFF4CAF82)),
                  label: Text(
                      _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                      style: TextStyle(
                          color: _isFavorite ? Colors.red : const Color(0xFF4CAF82),
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isFavorite ? Colors.red : const Color(0xFF4CAF82)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
        ),
      ),
    );
  }

  String _formatHarga(double harga) {
    return harga.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
