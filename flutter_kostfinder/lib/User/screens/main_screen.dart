import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
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
    FavoriteScreen(),
    ReviewScreen(),
    PrediksiScreen(),
  ];

  static const _tabs = [
    _Tab(icon: Icons.grid_view_rounded, label: 'Beranda', idx: 0),
    _Tab(icon: Icons.home_work_rounded, label: 'Kost', idx: 1),
    _Tab(icon: Icons.favorite_rounded, label: 'Favorit', idx: 2),
    _Tab(icon: Icons.rate_review_rounded, label: 'Ulasan', idx: 3),
    _Tab(icon: Icons.auto_graph_rounded, label: 'Prediksi', idx: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
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
                  children: _tabs.map((tab) {
                    final active = _currentIndex == tab.idx;
                    return GestureDetector(
                      onTap: () => setState(() => _currentIndex = tab.idx),
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
                            Text(tab.label, style: TextStyle(
                              fontSize: 9,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? AppColors.coral : muted,
                              height: 1.0,
                            )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final String label;
  final int idx;
  const _Tab({required this.icon, required this.label, required this.idx});
}