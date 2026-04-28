import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'kost_screen.dart';
import 'review_screen.dart';
import 'favorite_screen.dart';
import 'user_screen.dart';
import 'prediction_screen.dart';
import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final session = await ApiService.getSession();
    if (session != null) {
      final user = session['user'] ?? session;
      if (user['role'] == 'admin') {
        if (mounted) setState(() => _isAdmin = true);
      }
    }
  }

  final _screens = const [
    DashboardScreen(),
    KostScreen(),
    ReviewScreen(),
    FavoriteScreen(),
    PredictionScreen(),
    UserScreen(),
  ];

  static const _leftTabs = [
    _Tab(icon: Icons.grid_view_rounded, label: 'Beranda', screenIdx: 0),
    _Tab(icon: Icons.home_work_rounded, label: 'Kost', screenIdx: 1, badge: '6'),
  ];
  List<_Tab> get _rightTabs => [
    const _Tab(icon: Icons.favorite_rounded, label: 'Favorit', screenIdx: 3),
    if (_isAdmin) const _Tab(icon: Icons.people_rounded, label: 'Pengguna', screenIdx: 5, badge: '12'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(isDark, card, border, muted),
    );
  }

  Widget _buildBottomBar(bool isDark, Color card, Color border, Color muted) {
    return Container(
      color: card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, thickness: 1, color: border),
          SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ..._leftTabs.map((t) => _buildItem(t, muted)),
                  _buildReviewItem(muted),
                  ..._rightTabs.map((t) => _buildItem(t, muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Color muted) {
    final active = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.coralBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_rounded, size: 22, color: active ? AppColors.coral : muted),
            const SizedBox(height: 2),
            Text('Review', style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.coral : muted, height: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(_Tab tab, Color muted) {
    final active = _currentIndex == tab.screenIdx;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = tab.screenIdx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.coralBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(clipBehavior: Clip.none, children: [
              Icon(tab.icon, size: 22, color: active ? AppColors.coral : muted),
              if (tab.badge != null)
                Positioned(
                  top: -4, right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: active ? AppColors.coral : muted, borderRadius: BorderRadius.circular(100)),
                    child: Text(tab.badge!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
            ]),
            const SizedBox(height: 2),
            Text(tab.label, style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.coral : muted, height: 1.0)),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final String label;
  final int screenIdx;
  final String? badge;
  const _Tab({required this.icon, required this.label, required this.screenIdx, this.badge});
}
