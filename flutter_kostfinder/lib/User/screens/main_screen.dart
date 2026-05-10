import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'kost/kost_screen.dart';
import 'favorite/favorite_screen.dart';
import 'review/review_screen.dart';
import 'prediksi/prediksi_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    KostScreen(),
    ReviewScreen(),
    FavoriteScreen(),
    PrediksiScreen(),
  ];

  static const _leftTabs = [
    _Tab(icon: Icons.grid_view_rounded, label: 'Beranda', screenIdx: 0),
    _Tab(icon: Icons.home_work_rounded, label: 'Kost', screenIdx: 1),
  ];

  static const _rightTabs = [
    _Tab(icon: Icons.favorite_rounded, label: 'Favorit', screenIdx: 3),
    _Tab(icon: Icons.auto_graph_rounded, label: 'Prediksi', screenIdx: 4),
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
            Icon(tab.icon, size: 22, color: active ? AppColors.coral : muted),
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
  const _Tab({required this.icon, required this.label, required this.screenIdx});
}