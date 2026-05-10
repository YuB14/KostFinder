import 'package:flutter/material.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../widgets/shared_app_bar.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isLoading = true;
  List<dynamic> _myReviews = [];
  List<dynamic> _kosts = [];
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = await ApiService.getSession();
      _userId = session?['user']?['id']?.toString() ?? session?['id']?.toString() ?? '';
      final results = await Future.wait([ApiService.getReviews(), ApiService.getKosts()]);
      final allReviews = results[0] as List;
      _kosts = results[1] as List;
      _myReviews = allReviews.where((r) => r['user_id']?.toString() == _userId).toList();
    } catch (e) {
      debugPrint('Review error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showFormSheet({dynamic review}) {
    final isEdit = review != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? tempKostId = isEdit ? review['kost_id']?.toString() : null;
    int tempStars = isEdit ? ((review['rating'] ?? 0) as num).toInt() : 0;
    String tempText = isEdit ? (review['komentar'] ?? '') : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final card = isDark ? AppColors.cardDark : AppColors.cardLight;
        final border = isDark ? AppColors.borderDark : AppColors.borderLight;
        final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
        final textColor = isDark ? AppColors.textDark : AppColors.textLight;
        final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24), border: Border.all(color: border)),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(isEdit ? 'Edit Ulasan' : 'Tulis Ulasan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close_rounded, color: muted)),
                ]),
                const SizedBox(height: 20),
                Text('Kost', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tempKostId,
                      hint: Text('Pilih kost...', style: TextStyle(fontSize: 13, color: muted)),
                      isExpanded: true,
                      dropdownColor: card,
                      style: TextStyle(fontSize: 13, color: textColor),
                      icon: Icon(Icons.arrow_drop_down_rounded, color: muted),
                      onChanged: isEdit ? null : (v) { if (v != null) setSheet(() => tempKostId = v); },
                      items: _kosts.map<DropdownMenuItem<String>>((k) => DropdownMenuItem<String>(
                        value: k['id'].toString(),
                        child: Text(k['nama_kost'] ?? '-', overflow: TextOverflow.ellipsis),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                const SizedBox(height: 6),
                Row(children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setSheet(() => tempStars = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(i < tempStars ? Icons.star_rounded : Icons.star_outline_rounded, size: 30, color: i < tempStars ? AppColors.yellow : muted),
                  ),
                ))),
                const SizedBox(height: 14),
                Text('Komentar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: tempText,
                  onChanged: (v) => tempText = v,
                  maxLines: 4,
                  style: TextStyle(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Tulis ulasanmu di sini...',
                    hintStyle: TextStyle(fontSize: 13, color: muted),
                    filled: true, fillColor: bg2,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (tempKostId == null) { _showSnack('Pilih kost terlebih dahulu'); return; }
                      if (tempStars == 0) { _showSnack('Pilih rating bintang'); return; }
                      if (tempText.trim().isEmpty) { _showSnack('Tulis komentar terlebih dahulu'); return; }
                      Navigator.pop(ctx);
                      try {
                        if (isEdit) {
                          await ApiService.updateReview(review['id'].toString(), rating: tempStars, komentar: tempText);
                        } else {
                          await ApiService.createReview(userId: _userId, kostId: tempKostId!, rating: tempStars, komentar: tempText);
                        }
                        await _loadData();
                        if (mounted) _showSnack(isEdit ? 'Ulasan diperbarui' : 'Ulasan ditambahkan');
                      } catch (e) {
                        if (mounted) _showSnack('Gagal: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Kirim Ulasan', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final totalReview = _myReviews.length.toString();
    final approved = _myReviews.where((r) => r['status'] == 'Disetujui').length.toString();
    final pending = _myReviews.where((r) => r['status'] == 'Menunggu').length.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(children: [
          Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.rate_review_rounded, color: AppColors.coral, size: 18)),
          const SizedBox(width: 10),
          Text('Ulasan Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: () => _showFormSheet(),
            icon: const Icon(Icons.add_rounded, color: AppColors.coral, size: 18),
            label: const Text('Tambah', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
          : RefreshIndicator(
              color: AppColors.coral,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PageHeader(title: 'Ulasan ', italic: 'Saya', subtitle: 'Kelola ulasanmu untuk kost yang pernah ditinggali.'),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: StatCard(icon: Icons.rate_review_rounded, value: totalReview, label: 'Total Ulasan', accentColor: AppColors.coral, accentBg: AppColors.coralBg)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(icon: Icons.check_circle_rounded, value: approved, label: 'Disetujui', accentColor: AppColors.teal, accentBg: AppColors.tealBg)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(icon: Icons.hourglass_top_rounded, value: pending, label: 'Menunggu', accentColor: AppColors.yellow, accentBg: AppColors.yellowBg)),
                  ]),
                  const SizedBox(height: 20),
                  Text('Daftar Ulasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)),
                  const SizedBox(height: 12),
                  if (_myReviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(children: [
                          Icon(Icons.star_rounded, size: 56, color: muted),
                          const SizedBox(height: 12),
                          Text('Belum ada ulasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)),
                          const SizedBox(height: 8),
                          Text('Tap "+ Tambah" untuk menulis ulasan kost', style: TextStyle(color: muted, fontSize: 13)),
                        ]),
                      ),
                    )
                  else
                    ..._myReviews.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReviewCard(review: r, isDark: isDark, onEdit: () => _showFormSheet(review: r)),
                    )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  final bool isDark;
  final VoidCallback onEdit;

  const _ReviewCard({required this.review, required this.isDark, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    final int rating = (review['rating'] ?? 0) as int;
    final String status = review['status'] ?? 'Menunggu';
    final String kostName = review['kost_name'] ?? '-';
    final String komentar = review['komentar'] ?? '';
    final String createdAt = review['created_at'] ?? '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(kostName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Row(children: List.generate(5, (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14, color: i < rating ? AppColors.yellow : muted,
          ))),
        ]),
        const SizedBox(height: 8),
        Text('"$komentar"', style: TextStyle(fontSize: 12, color: isDark ? AppColors.text2Dark : AppColors.text2Light, fontStyle: FontStyle.italic, height: 1.4)),
        const SizedBox(height: 10),
        Divider(color: border, height: 1),
        const SizedBox(height: 10),
        Row(children: [
          Text(createdAt, style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(width: 8),
          _statusBadge(status),
          const Spacer(),
          if (status == 'Menunggu')
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: isDark ? AppColors.bg2Dark : AppColors.bg2Light, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.teal),
              ),
            ),
        ]),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    switch (status) {
      case 'Disetujui': return PillBadge.green('Disetujui');
      case 'Ditolak': return const PillBadge(text: 'Ditolak', color: Color(0xFFE53E3E), bgColor: Color(0x1AE53E3E));
      default: return PillBadge.yellow('Menunggu');
    }
  }
}