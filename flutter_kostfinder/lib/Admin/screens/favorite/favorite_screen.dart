import 'package:flutter/material.dart';
import '../../models/kost.dart';
import '../../services/api_service.dart';
import '../kost/kost_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favKosts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final favs = await ApiService.getFavorites();
      final kosts = await ApiService.getKosts();

      final result = <Map<String, dynamic>>[];
      for (final fav in favs) {
        final kostData = kosts.firstWhere(
          (k) => k['id']?.toString() == fav['kost_id']?.toString(),
          orElse: () => null,
        );
        if (kostData != null) {
          result.add({'fav_id': fav['id']?.toString(), 'kost': Kost.fromJson(kostData)});
        }
      }
      setState(() => _favKosts = result);
    } catch (e) {
      _showSnack('Gagal memuat favorit: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _removeFavorite(String favId) async {
    await ApiService.deleteFavorite(favId);
    _showSnack('Dihapus dari favorit');
    _loadFavorites();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF82), Color(0xFF2D8A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.favorite, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text('Favorit Saya', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
                SizedBox(height: 4),
                Text('Kost yang kamu simpan', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82)))
                : _favKosts.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        color: const Color(0xFF4CAF82),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _favKosts.length,
                          itemBuilder: (_, i) => _buildFavCard(_favKosts[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavCard(Map<String, dynamic> item) {
    final Kost kost = item['kost'];
    final String favId = item['fav_id'];

    return Dismissible(
      key: Key(favId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeFavorite(favId),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KostDetailScreen(kostId: kost.id)),
        ).then((_) => _loadFavorites()),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF82).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_work, color: Color(0xFF4CAF82), size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kost.namaKost,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(kost.alamat,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${_formatHarga(kost.harga)}/bulan',
                      style: const TextStyle(color: Color(0xFF4CAF82), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _removeFavorite(favId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.favorite_outline, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Belum ada favorit', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        const SizedBox(height: 8),
        Text('Tap ❤️ di detail kost untuk menyimpan',
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ]),
    );
  }

  String _formatHarga(double harga) {
    return harga.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
