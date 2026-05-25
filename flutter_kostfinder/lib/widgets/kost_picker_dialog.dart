import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable dialog that shows a searchable list of kosts.
/// Returns the selected kost map via Navigator.pop().
class KostPickerDialog extends StatefulWidget {
  final List<dynamic> kosts;
  final String? selectedKostId;
  final String title;

  const KostPickerDialog({
    super.key,
    required this.kosts,
    this.selectedKostId,
    this.title = 'Pilih Kost',
  });

  /// Show the picker and return selected kost map or null.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required List<dynamic> kosts,
    String? selectedKostId,
    String title = 'Pilih Kost',
  }) async {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KostPickerDialog(
        kosts: kosts,
        selectedKostId: selectedKostId,
        title: title,
      ),
    );
  }

  @override
  State<KostPickerDialog> createState() => _KostPickerDialogState();
}

class _KostPickerDialogState extends State<KostPickerDialog> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<dynamic> get _filtered {
    if (_search.isEmpty) return widget.kosts;
    final q = _search.toLowerCase();
    return widget.kosts.where((k) {
      final nama = (k['nama_kost'] ?? k['nama'] ?? '').toString().toLowerCase();
      final alamat = (k['alamat_kost'] ?? '').toString().toLowerCase();
      return nama.contains(q) || alamat.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.coralBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_work_rounded, color: AppColors.coral, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(fontSize: 13, color: textColor),
              decoration: InputDecoration(
                hintText: 'Cari nama kost atau alamat...',
                hintStyle: TextStyle(fontSize: 13, color: muted),
                prefixIcon: Icon(Icons.search_rounded, color: muted, size: 20),
                filled: true,
                fillColor: card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.coral),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} kost ditemukan',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏠', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text('Kost tidak ditemukan', style: TextStyle(color: muted, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final k = _filtered[i] as Map<String, dynamic>;
                      final id = k['id']?.toString() ?? '';
                      final nama = k['nama_kost'] ?? k['nama'] ?? '-';
                      final alamat = k['alamat_kost'] ?? '-';
                      final isSelected = id == widget.selectedKostId;

                      return GestureDetector(
                        onTap: () => Navigator.pop(context, k),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.coralBg : card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.coral : border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: bg2,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.home_rounded, color: AppColors.coral, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? AppColors.coral : textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '📍 $alamat',
                                      style: TextStyle(fontSize: 11, color: muted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.coral, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
