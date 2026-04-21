import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class AddKostScreen extends StatefulWidget {
  const AddKostScreen({super.key});

  @override
  State<AddKostScreen> createState() => _AddKostScreenState();
}

class _AddKostScreenState extends State<AddKostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _kontakCtrl = TextEditingController();
  final _fasilitasCtrl = TextEditingController();

  String _selectedTipe = 'Pria';
  String _selectedKelas = 'Standar';

  bool _isSubmitting = false;
  int _currentStep = 0;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  final _tipeList = ['Pria', 'Wanita', 'Bebas'];
  final _kelasList = ['Ekonomi', 'Standar', 'Premium'];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _kontakCtrl.dispose();
    _fasilitasCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }
    setState(() => _isSubmitting = true);
    
    try {
      final res = await ApiService.addKost(
        namaKost: _namaCtrl.text,
        alamatKost: _alamatCtrl.text,
        kelas: _selectedKelas,
        jenisKost: _selectedTipe,
        status: 'Aktif', // Admin menambah kost -> Langsung aktif
        fasilitas: _fasilitasCtrl.text,
        hargaKost: _hargaCtrl.text.replaceAll('.', ''),
        nomorTelepon: _kontakCtrl.text,
        deskripsi: _deskripsiCtrl.text,
        fotoPaths: _selectedImages.map((e) => e.path).toList(),
      );

      if (!mounted) return;
      if (res['success'] == true) {
        _showSuccessSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? 'Gagal menambahkan kost'),
          backgroundColor: AppColors.coral,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
        backgroundColor: AppColors.coral,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final card = isDark ? AppColors.cardDark : AppColors.cardLight;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: AppColors.tealBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.teal, size: 38),
            ),
            const SizedBox(height: 16),
            Text('Kost Berhasil Ditambahkan!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDark : AppColors.textLight)),
            const SizedBox(height: 8),
            Text(
              '"${_namaCtrl.text}" berhasil didaftarkan dan sudah berstatus Aktif di platform.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.teal, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Kembali ke Daftar Kost',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: AppColors.teal,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tambah Kost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                    Text('KostFinder - Listing Baru', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ),
            titleSpacing: 0,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _StepIndicator(current: _currentStep, total: 4, isDark: isDark, border: border, bg2: bg2, textColor: textColor, muted: muted),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(children: [
                    _SectionCard(
                      title: 'Informasi Dasar',
                      icon: Icons.info_rounded,
                      accentColor: AppColors.teal,
                      accentBg: AppColors.tealBg,
                      isDark: isDark, card: card, border: border,
                      onTap: () => setState(() => _currentStep = 0),
                      isActive: _currentStep == 0,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _FormField(
                          controller: _namaCtrl,
                          label: 'Nama Kost',
                          hint: 'e.g. Kost Melati Indah',
                          icon: Icons.home_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama kost wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _alamatCtrl,
                          label: 'Alamat Lengkap',
                          hint: 'Jl. Kalimantan No. 12, Sumbersari...',
                          icon: Icons.location_on_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _kontakCtrl,
                          label: 'Nomor Kontak (WA/HP)',
                          hint: '0812xxxxxxxx',
                          icon: Icons.phone_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Nomor kontak wajib diisi';
                            if (v.length < 10) return 'Nomor tidak valid';
                            return null;
                          },
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    _SectionCard(
                      title: 'Detail Kamar',
                      icon: Icons.bedroom_parent_rounded,
                      accentColor: AppColors.coral,
                      accentBg: AppColors.coralBg,
                      isDark: isDark, card: card, border: border,
                      onTap: () => setState(() => _currentStep = 1),
                      isActive: _currentStep == 1,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _SelectableCardRow(
                          label: 'Tipe Kost',
                          value: _selectedTipe,
                          items: _tipeList,
                          onChanged: (v) => setState(() => _selectedTipe = v),
                          isDark: isDark, card: card, border: border, textColor: textColor, muted: muted,
                        ),
                        const SizedBox(height: 14),
                        _SelectableCardRow(
                          label: 'Kelas Kamar',
                          value: _selectedKelas,
                          items: _kelasList,
                          onChanged: (v) => setState(() => _selectedKelas = v),
                          isDark: isDark, card: card, border: border, textColor: textColor, muted: muted,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _hargaCtrl,
                          label: 'Harga per Bulan',
                          hint: '750.000',
                          icon: Icons.attach_money_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CurrencyInputFormatter(),
                          ],
                          prefixText: 'Rp ',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                            final cleanStr = v.replaceAll('.', '');
                            final n = int.tryParse(cleanStr);
                            if (n == null || n < 100000) return 'Harga minimal Rp 100.000';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _deskripsiCtrl,
                          label: 'Deskripsi Kost',
                          hint: 'Ceritakan keunggulan kost ini...',
                          icon: Icons.description_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          maxLines: 3,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    _SectionCard(
                      title: 'Fasilitas',
                      icon: Icons.checklist_rounded,
                      accentColor: AppColors.yellow,
                      accentBg: AppColors.yellowBg,
                      isDark: isDark, card: card, border: border,
                      onTap: () => setState(() => _currentStep = 2),
                      isActive: _currentStep == 2,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Tuliskan fasilitas yang tersedia di kost ini, pisahkan dengan koma.',
                            style: TextStyle(fontSize: 12, color: muted, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),
                        _FormField(
                          controller: _fasilitasCtrl,
                          label: 'Fasilitas Kost',
                          hint: 'WiFi, AC, Kamar Mandi Dalam, Parkir...',
                          icon: Icons.star_border_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Fasilitas wajib diisi' : null,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    _SectionCard(
                      title: 'Foto Kost',
                      icon: Icons.photo_library_rounded,
                      accentColor: AppColors.teal,
                      accentBg: AppColors.tealBg,
                      isDark: isDark, card: card, border: border,
                      onTap: () => setState(() => _currentStep = 3),
                      isActive: _currentStep == 3,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Tambahkan foto kost untuk memperlengkap informasi',
                            style: TextStyle(fontSize: 12, color: muted, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),
                        if (_selectedImages.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_selectedImages[index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        if (_selectedImages.isNotEmpty) const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: bg2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border, width: 1.5, style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 32, color: muted),
                                const SizedBox(height: 8),
                                Text('Pilih Foto', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.upload_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Daftarkan Kost', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                              ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Data akan diverifikasi oleh tim KostFinder',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current, total;
  final bool isDark;
  final Color border, bg2, textColor, muted;

  const _StepIndicator({
    required this.current, required this.total, required this.isDark,
    required this.border, required this.bg2, required this.textColor, required this.muted,
  });

  static const _labels = ['Info Dasar', 'Detail Kamar', 'Fasilitas', 'Foto'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          final stepBefore = (i - 1) ~/ 2;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: stepBefore < current ? AppColors.teal : border,
            ),
          );
        }
        final step = i ~/ 2;
        final isActive = step == current;
        final isDone = step < current;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 30, height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.teal : (isActive ? AppColors.teal.withOpacity(0.15) : bg2),
              border: Border.all(
                color: (isActive || isDone) ? AppColors.teal : border,
                width: 2,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded, size: 14, color: AppColors.teal)
                  : Text('${step + 1}', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.teal : muted,
                    )),
            ),
          ),
          const SizedBox(height: 4),
          Text(_labels[step], style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: (isActive || isDone) ? AppColors.teal : muted,
          )),
        ]);
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor, accentBg;
  final bool isDark, isActive;
  final Color card, border;
  final VoidCallback onTap;
  final Widget child;

  const _SectionCard({
    required this.title, required this.icon, required this.accentColor,
    required this.accentBg, required this.isDark, required this.isActive,
    required this.card, required this.border, required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? accentColor.withOpacity(0.5) : border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? accentColor.withOpacity(0.08) : Colors.black.withOpacity(0.04),
            blurRadius: isActive ? 16 : 8,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 15, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accentColor)),
              const Spacer(),
              Icon(
                isActive ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 18, color: accentColor,
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: child,
        ),
      ]),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool isDark;
  final Color card, border, textColor, muted, bg2;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller, required this.label, required this.hint,
    required this.icon, required this.isDark, required this.card,
    required this.border, required this.textColor, required this.muted,
    required this.bg2, this.maxLines = 1, this.keyboardType,
    this.inputFormatters, this.prefixText, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: muted.withOpacity(0.6), fontWeight: FontWeight.w400),
          prefixText: prefixText,
          prefixStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, size: 17, color: muted),
          ),
          prefixIconConstraints: const BoxConstraints(),
          filled: true,
          fillColor: bg2,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral, width: 1.5)),
        ),
      ),
    ]);
  }
}

class _SelectableCardRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final Color card, border, textColor, muted;

  const _SelectableCardRow({
    required this.label, required this.value, required this.items,
    required this.onChanged, required this.isDark, required this.card,
    required this.border, required this.textColor, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
      const SizedBox(height: 6),
      Row(
        children: items.map((item) {
          final isSelected = value == item;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item),
              child: Container(
                margin: EdgeInsets.only(right: item == items.last ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tealBg : (isDark ? AppColors.bg2Dark : AppColors.bg2Light),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.teal : border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(item, style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.teal : muted,
                )),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (intValue == null) return oldValue;
    final newText = intValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
