import 'package:flutter/material.dart';
import '../Admin/theme/app_theme.dart';
import '../main.dart' show themeNotifier;
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../User/providers/auth_provider.dart';

// ─── SharedAppBar ─────────────────────────────────────────────────────────────

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function(BuildContext)? onNotificationPressed;

  const SharedAppBar({super.key, this.onNotificationPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

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
              child: const Icon(
                Icons.home_work_rounded,
                color: AppColors.coral,
                size: 18,
              ),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Notification Button
              Builder(
                builder: (btnContext) => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(Icons.notifications_none_rounded, size: 20, color: mutedColor),
                  onPressed: () {
                    if (onNotificationPressed != null) {
                      onNotificationPressed!(btnContext);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Belum ada notifikasi baru'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 4),

              // 2. Theme Mode Toggle
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) {
                  final isDarkMode = mode == ThemeMode.dark ||
                      (mode == ThemeMode.system &&
                          WidgetsBinding.instance.platformDispatcher
                                  .platformBrightness ==
                              Brightness.dark);
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: child.key == const ValueKey('dark') 
                            ? Tween<double>(begin: 1, end: 0).animate(anim) 
                            : Tween<double>(begin: 0.75, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        key: ValueKey(isDarkMode ? 'dark' : 'light'),
                        size: 20,
                        color: mutedColor,
                      ),
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
          
          // 3. Profile Dropdown
          FutureBuilder<Map<String, dynamic>?>(
            future: ApiService.getSession(),
            builder: (context, snapshot) {
              String userName = 'Admin';
              String userEmail = 'admin@example.com';
              if (snapshot.hasData && snapshot.data != null) {
                final user = snapshot.data!['user'] ?? snapshot.data!;
                userName = user['name'] ?? userName;
                userEmail = user['email'] ?? userEmail;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 45),
                  color: bgColor,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.coralBg,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                          style: const TextStyle(fontSize: 12, color: AppColors.coral, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: mutedColor),
                    ],
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(userEmail, style: TextStyle(fontSize: 11, color: mutedColor)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'logout') {
                      if (!context.mounted) return;
                      // logout() hapus session + notifyListeners() → AuthWrapper rebuild ke LoginScreen
                      await context.read<AuthProvider>().logout();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}