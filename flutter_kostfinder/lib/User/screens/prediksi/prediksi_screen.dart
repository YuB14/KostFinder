import 'package:flutter/material.dart';
import '../../services/prediksi_service.dart';
import '../../services/favorite_service.dart';
import '../../utils/helpers.dart';
import '../../../widgets/shared_app_bar.dart';
import '../../../theme/app_theme.dart';

class PrediksiScreen extends StatefulWidget {
  const PrediksiScreen({super.key});

  @override
  State<PrediksiScreen> createState() => _PrediksiScreenState();
}

class _PrediksiScreenState extends State<PrediksiScreen> {
  final _hargaCtrl = TextEditingController();
  Map<String, dynamic> _stats = {};
  bool _loadingStats = true;
  bool _loading = false;
  String _error = '';

  // ML status
  bool _mlOnline = false;
  bool _mlChecking = true;
  bool _modelTrained = false;

  // Prediction results
  PrediksiKarakteristik? _prediksi;
  String _sumber = '';
  List<PrediksiKostModel> _results = [];
  double? _maxSkor;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _checkMlHealth();
  }

  @override
  void dispose() {
    _hargaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await PrediksiService.getStats();
    if (mounted) setState(() { _stats = stats; _loadingStats = false; });
  }

  Future<void> _checkMlHealth() async {
    setState(() => _mlChecking = true);
    final result = await PrediksiService.checkHealth();
    if (mounted) {
      setState(() {
        _mlOnline = result['success'] == true && result['flask_status'] == 'online';
        _modelTrained = result['model_trained'] == true;
        _mlChecking = false;
      });
    }
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
    final harga = _parseHarga(_hargaCtrl.text);
    if (harga < 100000) {
      setState(() => _error = 'Masukkan harga minimal Rp 100.000');
      return;
    }
    if (!_mlOnline) {
      setState(() => _error = 'Server ML (Flask) tidak aktif. Jalankan python app.py');
      return;
    }
    setState(() { _loading = true; _error = ''; _prediksi = null; _results = []; });

    final result = await PrediksiService.predict(harga: harga.toDouble());

    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _prediksi = result['prediksi'] as PrediksiKarakteristik;
        _sumber = result['sumber'] as String? ?? '';
        _results = result['data'] as List<PrediksiKostModel>;
        _maxSkor = (result['meta']?['max_skor'] ?? 1).toDouble();
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Prediksi gagal';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: const SharedAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // ── ML Status Badge ──
          _buildMlStatusBadge(),
          const SizedBox(height: 12),

          // ── Stats Bar ──
          if (!_loadingStats && _stats.isNotEmpty) _buildStatsBar(),

          // ── Hero Input Card ──
          _buildInputCard(),

          // ── Prediction Characteristics Card ──
          if (_prediksi != null) ...[
            const SizedBox(height: 20),
            _buildPrediksiCard(),
          ],

          // ── Kost Recommendations ──
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildRekomendasiHeader(),
            const SizedBox(height: 12),
            ..._results.asMap().entries.map((entry) {
              final i = entry.key;
              final k = entry.value;
              final persen = _maxSkor != null && _maxSkor! > 0
                  ? ((k.skorCocok / _maxSkor!) * 100).clamp(0, 100).toInt()
                  : 0;
              return _KostCard(
                item: k,
                isTop: i == 0,
                persen: persen,
                onFav: () => _addFavorite(k.id),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ── ML Status Badge ──
  Widget _buildMlStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;
    Color dotColor;

    if (_mlChecking) {
      bgColor = const Color(0xFF6B7E94).withValues(alpha: 0.1);
      textColor = const Color(0xFF6B7E94);
      text = 'Mengecek status ML...';
      dotColor = const Color(0xFF6B7E94);
    } else if (_mlOnline) {
      bgColor = const Color(0xFF38A169).withValues(alpha: 0.1);
      textColor = const Color(0xFF38A169);
      text = '🧠 ML Server Online${_modelTrained ? ' — Model Siap' : ' — Model Belum Dilatih'}';
      dotColor = const Color(0xFF38A169);
    } else {
      bgColor = const Color(0xFFE53E3E).withValues(alpha: 0.1);
      textColor = const Color(0xFFE53E3E);
      text = '⚠️ ML Server Offline — Jalankan python app.py';
      dotColor = const Color(0xFFE53E3E);
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
            ),
            if (!_mlChecking) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _checkMlHealth,
                child: Icon(Icons.refresh_rounded, size: 14, color: textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Stats Bar ──
  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE8430D), Color(0xFFFF6B3D)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statMini('Total Kost', '${_stats['total_kost'] ?? 0}'),
          _statMini('Harga Min', Helpers.formatRupiah(_stats['harga_min'] ?? 0)),
          _statMini('Harga Max', Helpers.formatRupiah(_stats['harga_max'] ?? 0)),
          _statMini('Rata-rata', Helpers.formatRupiah(_stats['harga_avg'] ?? 0)),
        ],
      ),
    );
  }

  Widget _statMini(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
  }

  // ── Input Card (single harga field — matches Laravel) ──
  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Text('Prediksi Kost Impianmu 🤖', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                  'Masukkan harga kost yang sesuai anggaranmu.\nModel ML akan memprediksi karakteristik kost.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7E94), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Harga Input
          const Text('Harga Anggaran (Rp/bulan)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7E94))),
          const SizedBox(height: 6),
          TextField(
            controller: _hargaCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            onChanged: (v) {
              final formatted = _fmtInput(v);
              _hargaCtrl.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
            },
            onSubmitted: (_) => _predict(),
            decoration: InputDecoration(
              hintText: '1.500.000',
              hintStyle: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w400),
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF6B7E94)),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8430D), width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),

          if (_error.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFE53E3E).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Text('⚠️ ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text(_error, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_loading || !_mlOnline) ? null : _predict,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8430D),
                disabledBackgroundColor: const Color(0xFFE8430D).withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: const Color(0xFFE8430D).withValues(alpha: 0.3),
              ),
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('🤖 Prediksi Sekarang', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),

          // Steps row
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stepItem('1', 'Input harga', const Color(0xFFE8430D)),
              _stepItem('2', 'ML analisis', const Color(0xFF008F78)),
              _stepItem('3', 'Rekomendasi', const Color(0xFFD48D00)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepItem(String num, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(num, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color))),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94))),
      ],
    );
  }

  // ── Prediction Characteristics Card (matches Laravel) ──
  Widget _buildPrediksiCard() {
    final p = _prediksi!;
    final isFlask = _sumber.contains('flask');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8430D), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFFE8430D).withValues(alpha: 0.12), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Source Badge
          Row(
            children: [
              const Text('🎯 Prediksi Karakteristik', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isFlask ? const Color(0xFF008F78).withValues(alpha: 0.1) : const Color(0xFFD48D00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isFlask ? '🧠 Flask ML' : '📐 Rule-based',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isFlask ? const Color(0xFF008F78) : const Color(0xFFD48D00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Characteristic Grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _charItem('🏷️ Kelas', p.kelasLabel),
              _charItem('👥 Jenis', p.tipeKosLabel),
              _charItem('✅ Status', p.statusLabel),
              _charItem('📐 Ukuran', '${p.luasKamar} m²'),
            ],
          ),
          const SizedBox(height: 12),

          // Facilities
          const Text('🔌 Fasilitas Umum', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7E94), letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: p.fasilitasAktif.isEmpty
                ? [const Text('—', style: TextStyle(color: Color(0xFF6B7E94), fontSize: 12))]
                : p.fasilitasAktif.map((f) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8430D).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(f, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE8430D))),
                  )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _charItem(String label, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 74) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7E94), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ── Recommendations Header ──
  Widget _buildRekomendasiHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('🏘️ Kost Rekomendasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        Text('${_results.length} kost ditemukan', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7E94))),
      ],
    );
  }

  Future<void> _addFavorite(String kostId) async {
    final r = await FavoriteService.addFavorite(kostId);
    if (!mounted) return;
    final msg = r['status'] == 409
        ? 'Sudah ada di favorit ⚠️'
        : r['success'] == true
            ? 'Ditambahkan ke favorit! ❤️'
            : 'Gagal menambahkan';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ── Kost Recommendation Card ──
class _KostCard extends StatelessWidget {
  final PrediksiKostModel item;
  final bool isTop;
  final int persen;
  final VoidCallback onFav;

  const _KostCard({required this.item, required this.isTop, required this.persen, required this.onFav});

  @override
  Widget build(BuildContext context) {
    final kelasColor = item.kelas == 3
        ? const Color(0xFFD48D00)
        : item.kelas == 2
            ? const Color(0xFF008F78)
            : const Color(0xFF6B7E94);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isTop ? const Color(0xFFE8430D) : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          if (isTop)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFE8430D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(child: Text('🏆 PALING COCOK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))),
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
                          errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: const Color(0xFFEAEFF5), child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94))),
                        )
                      : Container(width: 80, height: 80, color: const Color(0xFFEAEFF5), child: const Icon(Icons.home_rounded, color: Color(0xFF6B7E94))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kelas + Jenis badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(item.kelasLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kelasColor)),
                          ),
                          const SizedBox(width: 4),
                          Text(item.tipeKosLabel, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E94))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.namaKost, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('📍 ${item.alamatKost}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7E94)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(Helpers.formatRupiah(item.hargaKost), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFE8430D))),
                      const SizedBox(height: 6),
                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Kecocokan', style: TextStyle(fontSize: 10, color: Color(0xFF6B7E94))),
                                    Text('$persen%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE8430D))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: persen / 100,
                                    backgroundColor: const Color(0xFFEAEFF5),
                                    color: const Color(0xFFE8430D),
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
                                color: const Color(0xFFE8430D).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.favorite_rounded, color: Color(0xFFE8430D), size: 18),
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