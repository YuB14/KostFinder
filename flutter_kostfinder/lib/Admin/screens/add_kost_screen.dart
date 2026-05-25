import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../services/api_service.dart';
import 'kost_screen.dart';

class AddKostScreen extends StatefulWidget {
  final KostData? editKost;
  const AddKostScreen({super.key, this.editKost});

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
  final _luasKamarCtrl = TextEditingController();

  String _selectedTipe = 'Pria';
  String _selectedKelas = 'Standar';
  int _selectedStatus = 1;
  int _selectedKodeLokasi = 1;
  String? _selectedWilayahId;
  String _selectedWilayahNama = '';

  // Binary facilities
  bool _fListrik = true;
  bool _fAc = false;
  bool _fKmDalam = false;
  bool _fParkir = false;
  bool _fLaundry = false;
  bool _fWifi = false;

  // Wilayah list from API
  List<dynamic> _wilayahList = [];

  bool _isSubmitting = false;
  int _currentStep = 0;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  bool get _isEdit => widget.editKost != null;

  final _tipeList = ['Pria', 'Wanita', 'Bebas'];
  final _kelasList = ['Ekonomi', 'Standar', 'Premium'];

  @override
  void initState() {
    super.initState();
    _loadWilayahs();
    if (_isEdit) {
      final k = widget.editKost!;
      _namaCtrl.text = k.name;
      _alamatCtrl.text = k.location;
      _kontakCtrl.text = k.ownerNumber;
      _deskripsiCtrl.text = k.description;
      _selectedTipe = k.type;
      _selectedKelas = k.roomClass;
      _selectedStatus = k.statusInt;
      _selectedKodeLokasi = k.kodeLokasi;
      _selectedWilayahId = k.wilayahId.isNotEmpty ? k.wilayahId : null;
      _selectedWilayahNama = k.wilayahNama;
      _luasKamarCtrl.text = k.luasKamar > 0 ? k.luasKamar.toStringAsFixed(0) : '';

      // Binary facilities
      _fListrik = k.bListrik == 1;
      _fAc = k.bAc == 1;
      _fKmDalam = k.bKmDalam == 1;
      _fParkir = k.bParkir == 1;
      _fLaundry = k.bLaundry == 1;
      _fWifi = k.bWifi == 1;

      // Harga: strip prefix "Rp " dan format ulang
      final rawHarga = k.price.replaceAll('Rp ', '').replaceAll('.', '').trim();
      final intHarga = int.tryParse(rawHarga);
      if (intHarga != null) {
        _hargaCtrl.text = intHarga.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
        );
      }
    }
    _hargaCtrl.addListener(_updateKelasFromHarga);
  }

  Future<void> _loadWilayahs() async {
    try {
      final list = await ApiService.getWilayahs();
      if (mounted) setState(() => _wilayahList = list);
    } catch (_) {}
  }

  void _updateKelasFromHarga() {
    final text = _hargaCtrl.text.replaceAll('.', '');
    final harga = int.tryParse(text) ?? 0;
    String newKelas = 'Standar';
    if (harga < 1000000) newKelas = 'Ekonomi';
    else if (harga > 1500000) newKelas = 'Premium';
    if (_selectedKelas != newKelas) setState(() => _selectedKelas = newKelas);
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) setState(() => _selectedImages.addAll(images));
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  int get _tipeKosInt {
    if (_selectedTipe == 'Pria') return 1;
    if (_selectedTipe == 'Wanita') return 2;
    return 3;
  }

  @override
  void dispose() {
    _hargaCtrl.removeListener(_updateKelasFromHarga);
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _kontakCtrl.dispose();
    _luasKamarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final hargaBersih = _hargaCtrl.text.replaceAll('.', '');
      final luasKamar = double.tryParse(_luasKamarCtrl.text) ?? 0;

      Map<String, dynamic> res;
      if (_isEdit) {
        res = await ApiService.updateKost(
          id: widget.editKost!.id,
          namaKost: _namaCtrl.text,
          alamatKost: _alamatCtrl.text,
          hargaKost: hargaBersih,
          tipeKos: _tipeKosInt,
          status: _selectedStatus,
          luasKamar: luasKamar,
          kodeLokasi: _selectedKodeLokasi,
          wilayahId: _selectedWilayahId,
          listrik: _fListrik ? 1 : 0,
          ac: _fAc ? 1 : 0,
          kamarMandiDalam: _fKmDalam ? 1 : 0,
          parkirMotor: _fParkir ? 1 : 0,
          laundry: _fLaundry ? 1 : 0,
          wifi: _fWifi ? 1 : 0,
          nomorTelepon: _kontakCtrl.text,
          deskripsi: _deskripsiCtrl.text,
          fotoPaths: _selectedImages.map((e) => e.path).toList(),
        );
      } else {
        res = await ApiService.addKost(
          namaKost: _namaCtrl.text,
          alamatKost: _alamatCtrl.text,
          hargaKost: hargaBersih,
          tipeKos: _tipeKosInt,
          status: _selectedStatus,
          luasKamar: luasKamar,
          kodeLokasi: _selectedKodeLokasi,
          wilayahId: _selectedWilayahId,
          listrik: _fListrik ? 1 : 0,
          ac: _fAc ? 1 : 0,
          kamarMandiDalam: _fKmDalam ? 1 : 0,
          parkirMotor: _fParkir ? 1 : 0,
          laundry: _fLaundry ? 1 : 0,
          wifi: _fWifi ? 1 : 0,
          nomorTelepon: _kontakCtrl.text,
          deskripsi: _deskripsiCtrl.text,
          fotoPaths: _selectedImages.map((e) => e.path).toList(),
        );
      }

      if (!mounted) return;
      if (res['success'] == true) {
        _showSuccessSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? (_isEdit ? 'Gagal mengupdate kost' : 'Gagal menambahkan kost')),
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
            Text(
              _isEdit ? 'Kost Berhasil Diperbarui!' : 'Kost Berhasil Ditambahkan!',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isEdit
                  ? '"${_namaCtrl.text}" berhasil diperbarui.'
                  : '"${_namaCtrl.text}" berhasil didaftarkan dan sudah berstatus Aktif di platform.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.teal, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // tutup bottom sheet
                  Navigator.pop(context); // kembali ke daftar kost
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
            backgroundColor: _isEdit ? AppColors.coral : AppColors.teal,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isEdit ? Icons.edit_rounded : Icons.home_work_rounded,
                    color: Colors.white, size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEdit ? 'Edit Kost' : 'Tambah Kost',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                    ),
                    Text(
                      _isEdit ? 'Perbarui data listing kost' : 'KostFinder - Listing Baru',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
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
                _StepIndicator(
                  current: _currentStep, total: 4,
                  isDark: isDark, border: border, bg2: bg2,
                  textColor: textColor, muted: muted,
                  accentColor: _isEdit ? AppColors.coral : AppColors.teal,
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(children: [
                    // ─── STEP 1: Info Dasar ───────────────────────────────────
                    _SectionCard(
                      title: 'Informasi Dasar',
                      icon: Icons.info_rounded,
                      accentColor: _isEdit ? AppColors.coral : AppColors.teal,
                      accentBg: _isEdit ? AppColors.coralBg : AppColors.tealBg,
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

                    // ─── STEP 2: Detail Kamar ─────────────────────────────────
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
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted,
                        ),
                        const SizedBox(height: 14),
                        _SelectableCardRow(
                          label: 'Kelas Kamar (Terisi Otomatis)',
                          value: _selectedKelas,
                          items: _kelasList,
                          onChanged: null,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted,
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
                            final n = int.tryParse(v.replaceAll('.', ''));
                            if (n == null || n < 100000) return 'Harga minimal Rp 100.000';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _luasKamarCtrl,
                          label: 'Luas Kamar (m²)',
                          hint: 'e.g. 12',
                          icon: Icons.square_foot_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 14),
                        // Status (0=Penuh, 1=Tersedia, 2+=sisa kamar)
                        Text('Status Kamar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedStatus,
                              isExpanded: true,
                              dropdownColor: card,
                              style: TextStyle(fontSize: 13, color: textColor),
                              icon: Icon(Icons.arrow_drop_down_rounded, color: muted),
                              onChanged: (v) { if (v != null) setState(() => _selectedStatus = v); },
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('🔴 Penuh')),
                                DropdownMenuItem(value: 1, child: Text('🟢 Tersedia')),
                                DropdownMenuItem(value: 2, child: Text('🟡 Sisa 2 Kamar')),
                                DropdownMenuItem(value: 3, child: Text('🟡 Sisa 3 Kamar')),
                                DropdownMenuItem(value: 4, child: Text('🟡 Sisa 4 Kamar')),
                                DropdownMenuItem(value: 5, child: Text('🟢 Sisa 5 Kamar')),
                                DropdownMenuItem(value: 6, child: Text('🟢 Sisa 6 Kamar')),
                                DropdownMenuItem(value: 7, child: Text('🟢 Sisa 7 Kamar')),
                                DropdownMenuItem(value: 8, child: Text('🟢 Sisa 8 Kamar')),
                                DropdownMenuItem(value: 9, child: Text('🟢 Sisa 9 Kamar')),
                                DropdownMenuItem(value: 10, child: Text('🟢 Sisa 10 Kamar')),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Kode Lokasi
                        Text('Kode Lokasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedKodeLokasi,
                              isExpanded: true,
                              dropdownColor: card,
                              style: TextStyle(fontSize: 13, color: textColor),
                              icon: Icon(Icons.arrow_drop_down_rounded, color: muted),
                              onChanged: (v) { if (v != null) setState(() => _selectedKodeLokasi = v); },
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('📍 1 - Dekat Kampus')),
                                DropdownMenuItem(value: 2, child: Text('🏙️ 2 - Pusat Kota')),
                                DropdownMenuItem(value: 3, child: Text('🏘️ 3 - Pinggir Kota')),
                                DropdownMenuItem(value: 4, child: Text('🚌 4 - Dekat Transportasi Umum')),
                                DropdownMenuItem(value: 5, child: Text('🏡 5 - Perumahan')),
                                DropdownMenuItem(value: 6, child: Text('🛒 6 - Dekat Pasar')),
                                DropdownMenuItem(value: 7, child: Text('🏭 7 - Kawasan Industri')),
                                DropdownMenuItem(value: 8, child: Text('🛣️ 8 - Pinggir Jalan Utama')),
                                DropdownMenuItem(value: 9, child: Text('🌿 9 - Pedesaan / Wisata')),
                                DropdownMenuItem(value: 10, child: Text('📌 10 - Lainnya')),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Wilayah / Kota — searchable
                        Text('Wilayah / Kota', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _showWilayahPicker(context, isDark, card, border, textColor, muted),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                            child: Row(children: [
                              Expanded(child: Text(
                                _selectedWilayahNama.isNotEmpty ? _selectedWilayahNama : 'Pilih wilayah/kota...',
                                style: TextStyle(fontSize: 13, color: _selectedWilayahNama.isNotEmpty ? textColor : muted),
                              )),
                              Icon(Icons.search_rounded, size: 18, color: muted),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _deskripsiCtrl,
                          label: 'Deskripsi Kost (Opsional)',
                          hint: 'Ceritakan keunggulan kost ini...',
                          icon: Icons.description_rounded,
                          isDark: isDark, card: card, border: border,
                          textColor: textColor, muted: muted, bg2: bg2,
                          maxLines: 3,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    // ─── STEP 3: Fasilitas (Checkbox) ────────────────────────────
                    _SectionCard(
                      title: 'Fasilitas',
                      icon: Icons.checklist_rounded,
                      accentColor: AppColors.yellow,
                      accentBg: AppColors.yellowBg,
                      isDark: isDark, card: card, border: border,
                      onTap: () => setState(() => _currentStep = 2),
                      isActive: _currentStep == 2,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Pilih fasilitas yang tersedia:', style: TextStyle(fontSize: 12, color: muted, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),
                        _facilitySwitch('⚡ Listrik', _fListrik, (v) => setState(() => _fListrik = v), isDark, border),
                        _facilitySwitch('❄️ AC', _fAc, (v) => setState(() => _fAc = v), isDark, border),
                        _facilitySwitch('🚿 KM Dalam', _fKmDalam, (v) => setState(() => _fKmDalam = v), isDark, border),
                        _facilitySwitch('🏍️ Parkir Motor', _fParkir, (v) => setState(() => _fParkir = v), isDark, border),
                        _facilitySwitch('👕 Laundry', _fLaundry, (v) => setState(() => _fLaundry = v), isDark, border),
                        _facilitySwitch('📶 WiFi', _fWifi, (v) => setState(() => _fWifi = v), isDark, border),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    // ─── STEP 4: Foto ─────────────────────────────────────────
                    _SectionCard(
                      title: 'Foto Kost',
                      icon: Icons.photo_library_rounded,
                      accentColor: _isEdit ? AppColors.coral : AppColors.teal,
                      accentBg: _isEdit ? AppColors.coralBg : AppColors.tealBg,
                      isDark: isDark, card: card, border: border,
                      onTap: () => setState(() => _currentStep = 3),
                      isActive: _currentStep == 3,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          _isEdit
                              ? 'Pilih foto baru untuk mengganti foto saat ini (opsional).'
                              : 'Tambahkan foto kost untuk memperlengkap informasi.',
                          style: TextStyle(fontSize: 12, color: muted, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedImages.isNotEmpty) ...[
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, index) => Stack(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<Uint8List>(
                                    future: _selectedImages[index].readAsBytes(),
                                    builder: (ctx, snap) {
                                      if (snap.hasData) {
                                        return Image.memory(
                                          snap.data!,
                                          width: 100, height: 100, fit: BoxFit.cover,
                                        );
                                      }
                                      return const SizedBox(width: 100, height: 100);
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4, right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                      child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: bg2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border, width: 1.5),
                            ),
                            child: Column(children: [
                              Icon(Icons.add_a_photo_rounded, size: 32, color: muted),
                              const SizedBox(height: 8),
                              Text('Pilih Foto', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // ─── Submit Button ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEdit ? AppColors.coral : AppColors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(_isEdit ? Icons.save_rounded : Icons.upload_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _isEdit ? 'Simpan Perubahan' : 'Daftarkan Kost',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _isEdit ? 'Perubahan akan langsung tersimpan' : 'Data akan diverifikasi oleh tim KostFinder',
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

  Widget _facilitySwitch(String label, bool value, ValueChanged<bool> onChanged, bool isDark, Color border) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textDark : AppColors.textLight))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.teal,
        ),
      ]),
    );
  }

  void _showWilayahPicker(BuildContext context, bool isDark, Color card, Color border, Color textColor, Color muted) {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateSheet) {
          final filtered = _wilayahList.where((w) {
            final nama = (w['nama_wilayah'] ?? '').toString().toLowerCase();
            return nama.contains(query.toLowerCase());
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDark : AppColors.bgLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text('Pilih Wilayah / Kota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setStateSheet(() => query = v),
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Cari wilayah/kota...',
                    hintStyle: TextStyle(color: muted),
                    prefixIcon: Icon(Icons.search, color: muted),
                    filled: true,
                    fillColor: card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.coral)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                  ? Center(child: Text('Tidak ada wilayah ditemukan.', style: TextStyle(color: muted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final w = filtered[i];
                        final isSelected = w['id']?.toString() == _selectedWilayahId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.tealBg : card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.teal : border),
                          ),
                          child: ListTile(
                            dense: true,
                            title: Text(w['nama_wilayah'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                            subtitle: Text('Kode Lokasi: ${w['kode_lokasi'] ?? '-'}', style: TextStyle(fontSize: 11, color: muted)),
                            trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.teal) : null,
                            onTap: () {
                              setState(() {
                                _selectedWilayahId = w['id']?.toString();
                                _selectedWilayahNama = w['nama_wilayah'] ?? '';
                                _selectedKodeLokasi = int.tryParse(w['kode_lokasi']?.toString() ?? '1') ?? 1;
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      },
                    ),
              ),
            ]),
          );
        });
      },
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current, total;
  final bool isDark;
  final Color border, bg2, textColor, muted, accentColor;

  const _StepIndicator({
    required this.current, required this.total, required this.isDark,
    required this.border, required this.bg2, required this.textColor,
    required this.muted, required this.accentColor,
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
              color: stepBefore < current ? accentColor : border,
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
              color: isDone ? accentColor : (isActive ? accentColor.withValues(alpha: 0.15) : bg2),
              border: Border.all(
                color: (isActive || isDone) ? accentColor : border,
                width: 2,
              ),
            ),
            child: Center(
              child: isDone
                  ? Icon(Icons.check_rounded, size: 14, color: accentColor)
                  : Text('${step + 1}', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isActive ? accentColor : muted,
                    )),
            ),
          ),
          const SizedBox(height: 4),
          Text(_labels[step], style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: (isActive || isDone) ? accentColor : muted,
          )),
        ]);
      }),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

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
          color: isActive ? accentColor.withValues(alpha: 0.5) : border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? accentColor.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
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

// ─── Form Field ───────────────────────────────────────────────────────────────

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
          hintStyle: TextStyle(fontSize: 13, color: muted.withValues(alpha: 0.6), fontWeight: FontWeight.w400),
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

// ─── Selectable Card Row ──────────────────────────────────────────────────────

class _SelectableCardRow extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String>? onChanged;
  final bool isDark;
  final Color card, border, textColor, muted;

  const _SelectableCardRow({
    required this.label, required this.value, required this.items,
    this.onChanged, required this.isDark, required this.card,
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
          final isDisabled = onChanged == null;
          return Expanded(
            child: GestureDetector(
              onTap: isDisabled ? null : () => onChanged!(item),
              child: Opacity(
                opacity: isDisabled ? 0.6 : 1.0,
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
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

// ─── Currency Formatter ───────────────────────────────────────────────────────

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (intValue == null) return oldValue;
    final newText = intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
    );
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}