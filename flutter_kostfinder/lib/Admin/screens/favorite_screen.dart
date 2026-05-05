import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../services/api_service.dart';
import '../../widgets/shared_app_bar.dart';
import 'package:intl/intl.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = true;
  List<_FavData> _favs = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getFavorites();
      if (mounted) {
        setState(() {
          _favs = res.map<_FavData>((f) {
            final priceNum = f['kost_harga'] ?? 0;
            final priceStr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(priceNum);
            
            return _FavData(
              id: f['id']?.toString() ?? '',
              foto: ApiService.getImageUrl(f['kost_foto']?.toString()),
              emoji: '🏢',
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleFav(int i) async {
    final fav = _favs[i];
    if (fav.isFav) {
      setState(() => _favs[i] = _favs[i].copyWith(isFav: false));
      try {
        await ApiService.deleteFavorite(fav.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('💔  ${fav.name} dihapus dari favorit'),
            backgroundColor: AppColors.mutedLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ));
        }
      } catch (e) {
        setState(() => _favs[i] = _favs[i].copyWith(isFav: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      appBar: const SharedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeader(title: 'Kost ', italic: 'Favorit ❤️', subtitle: 'Daftar kost yang disimpan dan difavoritkan pengguna.'),
          const SizedBox(height: 16),

          Builder(
            builder: (context) {
              final String totalFav = _favs.length.toString();
              final String mostFav = _favs.isNotEmpty ? _favs.first.name : '-';
              final String activeFav = _favs.where((f) => f.status.toLowerCase() == 'aktif').length.toString();
              
              return Row(children: [
                Expanded(child: StatCard(icon: Icons.favorite_rounded, value: totalFav, label: 'Total Favorit', accentColor: AppColors.coral, accentBg: AppColors.coralBg)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(icon: Icons.emoji_events_rounded, value: mostFav, label: 'Terbaru', accentColor: AppColors.teal, accentBg: AppColors.tealBg)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(icon: Icons.check_circle_rounded, value: activeFav, label: 'Kost Aktif', accentColor: AppColors.yellow, accentBg: AppColors.yellowBg)),
              ]);
            }
          ),
          const SizedBox(height: 20),

          Text('Daftar Kost Favorit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.textDark : AppColors.textLight)),
          const SizedBox(height: 12),

          if (_isLoading)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.coral)))
          else
            GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.78,
              children: _favs.asMap().entries.map((e) => _FavCard(
                data: e.value,
                isDark: isDark,
                onToggle: () => _toggleFav(e.key),
              )).toList(),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final _FavData data;
  final bool isDark;
  final VoidCallback onToggle;
  const _FavCard({required this.data, required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final bg2 = isDark ? AppColors.bg2Dark : AppColors.bg2Light;

    return Container(
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image area
        Container(
          height: 88,
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [bg2, isDark ? const Color(0xFF243447) : const Color(0xFFC5D8EE)])),
          child: Stack(children: [
            if (data.foto != null && !data.foto!.toLowerCase().contains('default'))
              Positioned.fill(
                child: Image.network(
                  data.foto!, 
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(child: Text(data.emoji, style: const TextStyle(fontSize: 36))),
                ),
              )
            else
              Center(child: Text(data.emoji, style: const TextStyle(fontSize: 36))),
            Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: data.isFav ? AppColors.coral : Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                  ),
                  child: Center(child: Text(data.isFav ? '❤️' : '🤍', style: const TextStyle(fontSize: 15))),
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('📍 ${data.location}', style: TextStyle(fontSize: 10, color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(data.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.coral)),
            Text('/bulan', style: TextStyle(fontSize: 10, color: muted)),
            const SizedBox(height: 8),
            Row(children: [
              _statusBadge(data.status, data.statusType, isDark),
              const Spacer(),
              Text('❤️ ${data.hearts}', style: TextStyle(fontSize: 10, color: muted)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _statusBadge(String text, String type, bool isDark) {
    switch (type) {
      case 'blue': return PillBadge.blue(text);
      case 'teal': return PillBadge.teal(text);
      case 'yellow': return PillBadge.yellow(text);
      case 'muted': 
        return PillBadge(
          text: text, 
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight, 
          bgColor: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
        );
      case 'green':
      default: return PillBadge.green(text);
    }
  }
}

class _FavData {
  final String id;
  final String? foto;
  final String emoji, name, location, price, status, statusType, hearts;
  final bool isFav;
  const _FavData({required this.id, this.foto, required this.emoji, required this.name, required this.location, required this.price, required this.status, required this.statusType, required this.hearts, required this.isFav});
  _FavData copyWith({bool? isFav}) => _FavData(id: id, foto: foto, emoji: emoji, name: name, location: location, price: price, status: status, statusType: statusType, hearts: hearts, isFav: isFav ?? this.isFav);
}
