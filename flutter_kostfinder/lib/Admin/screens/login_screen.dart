import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _obscureLogin = true;
  bool _obscureReg = true;
  bool _loading = false;
  String? _regPhotoPath;

  final _loginEmailCtrl = TextEditingController();
  final _loginPwCtrl = TextEditingController();
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPwCtrl = TextEditingController();

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

  void _handleLogin() async {
    final email = _loginEmailCtrl.text.trim();
    final password = _loginPwCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email dan password tidak boleh kosong')));
      return;
    }

    setState(() => _loading = true);
    
    try {
      final res = await ApiService.login(email, password);
      if (res['success'] == true) {
        await ApiService.saveSession(res['user']);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Login gagal')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleRegister() async {
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final password = _regPwCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || _regPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom dan foto profil wajib diisi')));
      return;
    }

    setState(() => _loading = true);
    
    try {
      final res = await ApiService.register(name: name, email: email, password: password, profilePicturePath: _regPhotoPath);
      if (res['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil! Silakan masuk.'), backgroundColor: AppColors.teal));
        _tabController.animateTo(0); // Pindah ke tab login
        _loginEmailCtrl.text = email;
        setState(() { _regPhotoPath = null; _regNameCtrl.clear(); _regPwCtrl.clear(); });
      } else {
        if (!mounted) return;
        String errMsg = res['message'] ?? 'Registrasi gagal';
        if (res['errors'] != null) {
          final errors = res['errors'] as Map<String, dynamic>;
          errMsg = errors.values.first.first.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Topbar ──────────────────────────────────────────
              Container(
                color: card,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [AppColors.coral, AppColors.coral2],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: AppColors.coral.withOpacity(0.28), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Center(child: Text('🏠', style: TextStyle(fontSize: 16))),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                        children: [
                          const TextSpan(text: 'Kost'),
                          const TextSpan(text: 'Finder', style: TextStyle(color: AppColors.coral)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Auth Card ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      // Tab bar
                      Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: AppColors.coral,
                          unselectedLabelColor: muted,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          tabs: const [Tab(text: 'Masuk'), Tab(text: 'Daftar')],
                        ),
                      ),

                      // Tab content
                      SizedBox(
                        height: 480,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginForm(textColor, muted, border),
                            _buildRegisterForm(textColor, muted, border),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(Color textColor, Color muted, Color border) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(100)),
              child: Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Selamat Datang Kembali', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.coral)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.3),
              children: const [
                TextSpan(text: 'Masuk ke '),
                TextSpan(text: 'Akunmu', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.coral)),
                TextSpan(text: ' 👋'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('Temukan kost impianmu hari ini.', style: TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 20),

          // Email
          _buildInputLabel('Email'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(prefixText: '  📧  ', hintText: 'namaemail@gmail.com'),
          ),
          const SizedBox(height: 14),

          // Password
          _buildInputLabel('Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginPwCtrl,
            obscureText: _obscureLogin,
            decoration: InputDecoration(
              prefixText: '  🔑  ',
              hintText: 'Masukkan password',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
                icon: Icon(_obscureLogin ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: muted),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.coral,
                shadowColor: AppColors.coral.withOpacity(0.3),
                elevation: 4,
              ),
              child: _loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Masuk Sekarang →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const Spacer(),
          Center(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: muted),
                  children: const [
                    TextSpan(text: 'Belum punya akun? '),
                    TextSpan(text: 'Daftar Gratis', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(Color textColor, Color muted, Color border) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(100)),
                child: Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Bergabung Sekarang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.coral)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.3),
                children: const [
                  TextSpan(text: 'Buat Akun '),
                  TextSpan(text: 'Gratis', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.coral)),
                  TextSpan(text: ' ✨'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text('Bergabung dengan 18.000+ pencari kost.', style: TextStyle(fontSize: 12, color: muted)),
            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _regPhotoPath = picked.path);
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coralBg,
                        image: _regPhotoPath != null 
                            ? DecorationImage(image: FileImage(File(_regPhotoPath!)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _regPhotoPath == null ? const Center(
                        child: Icon(Icons.person_add_alt_1_rounded, size: 30, color: AppColors.coral),
                      ) : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.coral, shape: BoxShape.circle, border: Border.all(color: border, width: 2)),
                        child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildInputLabel('Nama Lengkap'),
            const SizedBox(height: 6),
            TextFormField(controller: _regNameCtrl, decoration: const InputDecoration(prefixText: '  👤  ', hintText: 'Nama kamu')),
            const SizedBox(height: 14),

            _buildInputLabel('Email'),
            const SizedBox(height: 6),
            TextFormField(controller: _regEmailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixText: '  📧  ', hintText: 'namaemail@gmail.com')),
            const SizedBox(height: 14),

            _buildInputLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regPwCtrl,
              obscureText: _obscureReg,
              decoration: InputDecoration(
                prefixText: '  🔑  ',
                hintText: 'Min. 8 karakter',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureReg = !_obscureReg),
                  icon: Icon(_obscureReg ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: muted),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.coral,
                  shadowColor: AppColors.coral.withOpacity(0.3),
                  elevation: 4,
                ),
                child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Daftar Sekarang →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: muted),
                    children: const [
                      TextSpan(text: 'Sudah punya akun? '),
                      TextSpan(text: 'Masuk', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));
  }
}
