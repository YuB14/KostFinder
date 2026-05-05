import 'package:flutter/material.dart';
import '../Admin/theme/app_theme.dart';
import '../Admin/main.dart' show themeNotifier;

// ─── SharedAppBar ─────────────────────────────────────────────────────────────

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.coralBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_work_rounded,
                  color: AppColors.coral, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'KostFinder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.coralBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.coral,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) {
              final isDarkMode = mode == ThemeMode.dark ||
                  (mode == ThemeMode.system &&
                      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                          Brightness.dark);
              return IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 20,
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                ),
                onPressed: () {
                  themeNotifier.value =
                      isDarkMode ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
