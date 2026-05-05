import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  // Form state
  String _selectedKecamatan = 'Sumbersari';
  String _selectedTipe = 'Pria';
  String _selectedKelas = 'Standar';
  bool _hasAC = false;
  bool _hasWifi = false;
  bool _hasKMDalam = false;
  bool _hasParking = false;
  bool _hasLaundry = false;
  bool _hasListrik = false;

  bool _showResult = false;
  bool _isLoading = false;

  final _kecamatanList = [
    'Sumbersari', 'Patrang', 'Kaliwates', 'Mangli',
    'Tegalboto', 'Jember Kota', 'Ambulu', 'Tanggul',
  ];
  final _tipeList = ['Pria', 'Wanita', 'Bebas'];
  final _kelasList = ['Ekonomi', 'Standar', 'Premium'];

  // Kelas multiplier info — dipakai di UI hint juga
  static const _kelasMultiplier = {
    'Ekonomi': 0.75,
    'Standar': 1.0,
    'Premium': 1.4,
  };

  static const _kelasDesc = {
    'Ekonomi': 'Kamar sederhana, fasilitas dasar',
    'Standar': 'Kamar nyaman, fasilitas umum',
    'Premium': 'Kamar luas, fasilitas lengkap',
  };

  int get _predictedPrice {
    final basePrices = {
      'Sumbersari': 600000, 'Tegalboto': 650000, 'Patrang': 750000,
      'Kaliwates': 550000, 'Mangli': 900000, 'Jember Kota': 700000,
      'Ambulu': 400000, 'Tanggul': 380000,
    };
    int price = basePrices[_selectedKecamatan] ?? 600000;

    // Kelas multiplier — eksplisit semua opsi
    final multiplier = _kelasMultiplier[_selectedKelas] ?? 1.0;
    price = (price * multiplier).round();

    // Fasilitas tambahan
    if (_hasAC) price += 200000;
    if (_hasWifi) price += 80000;
    if (_hasKMDalam) price += 150000;
    if (_hasParking) price += 60000;
    if (_hasLaundry) price += 100000;
    if (_hasListrik) price += 120000;

    return price;
  }

  String get _priceCategory {
    if (_predictedPrice < 500000) return 'Ekonomis';
    if (_predictedPrice < 900000) return 'Standar';
    return 'Premium';
  }

  Color get _categoryColor {
    if (_predictedPrice < 500000) return AppColors.teal;
    if (_predictedPrice < 900000) return AppColors.coral;
    return AppColors.yellow;
  }

  Color get _categoryBg {
    if (_predictedPrice < 500000) return AppColors.tealBg;
    if (_predictedPrice < 900000) return AppColors.coralBg;
    return AppColors.yellowBg;
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return 'Rp ${result.toString()}';
  }

  Future<void> _predict() async {
    setState(() { _isLoading = true; _showResult = false; });
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() { _isLoading = false; _showResult = true; });
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
            expandedHeight: 140,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.coral,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.coral, AppColors.coral2],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Prediksi Harga', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                            Text('KostFinder · AI Estimator', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                          ]),
                        ]),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(children: [
                            Icon(Icons.tips_and_updates_rounded, color: Colors.white70, size: 14),
                            SizedBox(width: 8),
                            Text('Isi detail kost untuk mendapat estimasi harga akurat', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Prediksi Harga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Detail Kost', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
                    const SizedBox(height: 16),

                    _FieldLabel('Kecamatan', muted),
                    const SizedBox(height: 6),
                    _DropdownField(
                      value: _selectedKecamatan,
                      items: _kecamatanList,
                      isDark: isDark, card: card, border: border, textColor: textColor,
                      onChanged: (v) => setState(() => _selectedKecamatan = v!),
                    ),
                    const SizedBox(height: 14),

                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _FieldLabel('Tipe Kost', muted),
                        const SizedBox(height: 6),
                        _DropdownField(
                          value: _selectedTipe,
                          items: _tipeList,
                          isDark: isDark, card: card, border: border, textColor: textColor,
                          onChanged: (v) => setState(() => _selectedTipe = v!),
                        ),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _FieldLabel('Kelas Kamar', muted),
                        const SizedBox(height: 6),
                        _DropdownField(
                          value: _selectedKelas,
                          items: _kelasList,
                          isDark: isDark, card: card, border: border, textColor: textColor,
                          onChanged: (v) => setState(() => _selectedKelas = v!),
                        ),
                      ])),
                    ]),

                    // Kelas hint badge
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey(_selectedKelas),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: bg2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: border),
                        ),
                        child: Row(children: [
                          Icon(Icons.info_outline_rounded, size: 13, color: muted),
                          const SizedBox(width: 7),
                          Text(
                            _kelasDesc[_selectedKelas] ?? '',
                            style: TextStyle(fontSize: 11, color: muted, fontStyle: FontStyle.italic),
                          ),
                          const Spacer(),
                          Text(
                            'x${_kelasMultiplier[_selectedKelas]?.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _FieldLabel('Fasilitas Tersedia', muted),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        _FasilitasChip(label: 'AC', icon: Icons.ac_unit_rounded, value: _hasAC, isDark: isDark, bg2: bg2, border: border, onTap: () => setState(() => _hasAC = !_hasAC)),
                        _FasilitasChip(label: 'WiFi', icon: Icons.wifi_rounded, value: _hasWifi, isDark: isDark, bg2: bg2, border: border, onTap: () => setState(() => _hasWifi = !_hasWifi)),
                        _FasilitasChip(label: 'KM Dalam', icon: Icons.shower_rounded, value: _hasKMDalam, isDark: isDark, bg2: bg2, border: border, onTap: () => setState(() => _hasKMDalam = !_hasKMDalam)),
                        _FasilitasChip(label: 'Parkir', icon: Icons.local_parking_rounded, value: _hasParking, isDark: isDark, bg2: bg2, border: border, onTap: () => setState(() => _hasParking = !_hasParking)),
                        _FasilitasChip(label: 'Laundry', icon: Icons.local_laundry_service_rounded, value: _hasLaundry, isDark: isDark, bg2: bg2, border: border, onTap: () => setState(() => _hasLaundry = !_hasLaundry)),
                        _FasilitasChip(label: 'Listrik', icon: Icons.bolt_rounded, value: _hasListrik, isDark: isDark, bg2: bg2, border: border, onTap: () => setState(() => _hasListrik = !_hasListrik)),
                      ],
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _predict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.auto_graph_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Prediksi Harga', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          ]),
                  ),
                ),

                if (_showResult) ...[
                  const SizedBox(height: 20),
                  _ResultCard(
                    price: _formatPrice(_predictedPrice),
                    category: _priceCategory,
                    categoryColor: _categoryColor,
                    categoryBg: _categoryBg,
                    kecamatan: _selectedKecamatan,
                    tipe: _selectedTipe,
                    kelas: _selectedKelas,
                    isDark: isDark, card: card, border: border,
                    muted: muted, textColor: textColor, bg2: bg2,
                    fasCount: [_hasAC, _hasWifi, _hasKMDalam, _hasParking, _hasLaundry, _hasListrik].where((x) => x).length,
                  ),
                ],

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blueBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline_rounded, size: 17, color: AppColors.blue),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Prediksi ini berdasarkan data rata-rata kost di area Jember. Harga aktual dapat berbeda tergantung kondisi bangunan, jarak ke kampus, dan negosiasi pemilik.',
                      style: TextStyle(fontSize: 12, color: AppColors.blue, height: 1.5),
                    )),
                  ]),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _FieldLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color));
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final bool isDark;
  final Color card, border, textColor;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value, required this.items, required this.isDark,
    required this.card, required this.border, required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor, size: 18),
          dropdownColor: card,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FasilitasChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value, isDark;
  final Color bg2, border;
  final VoidCallback onTap;

  const _FasilitasChip({
    required this.label, required this.icon, required this.value,
    required this.isDark, required this.bg2, required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? AppColors.coralBg : bg2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value ? AppColors.coral.withOpacity(0.5) : border, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: value ? AppColors.coral : (isDark ? AppColors.mutedDark : AppColors.mutedLight)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: value ? AppColors.coral : (isDark ? AppColors.mutedDark : AppColors.mutedLight))),
          if (value) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_rounded, size: 13, color: AppColors.coral),
          ],
        ]),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String price, category, kecamatan, tipe, kelas;
  final Color categoryColor, categoryBg;
  final bool isDark;
  final Color card, border, muted, textColor, bg2;
  final int fasCount;

  const _ResultCard({
    required this.price, required this.category, required this.categoryColor,
    required this.categoryBg, required this.kecamatan, required this.tipe,
    required this.kelas, required this.isDark, required this.card,
    required this.border, required this.muted, required this.textColor,
    required this.bg2, required this.fasCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.coral.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.coral.withOpacity(0.08), blurRadius: 16)],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.coral, AppColors.coral2],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Column(children: [
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.auto_graph_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text('Estimasi Harga Sewa', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 10),
            Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
            const Text('per bulan', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
              child: Text('Kategori: $category', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _DetailRow('Kecamatan', kecamatan, textColor, muted),
            const SizedBox(height: 10),
            _DetailRow('Tipe Kost', tipe, textColor, muted),
            const SizedBox(height: 10),
            _DetailRow('Kelas Kamar', kelas, textColor, muted),
            const SizedBox(height: 10),
            _DetailRow('Fasilitas', '$fasCount fasilitas dipilih', textColor, muted),
          ]),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color textColor, muted;
  const _DetailRow(this.label, this.value, this.textColor, this.muted);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
      ]),
    );
  }
}
