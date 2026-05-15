import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'add_kost_screen.dart';
import 'kost_detail_screen.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../../widgets/shared_app_bar.dart';

class KostScreen extends StatefulWidget {
  const KostScreen({super.key});

  @override
  State<KostScreen> createState() => _KostScreenState();
}

class _KostScreenState extends State<KostScreen> {
  bool _isGrid = true;
  String _search = '';
  bool _isLoading = true;
  List<KostData> _kosts = [];
  bool _isAdmin = false;

  List<KostData> get _filtered => _kosts.where((k) =>
    k.name.toLowerCase().contains(_search.toLowerCase()) ||
    k.location.toLowerCase().contains(_search.toLowerCase())
  ).toList();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadRole(), _loadKosts()]);
  }

  Future<void> _loadKosts() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getKosts();
      if (mounted) {
        setState(() {
          _kosts = res.map<KostData>((k) => _parseKost(k)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  KostData _parseKost(Map<String, dynamic> k) {
    final rawHarga = k['harga_kost'] ?? k['harga'];
    final harga = double.tryParse(rawHarga?.toString() ?? '0') ?? 0.0;
    
    String kelas = 'Standar';
    if (harga <= 700000) {
      kelas = 'Ekonomi';
    } else if (harga <= 1200000) {
      kelas = 'Standar';
    } else {
      kelas = 'Premium';
    }
    String jenisKostStr = k['jenis_kost_label']?.toString() ?? k['tipe_kos_label']?.toString() ?? k['jenis_kost']?.toString() ?? k['tipe_kos']?.toString() ?? '';
    String jenisKost = 'Bebas';
    if (jenisKostStr == '1' || jenisKostStr.toLowerCase() == 'pria') jenisKost = 'Pria';
    else if (jenisKostStr == '2' || jenisKostStr.toLowerCase() == 'wanita') jenisKost = 'Wanita';
    else if (jenisKostStr == '3' || jenisKostStr.toLowerCase() == 'bebas' || jenisKostStr.toLowerCase() == 'campur') jenisKost = 'Bebas';

    Color iconColor = AppColors.teal;
    IconData icon = Icons.home_work_rounded;
    String tierType = 'teal';
    String tier = kelas;

    if (kelas == 'Ekonomi') {
      iconColor = AppColors.coral;
      icon = Icons.home_rounded;
      tierType = 'coral';
    } else if (kelas == 'Premium') {
      iconColor = AppColors.yellow;
      icon = Icons.apartment_rounded;
      tierType = 'yellow';
    }

    String formatCurrency(dynamic h) {
      final numValue = double.tryParse(h?.toString() ?? '0') ?? 0;
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(numValue);
    }
    
    final List<String> fasList = [];
    final rawFas = k['fasilitas']?.toString() ?? '';
    if (rawFas.isNotEmpty) {
      fasList.addAll(rawFas.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
    } else {
      if (k['wifi'] == 1 || k['wifi'] == '1') fasList.add('WiFi');
      if (k['ac'] == 1 || k['ac'] == '1') fasList.add('AC');
      if (k['kamar_mandi_dalam'] == 1 || k['kamar_mandi_dalam'] == '1') fasList.add('Kamar Mandi Dalam');
      if (k['parkir_motor'] == 1 || k['parkir_motor'] == '1') fasList.add('Parkir Motor');
      if (k['laundry'] == 1 || k['laundry'] == '1') fasList.add('Laundry');
      if (k['listrik'] == 1 || k['listrik'] == '1') fasList.add('Listrik');
    }

    return KostData(
      iconData: icon,
      iconColor: iconColor,
      name: k['nama_kost'] ?? '-',
      location: k['alamat_kost'] ?? '-',
      price: formatCurrency(k['harga_kost']),
      tier: tier,
      tierType: tierType,
      rating: k['avg_rating']?.toString() ?? '0.0',
      reviews: k['reviews_count']?.toString() ?? '0',
      tags: fasList,
      ownerNumber: k['nomor_telepon'] ?? '-',
      type: jenisKost,
      roomClass: kelas,
      description: k['deskripsi'] ?? 'Kosong',
      facilities: fasList,
      id: k['id']?.toString() ?? '',
      foto: ApiService.getImageUrl(k['foto_kost']?.toString()),
      status: k['status']?.toString() ?? 'Aktif',
    );
  }

  Future<void> _loadRole() async {
    final session = await ApiService.getSession();
    if (session != null) {
      final user = session['user'] ?? session;
      if (user['role'] == 'admin') {
        if (mounted) setState(() => _isAdmin = true);
      }
    }
  }

  void _deleteKost(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kost'),
        content: Text('Yakin ingin menghapus kost $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await ApiService.deleteKost(id);
                await _loadKosts();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Kost $name berhasil dihapus'),
                  backgroundColor: AppColors.teal,
                ));
              } catch (e) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Gagal menghapus kost: $e'),
                  backgroundColor: AppColors.coral,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
      appBar: const SharedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeader(
            title: 'Data ',
            italic: 'Kost',
            subtitle: 'Kelola semua listing kost yang terdaftar di platform.',
          ),
          const SizedBox(height: 16),

          // ─── Stat Cards ───────────────────────────────────────────────────
          Builder(builder: (context) {
            final int totalKost = _kosts.length;
            final int totalAktif = _kosts.where((k) => k.status.toLowerCase() == 'aktif').length;
            final double avgRating = totalKost > 0
                ? _kosts.map((k) => double.tryParse(k.rating) ?? 0.0).reduce((a, b) => a + b) / totalKost
                : 0.0;

            return GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.55,
              children: [
                StatCard(icon: Icons.home_work_rounded, value: totalKost.toString(), label: 'Total Kost', accentColor: AppColors.coral, accentBg: AppColors.coralBg),
                StatCard(icon: Icons.verified_rounded, value: totalAktif.toString(), label: 'Kost Aktif', accentColor: AppColors.teal, accentBg: AppColors.tealBg),
                StatCard(icon: Icons.star_rounded, value: avgRating.toStringAsFixed(1), label: 'Avg. Rating', accentColor: AppColors.yellow, accentBg: AppColors.yellowBg),
                StatCard(icon: Icons.hourglass_top_rounded, value: '0', label: 'Menunggu Review', accentColor: AppColors.blue, accentBg: AppColors.blueBg),
              ],
            );
          }),
          const SizedBox(height: 20),

          // ─── View Toggle + Search ─────────────────────────────────────────
          Row(children: [
            Container(
              decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                _ViewBtn(icon: Icons.grid_view_rounded, active: _isGrid, onTap: () => setState(() => _isGrid = true)),
                _ViewBtn(icon: Icons.view_list_rounded, active: !_isGrid, onTap: () => setState(() => _isGrid = false)),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(child: SearchBar2(hint: 'Cari kost...', onChanged: (v) => setState(() => _search = v))),
          ]),
          const SizedBox(height: 16),

          // ─── Kost List / Grid ─────────────────────────────────────────────
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: AppColors.coral)),
            )
          else if (_isGrid)
            GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.65,
              children: _filtered.map((k) => _KostGridCard(
                kost: k,
                isDark: isDark, card: card, border: border,
                muted: muted, textColor: textColor,
                isAdmin: _isAdmin,
                onEdit: _loadKosts,
                onDelete: () => _deleteKost(k.id, k.name),
              )).toList(),
            )
          else
            Column(children: _filtered.map((k) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _KostListCard(
                kost: k,
                isDark: isDark, card: card, border: border,
                muted: muted, textColor: textColor,
                isAdmin: _isAdmin,
                onEdit: _loadKosts,
                onDelete: () => _deleteKost(k.id, k.name),
              ),
            )).toList()),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddKostScreen()),
          );
          _loadKosts();
        },
        backgroundColor: AppColors.coral,
        icon: const Icon(Icons.home_work_rounded, color: Colors.white),
        label: const Text('Tambah Kost', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

// ─── View Toggle Button ───────────────────────────────────────────────────────

class _ViewBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ViewBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: active ? (isDark ? AppColors.cardDark : AppColors.cardLight) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)] : [],
        ),
        child: Icon(icon, size: 18, color: active ? AppColors.coral : (isDark ? AppColors.mutedDark : AppColors.mutedLight)),
      ),
    );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────

