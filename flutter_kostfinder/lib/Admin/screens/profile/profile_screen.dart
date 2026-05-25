import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../../screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    _session = await ApiService.getSession();
    setState(() => _loading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.clearSession();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF82)));
    }

    final name = _session?['name'] ?? 'Guest';
    final email = _session?['email'] ?? '-';
    final role = _session?['role'] ?? 'user';
    final userId = _session?['id'] ?? '-';

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(children: [
          // ── Header gradient ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF82), Color(0xFF2D8A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role == 'admin' ? '👑 Admin' : '🙋 User',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              // ── Info card ──
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Akun',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 14),
                      _infoRow(Icons.badge_outlined, 'User ID', userId),
                      const Divider(height: 20),
                      _infoRow(Icons.person_outline, 'Nama', name),
                      const Divider(height: 20),
                      _infoRow(Icons.email_outlined, 'Email', email),
                      const Divider(height: 20),
                      _infoRow(Icons.admin_panel_settings_outlined, 'Role',
                          role == 'admin' ? 'Administrator' : 'User'),
                    ]),
              ),
              const SizedBox(height: 16),

              // ── Menu card ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
                  ],
                ),
                child: Column(children: [
                  _menuTile(Icons.info_outline, 'Tentang Aplikasi', onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'KostFinder',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 KostFinder',
                    );
                  }),
                  const Divider(height: 1, indent: 56),
                  _menuTile(Icons.logout, 'Logout',
                      color: Colors.red, onTap: _logout),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 20, color: const Color(0xFF4CAF82)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    ]);
  }

  Widget _menuTile(IconData icon, String title,
      {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF4CAF82)).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? const Color(0xFF4CAF82), size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: color ?? const Color(0xFF2D3748),
              fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
