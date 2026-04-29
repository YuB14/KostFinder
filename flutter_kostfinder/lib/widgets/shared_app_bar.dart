import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';

class SharedAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SharedAppBar({super.key});

  @override
  State<SharedAppBar> createState() => _SharedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SharedAppBarState extends State<SharedAppBar> {
  bool _isLoading = true;
  String _userId = '';
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final session = await ApiService.getSession();
      if (session != null) {
        final u = session['user'] ?? session;
        if (mounted) {
          setState(() {
            _userId = u['id'].toString();
            _userName = u['name'] ?? 'Pengguna';
            _userEmail = u['email'] ?? '';
            _userRole = u['role'] ?? 'user';
            final photo = u['profile_picture'];
            if (photo != null) {
              _userPhotoUrl = ApiService.getImageUrl(photo.toString());
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user session: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  ImageProvider? _getProfileImage(String? pathOrUrl) {
    if (pathOrUrl == null) return null;
    if (pathOrUrl.startsWith('http')) {
      return NetworkImage(pathOrUrl);
    } else {
      return FileImage(File(pathOrUrl));
    }
  }

  Widget _iconBtn(IconData icon, Color muted) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Icon(icon, size: 20, color: muted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return AppBar(
      backgroundColor: card,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.coral,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.coral.withOpacity(0.30), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Center(
              child: Icon(Icons.home_work_rounded, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
              children: const [
                TextSpan(text: 'Kost'),
                TextSpan(text: 'Finder', style: TextStyle(color: AppColors.coral)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
          child: _iconBtn(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, muted),
        ),
        const SizedBox(width: 8),
        _isLoading 
          ? const SizedBox(width: 34, height: 34) 
          : GestureDetector(
          onTap: () => _showProfileDialog(context),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coral,
              image: _userPhotoUrl != null
                  ? DecorationImage(image: _getProfileImage(_userPhotoUrl!)!, fit: BoxFit.cover)
                  : null,
            ),
            child: _userPhotoUrl == null 
                ? Center(child: Text(_getInitials(_userName), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)))
                : null,
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final card = isDark ? AppColors.cardDark : AppColors.cardLight;
        final border = isDark ? AppColors.borderDark : AppColors.borderLight;
        final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
        final textColor = isDark ? AppColors.textDark : AppColors.textLight;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coral,
                    image: _userPhotoUrl != null
                        ? DecorationImage(image: _getProfileImage(_userPhotoUrl!)!, fit: BoxFit.cover)
                        : null,
                  ),
                  child: _userPhotoUrl == null 
                      ? Center(child: Text(_getInitials(_userName), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)))
                      : null,
                ),
                const SizedBox(height: 16),
                Text(_userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 4),
                Text(_userEmail, style: TextStyle(fontSize: 13, color: muted)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(100)),
                  child: Text(_userRole.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.coral)),
                ),
                const SizedBox(height: 24),
                Divider(color: border),
                const SizedBox(height: 16),
                _ProfileMenu(icon: Icons.person_outline_rounded, title: 'Edit Profil', textColor: textColor, muted: muted, onTap: () => _showEditProfileSheet(context)),
                _ProfileMenu(icon: Icons.settings_outlined, title: 'Pengaturan Akun', textColor: textColor, muted: muted, onTap: () => _showSettingsSheet(context)),
                _ProfileMenu(icon: Icons.security_rounded, title: 'Privasi & Keamanan', textColor: textColor, muted: muted, onTap: () {}),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ApiService.clearSession();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (_) => const LoginScreen()), 
                          (route) => false
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.coral),
                    label: const Text('Keluar', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.coral),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    Navigator.pop(context); // close profile dialog first

    String tempName = _userName;
    String tempEmail = _userEmail;
    String tempPassword = '';
    String? tempPhoto = _userPhotoUrl;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final card = isDark ? AppColors.cardDark : AppColors.cardLight;
          final border = isDark ? AppColors.borderDark : AppColors.borderLight;
          final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
          final textColor = isDark ? AppColors.textDark : AppColors.textLight;
          final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.tealBg, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.edit_rounded, size: 20, color: AppColors.teal),
                        ),
                        const SizedBox(width: 12),
                        Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                        const Spacer(),
                        IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: muted)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setStateSheet(() => tempPhoto = picked.path);
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.coral,
                                image: tempPhoto != null 
                                    ? DecorationImage(image: _getProfileImage(tempPhoto)!, fit: BoxFit.cover)
                                    : null,
                              ),
                              child: tempPhoto == null ? Center(
                                child: Text(_getInitials(tempName), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                              ) : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: AppColors.teal, shape: BoxShape.circle, border: Border.all(color: card, width: 2)),
                                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Nama Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: tempName)..selection = TextSelection.collapsed(offset: tempName.length),
                      onChanged: (v) => tempName = v,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        filled: true, fillColor: bg2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.teal)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    
                    Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: tempEmail)..selection = TextSelection.collapsed(offset: tempEmail.length),
                      onChanged: (v) => tempEmail = v,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        filled: true, fillColor: bg2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.teal)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: tempPassword)..selection = TextSelection.collapsed(offset: tempPassword.length),
                      onChanged: (v) => tempPassword = v,
                      obscureText: true,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Kosongkan jika tidak ingin mengubah',
                        hintStyle: TextStyle(fontSize: 13, color: muted),
                        filled: true, fillColor: bg2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.teal)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : () async {
                          setStateSheet(() => isSaving = true);
                          try {
                            String? newPhotoPath;
                            if (tempPhoto != null && !tempPhoto!.startsWith('http')) {
                              newPhotoPath = tempPhoto;
                            }

                            final res = await ApiService.updateUser(
                              _userId,
                              name: tempName,
                              email: tempEmail,
                              password: tempPassword.isNotEmpty ? tempPassword : null,
                              profilePicturePath: newPhotoPath,
                            );

                            if (res['success'] == true) {
                              final updatedUser = res['data'];
                              await ApiService.saveSession(updatedUser);

                              setState(() {
                                _userName = updatedUser['name'];
                                _userEmail = updatedUser['email'];
                                final photo = updatedUser['profile_picture'];
                                if (photo != null) {
                                  _userPhotoUrl = ApiService.getImageUrl(photo.toString());
                                }
                              });
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: AppColors.teal));
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal memperbarui profil'), backgroundColor: Colors.red));
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red));
                            }
                          }
                          if (mounted) setStateSheet(() => isSaving = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan Perubahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    Navigator.pop(context); // close profile dialog first
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final card = isDark ? AppColors.cardDark : AppColors.cardLight;
            final border = isDark ? AppColors.borderDark : AppColors.borderLight;
            final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
            final textColor = isDark ? AppColors.textDark : AppColors.textLight;

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.blueBg, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.settings_rounded, size: 20, color: AppColors.blue),
                      ),
                      const SizedBox(width: 12),
                      Text('Pengaturan Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: muted)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSettingSwitch('Notifikasi Push', 'Terima pemberitahuan aktivitas', true, AppColors.blue, muted, textColor),
                  const SizedBox(height: 12),
                  _buildSettingSwitch(
                    'Mode Gelap', 
                    'Sesuaikan tema aplikasi', 
                    themeNotifier.value == ThemeMode.dark || (themeNotifier.value == ThemeMode.system && isDark), 
                    AppColors.blue, muted, textColor,
                    onChanged: (v) {
                      themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                      setStateSheet(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingSwitch('Lokasi', 'Izinkan akses lokasi perangkat', false, AppColors.blue, muted, textColor),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildSettingSwitch(String title, String subtitle, bool value, Color activeColor, Color muted, Color textColor, {ValueChanged<bool>? onChanged}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: muted)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged ?? (v) {},
          activeColor: activeColor,
        ),
      ],
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color textColor, muted;
  final VoidCallback? onTap;

  const _ProfileMenu({required this.icon, required this.title, required this.textColor, required this.muted, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: muted),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20, color: muted),
          ],
        ),
      ),
    );
  }
}
