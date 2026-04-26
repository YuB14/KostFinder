import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailCtrl = TextEditingController();
  final _loginPwCtrl = TextEditingController();
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPwCtrl = TextEditingController();
  bool _pwVisible = false;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginEmailCtrl.text.isEmpty || _loginPwCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }
    setState(() { _isLoading = true; _error = ''; });
    final result = await context.read<AuthProvider>().login(
      _loginEmailCtrl.text.trim(),
      _loginPwCtrl.text,
    );
    if (!mounted) return;
    if (result['success'] != true) {
      setState(() {
        _error = result['message'] ?? 'Login gagal';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8430D), Color(0xFFFF6B3D)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.home_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1A2A3A)),
                      children: [
                        TextSpan(text: 'Kost'),
                        TextSpan(text: 'Finder', style: TextStyle(color: Color(0xFFE8430D))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Platform Kost Terpercaya',
                style: TextStyle(color: Color(0xFF6B7E94), fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Tab
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEFF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: const Color(0xFF1A2A3A),
                  unselectedLabelColor: const Color(0xFF6B7E94),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  dividerColor: Colors.transparent,
                  tabs: const [Tab(text: 'Masuk'), Tab(text: 'Daftar')],
                ),
              ),
              const SizedBox(height: 24),

              // Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20)],
                ),
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  height: 380,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildLoginForm(), _buildRegisterForm()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selamat Datang 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Masuk untuk menemukan kost impianmu', style: TextStyle(color: Color(0xFF6B7E94), fontSize: 13)),
        const SizedBox(height: 20),
        _buildTextField(_loginEmailCtrl, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildTextField(_loginPwCtrl, 'Password', Icons.lock_outline, isPassword: true),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_error, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8430D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Masuk Sekarang →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buat Akun Gratis ✨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Bergabung dengan ribuan pencari kost', style: TextStyle(color: Color(0xFF6B7E94), fontSize: 13)),
        const SizedBox(height: 16),
        _buildTextField(_regNameCtrl, 'Nama Lengkap', Icons.person_outline),
        const SizedBox(height: 10),
        _buildTextField(_regEmailCtrl, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _buildTextField(_regPwCtrl, 'Password', Icons.lock_outline, isPassword: true),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur registrasi dalam pengembangan')),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8430D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buat Akun →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && !_pwVisible,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7E94)),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7E94), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_pwVisible ? Icons.visibility_off : Icons.visibility, size: 20, color: const Color(0xFF6B7E94)),
                onPressed: () => setState(() => _pwVisible = !_pwVisible),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8430D), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}