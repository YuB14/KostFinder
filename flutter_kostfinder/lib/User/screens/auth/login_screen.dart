import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailCtrl = TextEditingController();
  final _loginPwCtrl = TextEditingController();
  bool _pwVisible = false;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() => _error = ''));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginEmailCtrl.text.isEmpty || _loginPwCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }
    setState(() { _isLoading = true; _error = ''; });
    try {
      final res = await ApiService.login(_loginEmailCtrl.text.trim(), _loginPwCtrl.text);
      if (!mounted) return;
      if (res['success'] == true) {
        await ApiService.saveSession(res['user']);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        setState(() => _error = res['message'] ?? 'Login gagal');
      }
    } catch (e) {
      setState(() => _error = 'Koneksi gagal: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.coral, AppColors.coral2]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              RichText(text: TextSpan(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
                children: const [
                  TextSpan(text: 'Kost'),
                  TextSpan(text: 'Finder', style: TextStyle(color: AppColors.coral)),
                ],
              )),
            ]),
            const SizedBox(height: 8),
            Text('Platform Kost Terpercaya', style: TextStyle(color: muted, fontSize: 13)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: textColor,
                unselectedLabelColor: muted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Masuk'), Tab(text: 'Daftar')],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20)],
              ),
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLoginForm(isDark, muted, textColor), _buildRegisterTab(isDark, muted, textColor)],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isDark, Color muted, Color textColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Selamat Datang 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
      const SizedBox(height: 4),
      Text('Masuk untuk menemukan kost impianmu', style: TextStyle(color: muted, fontSize: 13)),
      const SizedBox(height: 20),
      _buildTextField(_loginEmailCtrl, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress, isDark: isDark),
      const SizedBox(height: 12),
      _buildTextField(_loginPwCtrl, 'Password', Icons.lock_outline, isPassword: true, isDark: isDark),
      if (_error.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFE53E3E).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Text(_error, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
        ),
      ],
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Masuk Sekarang →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    ]);
  }

  Widget _buildRegisterTab(bool isDark, Color muted, Color textColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Buat Akun Gratis ✨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
      const SizedBox(height: 4),
      Text('Bergabung dengan ribuan pencari kost', style: TextStyle(color: muted, fontSize: 13)),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: const Text('Daftar Sekarang →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    ]);
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false, TextInputType? keyboardType, required bool isDark}) {
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return TextField(
      controller: ctrl,
      obscureText: isPassword && !_pwVisible,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: isDark ? AppColors.textDark : AppColors.textLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: muted),
        prefixIcon: Icon(icon, color: muted, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_pwVisible ? Icons.visibility_off : Icons.visibility, size: 20, color: muted),
                onPressed: () => setState(() => _pwVisible = !_pwVisible),
              )
            : null,
      ),
    );
  }
}