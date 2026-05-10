import 'package:flutter/material.dart';
import '../../services/prediksi_service.dart';
import '../../services/favorite_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../theme/theme_notifier.dart';

class PrediksiScreen extends StatefulWidget {
  const PrediksiScreen({super.key});

  @override
  State<PrediksiScreen> createState() => _PrediksiScreenState();
}

class _PrediksiScreenState extends State<PrediksiScreen> {
  final _hargaMaxCtrl = TextEditingController();
  final _hargaMinCtrl = TextEditingController();
  String _kelas = '';
  final Set<String> _fasilitasSelected = {};
  List<PrediksiModel> _results = [];
  Map<String, dynamic> _stats = {};
  bool _loading = false;
  bool _loadingStats = true;
  String _error = '';
  double? _maxSkor;

  final _fasilitasOpts = ['WiFi', 'AC', 'Parkir', 'Air Panas', 'Laundry', 'Dapur', 'Kamar Mandi Dalam', 'CCTV', 'Kulkas', 'TV'];
  final _kelasOpts = ['', 'Ekonomis', 'Standar', 'Premium'];
  final _kelasLabels = ['Semua', 'Ekonomis', 'Standar', 'Premium'];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _hargaMaxCtrl.dispose();
    _hargaMinCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await PrediksiService.getStats();
    if (mounted) setState(() { _stats = stats; _loadingStats = false; });
  }

  String _fmtInput(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    final n = int.parse(digits);
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  int _parseHarga(String formatted) {
    return int.tryParse(formatted.replaceAll('.', '')) ?? 0;
  }

  Future<void> _predict() async {
    final hargaMax = _parseHarga(_hargaMaxCtrl.text);
    if (hargaMax == 0) {
      setState(() => _error = 'Masukkan anggaran maksimal terlebih dahulu');
      return;
    }
    setState(() { _loading = true; _error = ''; _results = []; });
    final result = await PrediksiService.predict(
      hargaMax: hargaMax.toDouble(),
      hargaMin: _parseHarga(_hargaMinCtrl.text).toDouble(),
      fasilitas: _fasilitasSelected.toList(),
      kelas: _kelas,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      _results = result['data'] as List<PrediksiModel>;
      _maxSkor = (result['meta']['max_skor'] ?? 1).toDouble();
    } else {
      _error = result['message'] ?? 'Prediksi gagal';
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.bgDark     : AppColors.bgLight;
    final card     = isDark ? AppColors.cardDark   : AppColors.cardLight;
    final bg2      = isDark ? AppColors.bg2Dark    : AppColors.bg2Light;
    final border   = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted    = isDark ? AppColors.mutedDark  : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark  : AppColors.textLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.auto_graph_rounded, color: AppColors.coral, size: 18),
          ),
          const SizedBox(width: 10),
          Text('Prediksi Kost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: border),
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) {
              final isDarkMode = mode == ThemeMode.dark ||
                  (mode == ThemeMode.system &&
                      WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
              return IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20, color: muted),
                onPressed: () => themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Info Box Stats
          if (!_loadingStats && _stats.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.coral, AppColors.coral2]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statMini('Kost Aktif', '${_stats['total_kost'] ?? 0}'),
                  _statMini('Harga Min', Helpers.formatRupiah(_stats['harga_min'] ?? 0)),
                  _statMini('Harga Max', Helpers.formatRupiah(_stats['harga_max'] ?? 0)),
                ],
              ),
            ),

          // Form Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Input Preferensi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 16),

                // Harga Max
                Text('Anggaran Maksimal (Rp/bulan)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _hargaMaxCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13, color: textColor),
                  onChanged: (v) {
                    final formatted = _fmtInput(v);
                    _hargaMaxCtrl.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length));
                  },
                  decoration: InputDecoration(
                    hintText: '1.000.000',
                    hintStyle: TextStyle(color: muted),
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(color: textColor),
                    filled: true,
                    fillColor: bg2,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.coral)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Harga Min
                Text('Anggaran Minimal (opsional)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _hargaMinCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13, color: textColor),
                  onChanged: (v) {
                    final formatted = _fmtInput(v);
                    _hargaMinCtrl.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length));
                  },
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: muted),
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(color: textColor),
                    filled: true,
                    fillColor: bg2,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.coral)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Kelas
                Text('Kelas Kost',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: List.generate(_kelasOpts.length, (i) {
                    final opt = _kelasOpts[i];
                    final label = _kelasLabels[i];
                    final selected = _kelas == opt;
                    return GestureDetector(
                      onTap: () => setState(() => _kelas = opt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.coral : bg2,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: selected ? AppColors.coral : border),
                        ),
                        child: Text(label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : muted)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Fasilitas
                Text('Fasilitas Diinginkan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _fasilitasOpts.map((f) {
                    final sel = _fasilitasSelected.contains(f);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (sel) _fasilitasSelected.remove(f);
                        else _fasilitasSelected.add(f);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.coralBg : bg2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sel ? AppColors.coral : border),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: sel ? AppColors.coral : muted)),
                      ),
                    );
                  }).toList(),
                ),

                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(_error,
                        style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _predict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Prediksi Kost Untukku',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),

          // Hasil Prediksi
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hasil Prediksi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor)),
                Text('${_results.length} kost', style: TextStyle(fontSize: 12, color: muted)),
              ],
            ),
            const SizedBox(height: 12),
            ..._results.asMap().entries.map((entry) {
              final i = entry.key;
              final k = entry.value;
              final persen = _maxSkor != null && _maxSkor! > 0
                  ? ((k.skorCocok / _maxSkor!) * 100).clamp(0, 100).toInt()
                  : 0;
              return _PrediksiCard(
                key: ValueKey(k.id),
                item: k,
                isTop: i == 0,
                persen: persen,
                isDark: isDark,
                onFav: () async {
                  final r = await FavoriteService.addFavorite(k.id);
                  if (!mounted) return;
                  final msg = r['status'] == 409
                      ? 'Sudah ada di favorit'
                      : r['success'] == true
                          ? 'Ditambahkan ke favorit'
                          : 'Gagal menambahkan';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _statMini(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _PrediksiCard extends StatelessWidget {
  final PrediksiModel item;
  final bool isTop;
  final int persen;
  final bool isDark;
  final VoidCallback onFav;

  const _PrediksiCard({
    super.key,
    required this.item,
    required this.isTop,
    required this.persen,
    required this.isDark,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    final card   = isDark ? AppColors.cardDark  : AppColors.cardLight;
    final bg2    = isDark ? AppColors.bg2Dark   : AppColors.bg2Light;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted  = isDark ? AppColors.mutedDark  : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isTop ? AppColors.coral : border, width: isTop ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          if (isTop)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                  child: Text('PALING COCOK',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5))),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.fotoKost != null
                      ? Image.network(
                          item.fotoKost!,
                          width: 80, height: 80, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 80, height: 80, color: bg2,
                              child: Icon(Icons.home_rounded, color: muted)),
                        )
                      : Container(
                          width: 80, height: 80, color: bg2,
                          child: Icon(Icons.home_rounded, color: muted)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.namaKost,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.location_on_rounded, size: 11, color: muted),
                        const SizedBox(width: 3),
                        Expanded(
                            child: Text(item.alamatKost,
                                style: TextStyle(fontSize: 11, color: muted),
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 6),
                      Text(Helpers.formatRupiah(item.hargaKost),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.coral)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Kecocokan', style: TextStyle(fontSize: 10, color: muted)),
                                    Text('$persen%',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.coral)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: persen / 100,
                                    backgroundColor: bg2,
                                    color: AppColors.coral,
                                    minHeight: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onFav,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.coralBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.favorite_rounded,
                                  color: AppColors.coral, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}