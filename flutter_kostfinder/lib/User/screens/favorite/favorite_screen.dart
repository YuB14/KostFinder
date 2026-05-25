import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../../widgets/shared_app_bar.dart';
import '../../../widgets/kost_picker_dialog.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = true;
  List<_FavData> _favs = [];
  List<dynamic> _allKosts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getFavorites(),
        ApiService.getKosts(),
      ]);
      final res = results[0];
      _allKosts = results[1];

      if (mounted) {
        setState(() {
          _favs = res.map<_FavData>((f) {
            final priceNum = f['kost_harga'] ?? 0;
            final priceStr = NumberFormat.currency(
                    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                .format(priceNum);
            return _FavData(
              id: f['id']?.toString() ?? '',
              foto: ApiService.getImageUrl(f['kost_foto']?.toString()),
              name: f['kost_nama'] ?? '-',
              location: f['kost_alamat'] ?? '-',
              price: priceStr,
              status: f['kost_status'] ?? 'Aktif',
              statusType: f['pill_class'] ?? 'green',
              hearts: f['fav_count']?.toString() ?? '0',
              isFav: true,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading favs: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _toggleFav(int i) async {
    final fav = _favs[i];
    if (!fav.isFav) return;
    setState(() => _favs[i] = _favs[i].copyWith(isFav: false));
    try {
      await ApiService.deleteFavorite(fav.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('💔 ${fav.name} dihapus dari favorit'),
          backgroundColor: AppColors.mutedLight,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
        setState(() => _favs.removeAt(i));
      }
    } catch (e) {
      setState(() => _favs[i] = _favs[i].copyWith(isFav: true));
    }
  }

  Future<void> _showAddFavoriteSheet() async {
    final selected = await KostPickerDialog.show(
      context,
      kosts: _allKosts,
      title: 'Tambah Kost Favorit',
    );
    if (selected == null || !mounted) return;

    try {
      final session = await ApiService.getSession();
      final userId = session?['user']?['id']?.toString() ??
          session?['id']?.toString() ?? '';
      final res = await ApiService.addFavorite(
        userId: userId,
        kostId: selected['id'].toString(),
      );
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('❤️ ${selected['nama_kost']} ditambahkan ke favorit!'),
          backgroundColor: AppColors.teal,
        ));
        _loadFavorites();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? 'Gagal menambahkan favorit'),
          backgroundColor: const Color(0xFFE53E3E),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final totalFav = _favs.length.toString();
    final terbaru = _favs.isNotEmpty ? _favs.first.name : '-';
    final aktif = _favs
        .where((f) => f.status.toLowerCase() == 'aktif')
        .length
        .toString();

    return Scaffold(
      appBar: const SharedAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.coral))
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              color: AppColors.coral,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Header ──
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: 'Kost ',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textColor),
                      ),
                      const TextSpan(
                        text: 'Favorit',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.coral,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  Text('Daftar kost yang kamu simpan',
                      style: TextStyle(fontSize: 13, color: muted)),
                  const SizedBox(height: 16),

                  // Stat cards
                  Row(children: [
                    _StatCard(
                        icon: Icons.favorite_rounded,
                        value: totalFav,
                        label: 'Total Favorit',
                        accentColor: AppColors.coral,
                        accentBg: AppColors.coralBg),
                    const SizedBox(width: 10),
                    _StatCard(
                        icon: Icons.emoji_events_rounded,
                        value: terbaru,
                        label: 'Terbaru',
                        accentColor: AppColors.teal,
                        accentBg: AppColors.tealBg),
                    const SizedBox(width: 10),
                    _StatCard(
                        icon: Icons.check_circle_rounded,
                        value: aktif,
                        label: 'Kost Aktif',
                        accentColor: AppColors.yellow,
                        accentBg: AppColors.yellowBg),
                  ]),
                  const SizedBox(height: 20),

                  // Tambah Favorit button
                  Row(
                    children: [
                      Text('Daftar Kost Favorit',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textColor)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _showAddFavoriteSheet,
                        icon: const Icon(Icons.add_rounded,
                            size: 16, color: Colors.white),
                        label: const Text('Tambah Favorit',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_favs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(children: [
                        const Text('💔', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 12),
                        Text('Belum ada kost favorit',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textColor)),
                        const SizedBox(height: 8),
                        Text('Cari kost dan simpan yang kamu suka!',
                            style: TextStyle(color: muted, fontSize: 13)),
                      ]),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: _favs.length,
                      itemBuilder: (_, i) => _FavCard(
                          data: _favs[i],
                          isDark: isDark,
                          onToggle: () => _toggleFav(i)),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color accentColor, accentBg;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.accentColor,
      required this.accentBg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: accentBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.mutedLight,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Fav Card ───────────────────────────────────────────────────────────────
class _FavCard extends StatelessWidget {
  final _FavData data;
  final bool isDark;
  final VoidCallback onToggle;
  const _FavCard(
      {required this.data, required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;

    return Container(
      decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
          ]),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 88,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                bg2,
                isDark ? const Color(0xFF243447) : const Color(0xFFC5D8EE)
              ])),
          child: Stack(children: [
            if (data.foto != null && data.foto!.isNotEmpty)
              Positioned.fill(
                  child: Image.network(data.foto!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.home_rounded,
                              color: muted, size: 36))))
            else
              Center(
                  child:
                      Icon(Icons.home_rounded, color: muted, size: 36)),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: data.isFav
                        ? AppColors.coral
                        : Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6)
                    ],
                  ),
                  child: Center(
                      child: Text(data.isFav ? '❤️' : '🤍',
                          style: const TextStyle(fontSize: 15))),
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data.name,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('📍 ${data.location}',
                style: TextStyle(fontSize: 10, color: muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(data.price,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coral)),
            Text('/bulan', style: TextStyle(fontSize: 10, color: muted)),
            const SizedBox(height: 8),
            Row(children: [
              _statusBadge(data.status, data.statusType, isDark, muted, bg2),
              const Spacer(),
              Text('❤️ ${data.hearts}',
                  style: TextStyle(fontSize: 10, color: muted)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _statusBadge(
      String text, String type, bool isDark, Color muted, Color bg2) {
    Color color, bg;
    switch (type) {
      case 'blue':
        color = AppColors.blue;
        bg = AppColors.blueBg;
        break;
      case 'teal':
        color = AppColors.teal;
        bg = AppColors.tealBg;
        break;
      case 'yellow':
        color = AppColors.yellow;
        bg = AppColors.yellowBg;
        break;
      case 'muted':
        color = muted;
        bg = bg2;
        break;
      case 'green':
      default:
        color = AppColors.green;
        bg = AppColors.greenBg;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(text,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _FavData {
  final String id;
  final String? foto;
  final String name, location, price, status, statusType, hearts;
  final bool isFav;
  const _FavData(
      {required this.id,
      this.foto,
      required this.name,
      required this.location,
      required this.price,
      required this.status,
      required this.statusType,
      required this.hearts,
      required this.isFav});
  _FavData copyWith({bool? isFav}) => _FavData(
      id: id,
      foto: foto,
      name: name,
      location: location,
      price: price,
      status: status,
      statusType: statusType,
      hearts: hearts,
      isFav: isFav ?? this.isFav);
}