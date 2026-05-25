import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../User/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  Uint8List? _imageBytes;
  String? _imageName;

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

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showSnack('Semua field wajib diisi');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.register(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
        profilePictureBytes: _imageBytes,
        profilePictureName: _imageName,
      );
      if (res['message'] == 'Register berhasil') {
        if (!mounted) return;
        _showSnack('Registrasi berhasil! Silakan login.');
        Navigator.pop(context);
      } else {
        final errors = res['errors'];
        String msg = res['message'] ?? 'Registrasi gagal';
        if (errors != null) msg = (errors as Map).values.expand((e) => e as List).join('\n');
        _showSnack(msg);
      }
    } catch (e) {
      _showSnack('Koneksi gagal: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.coralBg,
              backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
              child: _imageBytes == null
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.camera_alt, color: AppColors.coral, size: 28),
                      const SizedBox(height: 4),
                      Text('Foto Profil', style: TextStyle(fontSize: 11, color: muted)),
                    ])
                  : null,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
            ),
            child: Column(children: [
              _buildField(_nameCtrl, 'Nama Lengkap', Icons.person_outline),
              const SizedBox(height: 16),
              _buildField(_emailCtrl, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField(_passCtrl, 'Password', Icons.lock_outline, obscure: _obscure, suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool obscure = false, TextInputType? keyboardType, Widget? suffix}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.coral),
        suffixIcon: suffix,
      ),
    );
  }
}

