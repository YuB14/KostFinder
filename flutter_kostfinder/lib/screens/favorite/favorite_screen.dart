import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/favorite_model.dart';
import '../../services/favorite_service.dart';
import '../../utils/helpers.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<FavoriteModel> _favs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavs();
  }

  Future<void> _loadFavs() async {
    setState(() => _loading = true);
    _favs = await FavoriteService.getFavorites();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _delete(FavoriteModel fav) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Favorit?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('"${fav.kostNama}" akan dihapus dari favorit.', style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFE53E3E))),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await FavoriteService.deleteFavorite(fav.id);
    if (ok && mounted) {
      setState(() => _favs.removeWhere((f) => f.id == fav.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💔 Dihapus dari favorit')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Favorit Saya ❤️', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${_favs.length} kost', style: const TextStyle(color: Color(0xFF6B7E94), fontSize: 12))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8430D)))
          : RefreshIndicator(
              onRefresh: _loadFavs,
              color: const Color(0xFFE8430D),
              child: _favs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💔', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 12),
                          const Text('Belum ada kost favorit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text('Mulai cari kost dan simpan yang kamu suka!', style: TextStyle(color: Color(0xFF6B7E94), fontSize: 13)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _favs.length,
                      itemBuilder: (_, i) => _FavCard(fav: _favs[i], onDelete: () => _delete(_favs[i])),
                    ),
            ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final FavoriteModel fav;
  final VoidCallback onDelete;
  const _FavCard({required this.fav, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: fav.kostFoto != null
                    ? CachedNetworkImage(
                        imageUrl: fav.kostFoto!,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(height: 110, color: const Color(0xFFEAEFF5), child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94))),
                      )
                    : Container(height: 110, color: const Color(0xFFEAEFF5), child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94), size: 32)),
              ),
              Positioned(
                top: 6, right: 6,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: const Icon(Icons.heart_broken_rounded, color: Color(0xFFE8430D), size: 16),
                  ),
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
                  Text(fav.kostNama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('📍 ${fav.kostAlamat}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text(Helpers.formatRupiah(fav.kostHarga), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFE8430D))),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: fav.kostStatus == 'Aktif' ? const Color(0xFF008F78).withOpacity(0.1) : const Color(0xFF6B7E94).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          fav.kostStatus,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fav.kostStatus == 'Aktif' ? const Color(0xFF008F78) : const Color(0xFF6B7E94)),
                        ),
                      ),
                      Text('❤️ ${fav.favCount}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}