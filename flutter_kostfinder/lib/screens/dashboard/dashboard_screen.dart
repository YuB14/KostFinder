import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../models/kost_model.dart';
import '../../models/favorite_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/kost_service.dart';
import '../../services/favorite_service.dart';
import '../../services/review_service.dart';
import '../../utils/helpers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalFav = 0, _totalReview = 0, _totalKost = 0;
  List<FavoriteModel> _favs = [];
  List<ReviewModel> _reviews = [];
  List<KostModel> _kosts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final cookie = await AuthService.getSavedCookie();
      final statsRes = await http.get(Uri.parse(ApiConfig.userStats), headers: ApiConfig.headers(cookie: cookie));
      if (statsRes.statusCode == 200) {
        final d = jsonDecode(statsRes.body)['data'];
        _totalFav = d['total_favorit'] ?? 0;
        _totalReview = d['total_review'] ?? 0;
        _totalKost = d['total_kost'] ?? 0;
      }

      final results = await Future.wait([
        FavoriteService.getFavorites(),
        ReviewService.getMyReviews(),
        KostService.getKosts(),
      ]);

      _favs = (results[0] as List<FavoriteModel>).take(3).toList();
      _reviews = (results[1] as List<ReviewModel>).take(3).toList();
      _kosts = (results[2] as List<KostModel>).take(4).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: const Color(0xFFE8430D),
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE8430D), Color(0xFFFF6B3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: Text(
                                  user?.initials ?? 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo, ${user?.name ?? ''}! 👋',
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                    const Text(
                                      'Selamat datang di KostFinder',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                                onPressed: () async {
                                  await context.read<AuthProvider>().logout();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFE8430D))))
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats
                    Row(
                      children: [
                        _statCard('❤️', _totalFav.toString(), 'Favorit', const Color(0xFFE8430D)),
                        const SizedBox(width: 12),
                        _statCard('⭐', _totalReview.toString(), 'Ulasan', const Color(0xFF008F78)),
                        const SizedBox(width: 12),
                        _statCard('🏘️', _totalKost.toString(), 'Kost', const Color(0xFFD48D00)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Favorit Terbaru
                    _sectionHeader('❤️ Favorit Terbaru', 'Lihat Semua'),
                    const SizedBox(height: 10),
                    if (_favs.isEmpty)
                      _emptyWidget('Belum ada favorit')
                    else
                      ..._favs.map((f) => _favListItem(f)),
                    const SizedBox(height: 20),

                    // Ulasan Terbaru
                    _sectionHeader('⭐ Ulasan Terbaru', 'Lihat Semua'),
                    const SizedBox(height: 10),
                    if (_reviews.isEmpty)
                      _emptyWidget('Belum ada ulasan')
                    else
                      ..._reviews.map((r) => _reviewListItem(r)),
                    const SizedBox(height: 20),

                    // Kost Populer
                    _sectionHeader('🏘️ Kost Populer', 'Lihat Semua'),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _kosts.length,
                      itemBuilder: (_, i) => _miniKostCard(_kosts[i]),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7E94))),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        TextButton(
          onPressed: () {},
          child: Text(action, style: const TextStyle(color: Color(0xFFE8430D), fontSize: 12)),
        ),
      ],
    );
  }

  Widget _emptyWidget(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(msg, style: const TextStyle(color: Color(0xFF6B7E94), fontSize: 13)),
    );
  }

  Widget _favListItem(FavoriteModel f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: f.kostFoto != null
                ? Image.network(f.kostFoto!, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _kostPlaceholder())
                : _kostPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.kostNama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('📍 ${f.kostAlamat}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7E94))),
              ],
            ),
          ),
          Text(
            Helpers.formatRupiah(f.kostHarga),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE8430D)),
          ),
        ],
      ),
    );
  }

  Widget _reviewListItem(ReviewModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.kostName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              Text(Helpers.renderStars(r.rating), style: const TextStyle(color: Color(0xFFD48D00), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text('"${r.komentar}"', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7E94)), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _miniKostCard(KostModel k) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: k.fotoKost != null
                ? Image.network(k.fotoKost!, height: 90, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _kostPlaceholderLg())
                : _kostPlaceholderLg(),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.namaKost, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('📍 ${k.alamatKost}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(Helpers.formatRupiah(k.hargaKost), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFE8430D))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kostPlaceholder() {
    return Container(
      width: 44, height: 44, color: const Color(0xFFEAEFF5),
      child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94), size: 20),
    );
  }

  Widget _kostPlaceholderLg() {
    return Container(
      height: 90, width: double.infinity, color: const Color(0xFFEAEFF5),
      child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94), size: 32),
    );
  }
}