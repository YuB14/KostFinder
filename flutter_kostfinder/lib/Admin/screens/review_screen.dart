import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../services/api_service.dart';
import '../../widgets/shared_app_bar.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _activeFilter = 'Semua';
  bool _isLoading = true;

  List<dynamic> _allReviews = [];
  List<dynamic> _kosts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reviews = await ApiService.getReviews();
      final kosts = await ApiService.getKosts();

      if (mounted) {
        setState(() {
          _allReviews = reviews;
          _kosts = kosts;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteReview(String id) async {
    try {
      await ApiService.deleteReview(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan berhasil dihapus', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus ulasan: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(dynamic review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ✅ FIX: pakai user_name (flat dari ReviewResource)
    final name = review['user_name'] ?? 'Pengguna';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0x1AE53E3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('🗑️', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 14),
            Text(
              'Hapus Ulasan?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
        content: Text(
          'Ulasan dari "$name" akan dihapus permanen.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(review['id'].toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showFormSheet({dynamic review}) {
    final isEdit = review != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ FIX: pakai user_name & kost_id (flat dari ReviewResource)
    String tempName = isEdit ? (review['user_name'] ?? 'Pengguna') : 'Anda (Admin)';
    String? tempKostId = isEdit ? review['kost_id']?.toString() : null;
    int tempStars = isEdit ? ((review['rating'] ?? 0) as num).toInt() : 0;
    String tempText = isEdit ? (review['komentar'] ?? '') : '';
    String tempStatus = isEdit ? (review['status'] ?? 'Menunggu') : 'Menunggu';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateSheet) {
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
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEdit ? '✏️ Edit Ulasan' : '⭐ Tambah Ulasan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Nama Pengguna (read only)
                    Text('Nama Pengguna',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: tempName),
                      readOnly: true,
                      style: TextStyle(fontSize: 13, color: muted),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bg2,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border)),
                        suffixIcon: Icon(Icons.lock_rounded, size: 16, color: muted),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Kost dropdown
                    Text('Kost',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: bg2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: tempKostId,
                          hint: Text('Pilih kost...',
                              style: TextStyle(fontSize: 13, color: muted)),
                          isExpanded: true,
                          dropdownColor: card,
                          style: TextStyle(fontSize: 13, color: textColor),
                          icon: Icon(Icons.arrow_drop_down_rounded, color: muted),
                          // ✅ Kost dropdown di-disable saat edit (kost_id tidak boleh diubah)
                          onChanged: isEdit
                              ? null
                              : (v) {
                                  if (v != null) setStateSheet(() => tempKostId = v);
                                },
                          items: _kosts.map<DropdownMenuItem<String>>((k) {
                            return DropdownMenuItem<String>(
                              value: k['id'].toString(),
                              child: Text(k['nama_kost'] ?? k['nama'] ?? 'Unknown Kost'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Rating bintang
                    Text('Rating',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setStateSheet(() => tempStars = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              index < tempStars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 28,
                              color: index < tempStars ? AppColors.yellow : muted,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Teks ulasan
                    Text('Ulasan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: tempText)
                        ..selection =
                            TextSelection.collapsed(offset: tempText.length),
                      onChanged: (v) => tempText = v,
                      maxLines: 4,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Tulis ulasan di sini...',
                        hintStyle: TextStyle(fontSize: 13, color: muted),
                        filled: true,
                        fillColor: bg2,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.coral)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status (hanya saat edit)
                    if (isEdit) ...[
                      Text('Status',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: bg2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tempStatus,
                            isExpanded: true,
                            dropdownColor: card,
                            style: TextStyle(
                                fontSize: 13,
                                color: textColor,
                                fontWeight: FontWeight.w600),
                            icon: Icon(Icons.arrow_drop_down_rounded, color: muted),
                            onChanged: (v) {
                              if (v != null) setStateSheet(() => tempStatus = v);
                            },
                            items: ['Menunggu', 'Disetujui', 'Ditolak']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(children: [
                                  if (value == 'Disetujui')
                                    const Text('✅ ')
                                  else if (value == 'Menunggu')
                                    const Text('⏳ ')
                                  else if (value == 'Ditolak')
                                    const Text('🚫 '),
                                  Text(value),
                                ]),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (tempKostId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Pilih kost terlebih dahulu.')),
                            );
                            return;
                          }
                          if (tempStars == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih rating bintang.')),
                            );
                            return;
                          }
                          if (tempText.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Tulis ulasan terlebih dahulu.')),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          try {
                            if (isEdit) {
                              await ApiService.updateReview(
                                review['id'].toString(),
                                status: tempStatus,
                                rating: tempStars,
                                komentar: tempText,
                              );
                            } else {
                              final session = await ApiService.getSession();
                              final userId =
                                  session?['user']?['id']?.toString() ?? '1';

                              await ApiService.createReview(
                                userId: userId,
                                kostId: tempKostId!,
                                rating: tempStars,
                                komentar: tempText,
                              );
                            }

                            _loadData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(isEdit
                                    ? 'Ulasan berhasil diperbarui'
                                    : 'Ulasan berhasil ditambahkan'),
                                backgroundColor: AppColors.teal,
                              ));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal menyimpan: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    final filteredReviews = _activeFilter == 'Semua'
        ? _allReviews
        : _allReviews.where((r) => r['status'] == _activeFilter).toList();

    return Scaffold(
      appBar: const SharedAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
          : RefreshIndicator(
              color: AppColors.coral,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PageHeader(
                    title: 'Manajemen ',
                    italic: 'Ulasan',
                    subtitle:
                        'Pantau dan moderasi ulasan pengguna pada seluruh kost.',
                  ),
                  const SizedBox(height: 16),

                  // Stat Cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.55,
                    children: [
                      StatCard(
                        icon: Icons.star_rounded,
                        value: _allReviews.length.toString(),
                        label: 'Total Ulasan',
                        accentColor: AppColors.yellow,
                        accentBg: AppColors.yellowBg,
                      ),
                      StatCard(
                        icon: Icons.check_circle_rounded,
                        value: _allReviews
                            .where((r) => r['status'] == 'Disetujui')
                            .length
                            .toString(),
                        label: 'Disetujui',
                        accentColor: AppColors.teal,
                        accentBg: AppColors.tealBg,
                      ),
                      StatCard(
                        icon: Icons.hourglass_top_rounded,
                        value: _allReviews
                            .where((r) => r['status'] == 'Menunggu')
                            .length
                            .toString(),
                        label: 'Menunggu',
                        accentColor: AppColors.coral,
                        accentBg: AppColors.coralBg,
                      ),
                      StatCard(
                        icon: Icons.block_rounded,
                        value: _allReviews
                            .where((r) => r['status'] == 'Ditolak')
                            .length
                            .toString(),
                        label: 'Ditolak',
                        accentColor: AppColors.blue,
                        accentBg: AppColors.blueBg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Filter + Tambah
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _activeFilter,
                            icon: const Icon(Icons.arrow_drop_down_rounded,
                                size: 20),
                            isDense: true,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor),
                            dropdownColor: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _activeFilter = v);
                              }
                            },
                            items: ['Semua', 'Disetujui', 'Menunggu', 'Ditolak']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    if (value == 'Semua')
                                      const Text('📋 ')
                                    else if (value == 'Disetujui')
                                      const Text('✅ ')
                                    else if (value == 'Menunggu')
                                      const Text('⏳ ')
                                    else if (value == 'Ditolak')
                                      const Text('🚫 '),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showFormSheet(),
                        icon: const Icon(Icons.add_rounded,
                            size: 16, color: Colors.white),
                        label: const Text('Tambah Ulasan',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (filteredReviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Tidak ada ulasan ditemukan.',
                          style: TextStyle(
                              color: AppColors.mutedLight, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...filteredReviews.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReviewCard(
                            review: r,
                            isDark: isDark,
                            onEdit: () => _showFormSheet(review: r),
                            onDelete: () => _showDeleteDialog(r),
                          ),
                        )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// Review Card
// ─────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  /// Parse gradient string dari ReviewResource → 2 warna Flutter
  List<Color> _parseGradient(String? gradientStr) {
    if (gradientStr == null || gradientStr.isEmpty) {
      return [AppColors.teal, AppColors.teal];
    }
    // Format: "linear-gradient(135deg,#RRGGBB,#RRGGBB)"
    final hexPattern = RegExp(r'#([A-Fa-f0-9]{6})');
    final matches = hexPattern.allMatches(gradientStr).toList();
    if (matches.length >= 2) {
      return [
        Color(int.parse('FF${matches[0].group(1)}', radix: 16)),
        Color(int.parse('FF${matches[1].group(1)}', radix: 16)),
      ];
    }
    if (matches.length == 1) {
      final c = Color(int.parse('FF${matches[0].group(1)}', radix: 16));
      return [c, c];
    }
    return [AppColors.teal, AppColors.teal];
  }

  @override
  Widget build(BuildContext context) {
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    // ✅ FIX: semua field sudah flat dari ReviewResource
    final String name = review['user_name'] ?? 'Pengguna';
    final String initials = review['user_initials'] ?? 'U';
    final String kostName = review['kost_name'] ?? '-';
    final int rating = (review['rating'] ?? 0) as int;
    final String status = review['status'] ?? 'Menunggu';
    final String createdAt = review['created_at'] ?? '-';
    final String komentar = review['komentar'] ?? '';
    final String? userPhoto = review['user_photo'];
    final List<Color> gradientColors = _parseGradient(review['user_color']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + nama + kost + bintang
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar — hanya tampilkan foto jika bukan default.png
              // (default.png sering 403 karena belum di-symlink storage)
              _buildAvatar(userPhoto, initials, gradientColors),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        kostName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.coral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bintang rating
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: i < rating ? AppColors.yellow : muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Komentar
          Text(
            '"$komentar"',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.text2Dark : AppColors.text2Light,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: border, height: 1),
          const SizedBox(height: 12),

          // Footer: tanggal + badge status + aksi
          Row(
            children: [
              Text(
                createdAt,
                style: TextStyle(fontSize: 11, color: muted),
              ),
              const SizedBox(width: 12),
              _statusBadge(status),
              const Spacer(),
              // Tombol edit
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 14, color: AppColors.teal),
                ),
              ),
              const SizedBox(width: 6),
              // Tombol hapus
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete_rounded,
                      size: 14, color: Color(0xFFE53E3E)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tampilkan foto hanya jika bukan default/placeholder.
  /// Kalau null, kosong, atau path mengandung 'default' → langsung inisial.
  Widget _buildAvatar(
      String? photoUrl, String initials, List<Color> gradientColors) {
    final bool usePhoto = photoUrl != null &&
        photoUrl.isNotEmpty &&
        !photoUrl.toLowerCase().contains('default');

    if (usePhoto) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          // Kalau tetap gagal load (misal 403 foto lain) → fallback inisial
          errorBuilder: (_, __, ___) =>
              _initialsAvatar(initials, gradientColors),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _initialsAvatar(initials, gradientColors),
        ),
      );
    }

    return _initialsAvatar(initials, gradientColors);
  }

  Widget _initialsAvatar(String initials, List<Color> colors) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    switch (status) {
      case 'Disetujui':
        return PillBadge.green('Disetujui');
      case 'Menunggu':
        return PillBadge.yellow('Menunggu');
      case 'Ditolak':
        return const PillBadge(
          text: 'Ditolak',
          color: Color(0xFFE53E3E),
          bgColor: Color(0x1AE53E3E),
        );
      default:
        return PillBadge.yellow(status);
    }
  }
}