class _KostGridCard extends StatelessWidget {
  final KostData kost;
  final bool isDark, isAdmin;
  final Color card, border, muted, textColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _KostGridCard({
    required this.kost, required this.isDark, required this.card,
    required this.border, required this.muted, required this.textColor,
    required this.isAdmin, this.onEdit, this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;
    final (badgeColor, _) = _tierColors(kost.tierType);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        // ── Foto / Header ──────────────────────────────────────────────────
        SizedBox(
          height: 90,
          child: Stack(fit: StackFit.expand, children: [
            // Foto full cover, fallback gradient + icon
            if (kost.foto != null)
              Image.network(kost.foto!, fit: BoxFit.cover)
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [bg2, isDark ? const Color(0xFF243447) : const Color(0xFFC5D8EE)],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: kost.iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(kost.iconData, size: 28, color: kost.iconColor),
                  ),
                ),
              ),
            // Badge tier
            Positioned(
              top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(kost.tier, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),

        // ── Info ───────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(kost.name,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(children: [
              Icon(Icons.location_on_rounded, size: 10, color: muted),
              const SizedBox(width: 2),
              Expanded(child: Text(kost.location,
                style: TextStyle(fontSize: 10, color: muted),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
            ]),
            const SizedBox(height: 6),
            Text(kost.price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.coral)),
            Text('/bulan', style: TextStyle(fontSize: 10, color: muted)),
            const SizedBox(height: 8),
            Wrap(spacing: 4, runSpacing: 4, children: kost.tags.take(2).map((t) => KostTag(t)).toList()),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.star_rounded, size: 12, color: AppColors.yellow),
              const SizedBox(width: 3),
              Text(kost.rating, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
              Text(' (${kost.reviews})', style: TextStyle(fontSize: 10, color: muted)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              // Detail button
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KostDetailScreen(kost: kost))),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(color: AppColors.tealBg, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
                  ),
                ),
              ),
              // Edit button (admin only)
              if (isAdmin) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddKostScreen(editKost: kost)),
                    );
                    onEdit?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.coralBg, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.coral),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: isDark ? AppColors.bg2Dark : AppColors.bg2Light, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.delete_outline_rounded, size: 14, color: muted),
                  ),
                ),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── List Card ────────────────────────────────────────────────────────────────

