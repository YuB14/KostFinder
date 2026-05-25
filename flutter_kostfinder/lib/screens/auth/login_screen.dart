import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../User/providers/auth_provider.dart';
import '../../User/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPwCtrl = TextEditingController();
  bool _pwVisible = false;
  bool _isLoading = false;
  String _error = '';

  // Register controllers
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPwCtrl = TextEditingController();
  bool _regObscure = true;
  bool _regLoading = false;
  String _regError = '';
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {
      _error = '';
      _regError = '';
    }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPwCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginEmailCtrl.text.isEmpty || _loginPwCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }
    setState(() { _isLoading = true; _error = ''; });
    try {
      final result = await context.read<AuthProvider>().login(
        _loginEmailCtrl.text.trim(),
        _loginPwCtrl.text,
      );
      if (!mounted) return;
      if (result['success'] != true) {
        setState(() => _error = result['message'] ?? 'Login gagal');
      }
      // Jika berhasil: AuthProvider.notifyListeners() → AuthWrapper otomatis redirect
    } catch (e) {
      setState(() => _error = 'Koneksi gagal: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_regNameCtrl.text.isEmpty || _regEmailCtrl.text.isEmpty || _regPwCtrl.text.isEmpty) {
      setState(() => _regError = 'Semua field wajib diisi');
      return;
    }
    setState(() { _regLoading = true; _regError = ''; });
    try {
      final res = await ApiService.register(
        name: _regNameCtrl.text,
        email: _regEmailCtrl.text,
        password: _regPwCtrl.text,
        profilePictureBytes: _imageBytes,
        profilePictureName: _imageName,
      );
      if (!mounted) return;
      if (res['message'] == 'Register berhasil') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        // Reset form & pindah ke tab login
        _regNameCtrl.clear();
        _regEmailCtrl.clear();
        _regPwCtrl.clear();
        setState(() {
          _imageBytes = null;
          _imageName = null;
        });
        _tabController.animateTo(0);
      } else {
        final errors = res['errors'];
        String msg = res['message'] ?? 'Registrasi gagal';
        if (errors != null) msg = (errors as Map).values.expand((e) => e as List).join('\n');
        setState(() => _regError = msg);
      }
    } catch (e) {
      setState(() => _regError = 'Koneksi gagal: $e');
    }
    if (mounted) setState(() => _regLoading = false);
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
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IndexedStack(
                  index: _tabController.index,
                  children: [
                    _buildLoginForm(isDark, muted, textColor),
                    _buildRegisterForm(isDark, muted, textColor),
                  ],
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

  Widget _buildRegisterForm(bool isDark, Color muted, Color textColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Buat Akun Gratis ✨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
      const SizedBox(height: 4),
      Text('Bergabung dengan ribuan pencari kost', style: TextStyle(color: muted, fontSize: 13)),
      const SizedBox(height: 20),
      // Foto Profil
      Center(
        child: GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.coralBg,
            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
            child: _imageBytes == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.camera_alt, color: AppColors.coral, size: 24),
                    const SizedBox(height: 2),
                    Text('Foto Profil', style: TextStyle(fontSize: 10, color: muted)),
                  ])
                : null,
          ),
        ),
      ),
      const SizedBox(height: 16),
      _buildTextField(_regNameCtrl, 'Nama Lengkap', Icons.person_outline, isDark: isDark),
      const SizedBox(height: 12),
      _buildTextField(_regEmailCtrl, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress, isDark: isDark),
      const SizedBox(height: 12),
      _buildTextField(_regPwCtrl, 'Password', Icons.lock_outline, isPassword: true, isDark: isDark, isRegister: true),
      if (_regError.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFE53E3E).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Text(_regError, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
        ),
      ],
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _regLoading ? null : _handleRegister,
          child: _regLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Daftar Sekarang →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    ]);
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false, TextInputType? keyboardType, required bool isDark, bool isRegister = false}) {
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final obscure = isPassword ? (isRegister ? _regObscure : !_pwVisible) : false;
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: isDark ? AppColors.textDark : AppColors.textLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: muted),
        prefixIcon: Icon(icon, color: muted, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isRegister
                    ? (_regObscure ? Icons.visibility_off : Icons.visibility)
                    : (_pwVisible ? Icons.visibility_off : Icons.visibility),
                  size: 20, color: muted,
                ),
                onPressed: () => setState(() {
                  if (isRegister) {
                    _regObscure = !_regObscure;
                  } else {
                    _pwVisible = !_pwVisible;
                  }
                }),
              )
            : null,
      ),
    );
  }
}
