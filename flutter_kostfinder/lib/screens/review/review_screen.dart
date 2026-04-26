import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/kost_model.dart';
import '../../models/review_model.dart';
import '../../services/kost_service.dart';
import '../../services/review_service.dart';
import '../../utils/helpers.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<ReviewModel> _reviews = [];
  List<KostModel> _kosts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final results = await Future.wait([ReviewService.getMyReviews(), KostService.getKosts()]);
    _reviews = results[0] as List<ReviewModel>;
    _kosts = results[1] as List<KostModel>;
    if (mounted) setState(() => _loading = false);
  }

  void _openAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewFormSheet(
        kosts: _kosts,
        onSubmit: (kostId, rating, komentar) async {
          final result = await ReviewService.addReview(kostId: kostId, rating: rating, komentar: komentar);
          if (!mounted) return;
          if (result['success'] == true) {
            await _loadAll();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Ulasan berhasil ditambahkan!')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Gagal')));
          }
        },
      ),
    );
  }

  void _openEditDialog(ReviewModel review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewFormSheet(
        kosts: _kosts,
        editReview: review,
        onSubmit: (_, rating, komentar) async {
          final result = await ReviewService.updateReview(reviewId: review.id, rating: rating, komentar: komentar);
          if (!mounted) return;
          if (result['success'] == true) {
            await _loadAll();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Ulasan diperbarui!')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Gagal')));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ulasan Saya ⭐', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _openAddDialog,
              icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFFE8430D)),
              label: const Text('Tulis Ulasan', style: TextStyle(color: Color(0xFFE8430D), fontSize: 12)),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8430D)))
          : RefreshIndicator(
              onRefresh: _loadAll,
              color: const Color(0xFFE8430D),
              child: _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 12),
                          const Text('Belum ada ulasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _openAddDialog,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8430D), foregroundColor: Colors.white),
                            child: const Text('Tulis Ulasan Pertama'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final r = _reviews[i];
                        return _ReviewCard(review: r, onEdit: () => _openEditDialog(r));
                      },
                    ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onEdit;
  const _ReviewCard({required this.review, required this.onEdit});

  Color _statusColor(String s) {
    switch (s) {
      case 'Disetujui': return const Color(0xFF008F78);
      case 'Menunggu': return const Color(0xFFD48D00);
      case 'Ditolak': return const Color(0xFF6B7E94);
      default: return const Color(0xFF6B7E94);
    }
  }

  String _statusIcon(String s) {
    switch (s) {
      case 'Disetujui': return '✅';
      case 'Menunggu': return '⏳';
      case 'Ditolak': return '🚫';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.kostName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(Helpers.renderStars(review.rating), style: const TextStyle(color: Color(0xFFD48D00), fontSize: 15)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(review.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${_statusIcon(review.status)} ${review.status}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor(review.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('"${review.komentar}"', style: const TextStyle(fontSize: 13, color: Color(0xFF3D5166)), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📅 ${review.createdAt}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7E94))),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8430D).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('✏️ Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE8430D))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Form Sheet Tambah/Edit Ulasan
class _ReviewFormSheet extends StatefulWidget {
  final List<KostModel> kosts;
  final ReviewModel? editReview;
  final Function(String kostId, int rating, String komentar) onSubmit;

  const _ReviewFormSheet({required this.kosts, this.editReview, required this.onSubmit});

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  String? _selectedKostId;
  int _rating = 0;
  final _komentarCtrl = TextEditingController();
  bool _submitting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    if (widget.editReview != null) {
      _selectedKostId = widget.editReview!.kostId;
      _rating = widget.editReview!.rating;
      _komentarCtrl.text = widget.editReview!.komentar;
    }
  }

  @override
  void dispose() {
    _komentarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedKostId == null && widget.editReview == null) {
      setState(() => _error = 'Pilih kost terlebih dahulu');
      return;
    }
    if (_rating == 0) {
      setState(() => _error = 'Pilih rating bintang');
      return;
    }
    if (_komentarCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Tulis ulasan terlebih dahulu');
      return;
    }
    setState(() { _submitting = true; _error = ''; });
    await widget.onSubmit(_selectedKostId ?? widget.editReview!.kostId, _rating, _komentarCtrl.text.trim());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editReview != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(isEdit ? '✏️ Edit Ulasan' : '⭐ Tulis Ulasan', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              if (!isEdit) ...[
                const Text('Kost', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7E94))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedKostId,
                  hint: const Text('Pilih kost...', style: TextStyle(fontSize: 13)),
                  items: widget.kosts.map((k) => DropdownMenuItem(
                    value: k.id,
                    child: Text(k.namaKost, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedKostId = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
              ] else ...[
                const Text('Kost', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7E94))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                  child: Text(widget.editReview!.kostName, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7E94))),
                ),
                const SizedBox(height: 14),
              ],

              const Text('Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7E94))),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 32,
                itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Color(0xFFD48D00)),
                onRatingUpdate: (r) => setState(() => _rating = r.toInt()),
              ),
              const SizedBox(height: 14),

              const Text('Ulasan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7E94))),
              const SizedBox(height: 6),
              TextField(
                controller: _komentarCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ceritakan pengalamanmu...',
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8430D))),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE53E3E).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: Text(_error, style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12)),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8430D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}