class _KostListCard extends StatelessWidget {
  final KostData kost;
  final bool isDark, isAdmin;
  final Color card, border, muted, textColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _KostListCard({
    required this.kost, required this.isDark, required this.card,
    required this.border, required this.muted, required this.textColor,
    required this.isAdmin, this.onEdit, this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeColor, badgeBg) = _tierColors(kost.tierType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        // Foto (rectangular, full cover)
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 54, height: 54,
            child: kost.foto != null
                ? Image.network(kost.foto!, fit: BoxFit.cover)
                : Container(
                    color: kost.iconColor.withValues(alpha: 0.1),
                    child: Icon(kost.iconData, size: 26, color: kost.iconColor),
                  ),
          ),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kost.name,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          Row(children: [
            Icon(Icons.location_on_rounded, size: 11, color: muted),
            const SizedBox(width: 2),
            Expanded(child: Text(kost.location,
              style: TextStyle(fontSize: 11, color: muted),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            )),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text(kost.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.coral)),
            Text('/bln', style: TextStyle(fontSize: 10, color: muted)),
            const SizedBox(width: 8),
            Icon(Icons.star_rounded, size: 12, color: AppColors.yellow),
            const SizedBox(width: 2),
            Text(kost.rating, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
          ]),
        ])),

        // Actions
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(100)),
            child: Text(kost.tier, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            // Detail
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KostDetailScreen(kost: kost))),
              child: _actionBtn(Icons.visibility_rounded, AppColors.teal),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 6),
              // Edit
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddKostScreen(editKost: kost)),
                  );
                  onEdit?.call();
                },
                child: _actionBtn(Icons.edit_rounded, AppColors.coral),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: _actionBtn(Icons.delete_outline_rounded, muted),
              ),
            ],
          ]),
        ]),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, Color color) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(
      color: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(child: Icon(icon, size: 15, color: color)),
  );
}

// ─── Helper ───────────────────────────────────────────────────────────────────

(Color, Color) _tierColors(String type) {
  switch (type) {
    case 'teal':   return (AppColors.teal, AppColors.tealBg);
    case 'yellow': return (AppColors.yellow, AppColors.yellowBg);
    case 'blue':   return (AppColors.blue, AppColors.blueBg);
    default:       return (AppColors.coral, AppColors.coralBg);
  }
}

// ─── KostData Model ───────────────────────────────────────────────────────────

class KostData {
  final String id;
  final String? foto;
  final IconData iconData;
  final Color iconColor;
  final String name, location, price, tier, tierType, rating, reviews;
  final List<String> tags;
  final String ownerNumber, type, roomClass, description, status;
  final List<String> facilities;

  const KostData({
    required this.id, this.foto, required this.iconData, required this.iconColor,
    required this.name, required this.location, required this.price,
    required this.tier, required this.tierType, required this.rating,
    required this.reviews, required this.tags, required this.ownerNumber,
    required this.type, required this.roomClass, required this.description,
    required this.facilities, required this.status,
  });
}