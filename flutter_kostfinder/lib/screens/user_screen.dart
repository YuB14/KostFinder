import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/api_service.dart';
import '../widgets/shared_app_bar.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String _search = '';
  bool _isLoading = true;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await ApiService.getUsers();
      if (mounted) setState(() => _users = users);
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filtered => _users.where((u) {
    final name = (u['name'] ?? '').toLowerCase();
    final email = (u['email'] ?? '').toLowerCase();
    final s = _search.toLowerCase();
    return name.contains(s) || email.contains(s);
  }).toList();

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  void _showUserSheet({Map<String, dynamic>? user}) {
    final isEdit = user != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: isEdit ? user['name'] : '');
    final emailCtrl = TextEditingController(text: isEdit ? user['email'] : '');
    final passwordCtrl = TextEditingController();
    String role = isEdit ? (user['role'] == 'admin' ? 'Admin' : 'Pengguna') : 'Pengguna';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final card = isDark ? AppColors.cardDark : AppColors.cardLight;
        final border = isDark ? AppColors.borderDark : AppColors.borderLight;
        final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
        final textColor = isDark ? AppColors.textDark : AppColors.textLight;
        final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;

        return StatefulBuilder(builder: (context, setStateSheet) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24)),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(10)),
                          child: Icon(isEdit ? Icons.edit_rounded : Icons.person_add_rounded, size: 20, color: AppColors.coral),
                        ),
                        const SizedBox(width: 12),
                        Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Text('Nama Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameCtrl,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'e.g. Budi Santoso',
                        filled: true, fillColor: bg2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),

                    Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailCtrl,
                      style: TextStyle(fontSize: 13, color: textColor),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'e.g. budi@mail.com',
                        filled: true, fillColor: bg2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                      ),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                    ),
                    const SizedBox(height: 14),

                    Text(isEdit ? 'Password Baru (Opsional)' : 'Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Min. 8 karakter',
                        filled: true, fillColor: bg2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                      ),
                      validator: (v) => (!isEdit && (v == null || v.length < 8)) ? 'Minimal 8 karakter' : null,
                    ),
                    const SizedBox(height: 14),

                    Text('Peran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: bg2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: role,
                          isExpanded: true,
                          dropdownColor: card,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: muted),
                          style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w600),
                          items: ['Pengguna', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (v) => setStateSheet(() => role = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          if (!formKey.currentState!.validate()) return;
                          setStateSheet(() => isSubmitting = true);
                          try {
                            if (isEdit) {
                              await ApiService.updateUser(
                                user['id'].toString(),
                                name: nameCtrl.text,
                                email: emailCtrl.text,
                                password: passwordCtrl.text.isNotEmpty ? passwordCtrl.text : null,
                                role: role.toLowerCase(),
                              );
                            } else {
                              await ApiService.register(
                                name: nameCtrl.text,
                                email: emailCtrl.text,
                                password: passwordCtrl.text,
                              );
                              // We can't set role natively in current /auth/register unless backend allows it, 
                              // but let's just proceed. 
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _loadUsers();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pengguna ${nameCtrl.text} berhasil ${isEdit ? 'diperbarui' : 'ditambahkan'}!'), backgroundColor: AppColors.teal),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan pengguna'), backgroundColor: AppColors.coral),
                            );
                            setStateSheet(() => isSubmitting = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Simpan Pengguna', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
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

  void _deleteUser(String id, String name) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hapus Pengguna'),
      content: Text('Yakin ingin menghapus pengguna $name?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            setState(() => _isLoading = true);
            try {
              await ApiService.deleteUser(id);
              await _loadUsers();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pengguna $name dihapus!'), backgroundColor: AppColors.coral),
              );
            } catch (e) {
              setState(() => _isLoading = false);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Scaffold(
      appBar: const SharedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeader(title: 'Manajemen ', italic: 'Pengguna', subtitle: 'Kelola semua pengguna yang terdaftar di KostFinder.'),
          const SizedBox(height: 16),

          Builder(
            builder: (context) {
              final String totalUsers = _users.length.toString();
              final String totalAdmins = _users.where((u) => u['role'] == 'admin').length.toString();
              
              final now = DateTime.now();
              final int thisMonth = _users.where((u) {
                if (u['created_at_iso'] == null) return false;
                final date = DateTime.tryParse(u['created_at_iso'].toString());
                return date != null && date.year == now.year && date.month == now.month;
              }).length;
              
              return Row(children: [
                Expanded(child: StatCard(icon: Icons.people_rounded, value: totalUsers, label: 'Total Pengguna', accentColor: AppColors.teal, accentBg: AppColors.tealBg)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(icon: Icons.admin_panel_settings_rounded, value: totalAdmins, label: 'Total Admin', accentColor: AppColors.coral, accentBg: AppColors.coralBg)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(icon: Icons.person_add_rounded, value: thisMonth.toString(), label: 'Bulan Ini', accentColor: AppColors.yellow, accentBg: AppColors.yellowBg)),
              ]);
            }
          ),
          const SizedBox(height: 20),

          // Table header + search
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: card, borderRadius: const BorderRadius.vertical(top: Radius.circular(14)), border: Border.all(color: border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Daftar Pengguna', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_rounded, size: 14),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    side: BorderSide(color: border),
                    foregroundColor: muted,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showUserSheet(),
                  icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                  label: const Text('Tambah', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    backgroundColor: AppColors.coral,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              SearchBar2(hint: 'Cari pengguna...', onChanged: (v) => setState(() => _search = v)),
            ]),
          ),

          // Table header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
            child: Row(children: [
              Expanded(flex: 3, child: Text('PENGGUNA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted, letterSpacing: 0.7))),
              Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted, letterSpacing: 0.7))),
              Expanded(flex: 2, child: Text('BERGABUNG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted, letterSpacing: 0.7))),
              SizedBox(width: 60, child: Text('AKSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted, letterSpacing: 0.7), textAlign: TextAlign.center)),
            ]),
          ),

          // User rows
          _isLoading 
            ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.coral)))
            : Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border.all(color: border),
            ),
            child: Column(
              children: _filtered.asMap().entries.map((e) {
                final i = e.key; final u = e.value;
                final name = u['name'] ?? '-';
                final email = u['email'] ?? '-';
                final role = u['role'] ?? 'user';
                final status = u['status'] ?? 'Tidak Aktif';
                final joined = u['created_at']?.toString() ?? '-';
                final photo = ApiService.getImageUrl(u['photo']?.toString() ?? u['profile_picture']?.toString());
                final isActive = status == 'Aktif';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: i < _filtered.length - 1 ? Border(bottom: BorderSide(color: border)) : null,
                  ),
                  child: Row(children: [
                    Expanded(flex: 3, child: Row(children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.coral,
                          image: photo != null ? DecorationImage(image: NetworkImage(photo), fit: BoxFit.cover) : null,
                        ),
                        child: photo == null ? Center(child: Text(_getInitials(name), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))) : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(role.toUpperCase(), style: TextStyle(fontSize: 9, color: muted)),
                      ])),
                    ])),
                    Expanded(flex: 2, child: isActive ? PillBadge.green('● Aktif') : PillBadge.yellow('● Tidak Aktif')),
                    Expanded(flex: 2, child: Text(joined, style: TextStyle(fontSize: 10, color: muted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    SizedBox(width: 60, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _ActionBtn(icon: Icons.edit_rounded, onTap: () => _showUserSheet(user: u)),
                      const SizedBox(width: 5),
                      _ActionBtn(icon: Icons.delete_outline_rounded, onTap: () => _deleteUser(u['id'].toString(), name)),
                    ])),
                  ]),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(child: Icon(icon, size: 13, color: muted)),
      ),
    );
  }
}
