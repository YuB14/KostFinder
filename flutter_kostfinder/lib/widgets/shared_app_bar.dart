import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart' show themeNotifier;
import '../Admin/services/api_service.dart';
import 'package:provider/provider.dart';
import '../User/providers/auth_provider.dart';

// ─── SharedAppBar ─────────────────────────────────────────────────────────────

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function(BuildContext)? onNotificationPressed;
  /// Optional role override. If null, auto-detects from session.
  final String? roleOverride;

  const SharedAppBar({super.key, this.onNotificationPressed, this.roleOverride});

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
        automaticallyImplyLeading: false,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: ApiService.getSession(),
          builder: (context, snap) {
            String roleBadge = roleOverride ?? 'User';
            if (roleOverride == null && snap.hasData && snap.data != null) {
              final user = snap.data!['user'] ?? snap.data!;
              final role = user['role']?.toString() ?? 'user';
              roleBadge = role == 'admin' ? 'Admin' : 'User';
            }
            final bool isAdmin = roleBadge == 'Admin';
            final Color badgeColor = isAdmin ? AppColors.coral : AppColors.teal;
            final Color badgeBg = isAdmin ? AppColors.coralBg : AppColors.tealBg;

            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: badgeColor,
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
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    roleBadge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            );
          },
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
                  icon: Stack(
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 20, color: mutedColor),
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (onNotificationPressed != null) {
                      onNotificationPressed!(btnContext);
                    } else {
                      _showNotificationPanel(context, isDark);
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

  static void _showNotificationPanel(BuildContext context, bool isDark) {
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    final notifications = [
      {'icon': Icons.login_rounded, 'color': AppColors.teal, 'title': 'Login berhasil', 'desc': 'Anda telah masuk sebagai Admin', 'time': 'Baru saja'},
      {'icon': Icons.person_add_rounded, 'color': AppColors.coral, 'title': 'Pengguna baru terdaftar', 'desc': 'Sistem registrasi aktif', 'time': '1 jam lalu'},
      {'icon': Icons.rate_review_rounded, 'color': AppColors.yellow, 'title': 'Ulasan baru masuk', 'desc': 'Periksa di menu Review', 'time': '3 jam lalu'},
      {'icon': Icons.home_work_rounded, 'color': AppColors.teal, 'title': 'Kost ditambahkan', 'desc': 'Listing baru tersedia', 'time': 'Kemarin'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
        decoration: BoxDecoration(color: isDark ? AppColors.bgDark : AppColors.bgLight, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Icon(Icons.notifications_rounded, color: AppColors.coral, size: 22),
              const SizedBox(width: 8),
              Text('Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(12)),
                child: Text('${notifications.length} baru', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.coral)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: (n['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n['title'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
                      const SizedBox(height: 2),
                      Text(n['desc'] as String, style: TextStyle(fontSize: 11, color: muted)),
                    ])),
                    Text(n['time'] as String, style: TextStyle(fontSize: 10, color: muted)),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}