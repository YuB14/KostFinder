import 'package:flutter/material.dart';
import '../../../widgets/shared_widgets.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../auth/login_screen.dart';
import '../../theme/theme_notifier.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _scrolled = false;
  final _scrollCtrl = ScrollController();
  String _userName = '';
  String _userEmail = '';
  String? _userPhotoUrl;
  int _totalFav = 0, _totalReview = 0, _totalKost = 0;
  List<dynamic> _recentFavs = [];
  List<dynamic> _myReviews = [];
  List<dynamic> _popularKosts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollCtrl.addListener(() {
      final isScrolled = _scrollCtrl.offset > 60;
      if (isScrolled != _scrolled) setState(() => _scrolled = isScrolled);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = await ApiService.getSession();
      if (session != null) {
        final u = session['user'] ?? session;
        _userName = u['name'] ?? 'Pengguna';
        _userEmail = u['email'] ?? '';
        final photo = u['profile_picture'];
        if (photo != null) _userPhotoUrl = ApiService.getImageUrl(photo.toString());
      }
      final results = await Future.wait([
        ApiService.getFavorites(),
        ApiService.getReviews(),
        ApiService.getKosts(),
      ]);
      final favs = results[0] as List;
      final reviews = results[1] as List;
      final kosts = results[2] as List;
      final session2 = await ApiService.getSession();
      final userId = session2?['user']?['id']?.toString() ?? session2?['id']?.toString() ?? '';
      final myReviews = reviews.where((r) => r['user_id']?.toString() == userId).toList();
      _totalFav = favs.length;
      _totalReview = myReviews.length;
      _totalKost = kosts.length;
      _recentFavs = favs.take(3).toList();
      _myReviews = myReviews.take(3).toList();
      _popularKosts = kosts.take(4).toList();
    } catch (e) {
      debugPrint('Dashboard error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.coral,
        child: CustomScrollView(
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
              Text('KostFinder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(6)),
                child: const Text('User', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.coral)),
              ),
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
              IconButton(
                icon: Icon(Icons.logout_rounded, color: muted, size: 20),
                onPressed: _logout,
              ),
              const SizedBox(width: 4),
            ],
          ),

                        if (_isLoading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.coral)))
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(children: [
                      Expanded(child: StatCard(icon: Icons.favorite_rounded, value: _totalFav.toString(), label: 'Favorit', accentColor: AppColors.coral, accentBg: AppColors.coralBg)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(icon: Icons.star_rounded, value: _totalReview.toString(), label: 'Ulasan Saya', accentColor: AppColors.yellow, accentBg: AppColors.yellowBg)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(icon: Icons.home_work_rounded, value: _totalKost.toString(), label: 'Total Kost', accentColor: AppColors.teal, accentBg: AppColors.tealBg)),
                    ]),
                    const SizedBox(height: 24),
                    _sectionTitle('Favorit Terbaru', textColor),
                    const SizedBox(height: 10),
                    if (_recentFavs.isEmpty)
                      _emptyBox('Belum ada favorit', card, border, muted)
                    else
                      ..._recentFavs.map((f) => _favRow(f, card, border, muted, textColor)),
                    const SizedBox(height: 24),
                    _sectionTitle('Ulasan Saya Terbaru', textColor),
                    const SizedBox(height: 10),
                    if (_myReviews.isEmpty)
                      _emptyBox('Belum ada ulasan', card, border, muted)
                    else
                      ..._myReviews.map((r) => _reviewRow(r, card, border, muted, textColor)),
                    const SizedBox(height: 24),
                    _sectionTitle('Kost Tersedia', textColor),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
                      ),
                      itemCount: _popularKosts.length,
                      itemBuilder: (_, i) => _miniKostCard(_popularKosts[i], card, border, muted, textColor),
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

  Widget _sectionTitle(String title, Color textColor) =>
      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor));

  Widget _emptyBox(String msg, Color card, Color border, Color muted) =>
      Container(
        padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Text(msg, style: TextStyle(color: muted, fontSize: 13)),
      );

  Widget _favRow(dynamic f, Color card, Color border, Color muted, Color textColor) {
    final foto = f['kost_foto'] ?? f['foto'];
    final fotoUrl = foto != null ? ApiService.getImageUrl(foto.toString()) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.contains('default'))
              ? Image.network(fotoUrl, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _iconBox())
              : _iconBox(),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f['kost_nama'] ?? '-', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(f['kost_alamat'] ?? '-', style: TextStyle(fontSize: 11, color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Text(Helpers.formatRupiah(f['kost_harga'] ?? 0),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.coral)),
      ]),
    );
  }

  Widget _reviewRow(dynamic r, Color card, Color border, Color muted, Color textColor) {
    final rating = (r['rating'] ?? 0) as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(r['kost_name'] ?? '-', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 13, color: i < rating ? AppColors.yellow : muted))),
        ]),
        const SizedBox(height: 4),
        Text('"${r['komentar'] ?? ''}"', style: TextStyle(fontSize: 12, color: muted), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _miniKostCard(dynamic k, Color card, Color border, Color muted, Color textColor) {
    final foto = k['foto_kost'] ?? k['foto'];
    final fotoUrl = foto != null ? ApiService.getImageUrl(foto.toString()) : null;
    return Container(
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: (fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.contains('default'))
              ? Image.network(fotoUrl, height: 90, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _photoPlaceholder())
              : _photoPlaceholder(),
        ),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k['nama_kost'] ?? '-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(k['alamat_kost'] ?? '-', style: TextStyle(fontSize: 10, color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(Helpers.formatRupiah(k['harga_kost'] ?? 0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.coral)),
        ])),
      ]),
    );
  }

  Widget _iconBox() => Container(width: 44, height: 44, color: AppColors.bg2Light, child: const Icon(Icons.home_rounded, color: AppColors.mutedLight, size: 20));
  Widget _photoPlaceholder() => Container(height: 90, color: AppColors.bg2Light, child: const Icon(Icons.home_rounded, color: AppColors.mutedLight, size: 32));
}