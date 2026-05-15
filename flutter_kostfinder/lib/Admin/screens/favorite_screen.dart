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
  List<_FavData> _filteredFavs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFavs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFavs = List.from(_favs);
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredFavs = _favs.where((f) {
          return f.name.toLowerCase().contains(lowerQuery) ||
                 f.location.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getFavorites();
      if (mounted) {
        setState(() {
          _favs = res.map<_FavData>((f) {
            final priceNum = f['kost_harga'] ?? 0;
            final priceStr = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(priceNum);

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
          _filterFavs(_searchController.text);
        });
      }
    } catch (e) {
      debugPrint('Error loading favs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleFav(int i) async {
    final fav = _filteredFavs[i];
    if (!fav.isFav) return;

    final oldFavs = List<_FavData>.from(_favs);
    final oldFiltered = List<_FavData>.from(_filteredFavs);
    
    setState(() {
      _favs.removeWhere((f) => f.id == fav.id);
      _filteredFavs.removeAt(i);
    });
    
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
      if (mounted) setState(() {
        _favs = oldFavs;
        _filteredFavs = oldFiltered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const SharedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeader(
            title: 'Kost ',
            italic: 'Favorit',
            subtitle: 'Daftar kost yang disimpan dan difavoritkan pengguna.',
          ),
          const SizedBox(height: 16),

          Builder(builder: (context) {
            final totalFav = _favs.length.toString();
            final mostFav = _favs.isNotEmpty ? _favs.first.name : '-';
            final activeFav = _favs
                .where((f) => f.status.toLowerCase() == 'aktif')
                .length
                .toString();

            return Row(children: [
              Expanded(child: StatCard(icon: Icons.favorite_rounded, value: totalFav, label: 'Total Favorit', accentColor: AppColors.coral, accentBg: AppColors.coralBg)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(icon: Icons.emoji_events_rounded, value: mostFav, label: 'Terbaru', accentColor: AppColors.teal, accentBg: AppColors.tealBg)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(icon: Icons.check_circle_rounded, value: activeFav, label: 'Kost Aktif', accentColor: AppColors.yellow, accentBg: AppColors.yellowBg)),
            ]);
          }),
          const SizedBox(height: 20),

          Text(
            'Daftar Kost Favorit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _searchController,
            onChanged: _filterFavs,
            style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight),
            decoration: InputDecoration(
              hintText: 'Cari nama atau lokasi kost...',
              hintStyle: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
              prefixIcon: Icon(Icons.search, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.coral),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: AppColors.coral)),
            )
          else if (_filteredFavs.isEmpty && _favs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Tidak ada kost favorit yang cocok dengan pencarian.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.78,
              children: _filteredFavs
                  .asMap()
                  .entries
                  .map((e) => _FavCard(
                        data: e.value,
                        isDark: isDark,
                        onToggle: () => _toggleFav(e.key),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const _SelectKostSheet(),
          ).then((_) => _loadFavorites());
        },
        backgroundColor: AppColors.coral,
        icon: const Icon(Icons.favorite_rounded, color: Colors.white),
        label: const Text('Favoritkan Kost', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _SelectKostSheet extends StatefulWidget {
  const _SelectKostSheet();

  @override
  State<_SelectKostSheet> createState() => _SelectKostSheetState();
}

class _SelectKostSheetState extends State<_SelectKostSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _kosts = [];
  List<Map<String, dynamic>> _filteredKosts = [];
  final TextEditingController _searchController = TextEditingController();
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterKosts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredKosts = List.from(_kosts);
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredKosts = _kosts.where((k) {
          final name = (k['nama_kost'] ?? '').toString().toLowerCase();
          final loc = (k['alamat_kost'] ?? '').toString().toLowerCase();
          return name.contains(lowerQuery) || loc.contains(lowerQuery);
        }).toList();
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final session = await ApiService.getSession();
      if (session != null) {
        final user = session['user'] ?? session;
        _userId = user['id']?.toString() ?? '';
      }
      final res = await ApiService.getKosts();
      if (mounted) {
        setState(() {
          _kosts = List<Map<String, dynamic>>.from(res);
          _filterKosts(_searchController.text);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addFav(Map<String, dynamic> kost) async {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu')));
      return;
    }
    
    // Close the bottom sheet first so we return to FavoriteScreen
    Navigator.pop(context); 
    
    try {
      await ApiService.addFavorite(userId: _userId, kostId: kost['id'].toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❤️ ${kost['nama_kost']} berhasil difavoritkan'), 
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambah favorit')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final text = isDark ? AppColors.textDark : AppColors.textLight;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 16),
          Text('Pilih Kost untuk Difavoritkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: text)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterKosts,
              style: TextStyle(color: text),
              decoration: InputDecoration(
                hintText: 'Cari kost...',
                hintStyle: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                prefixIcon: Icon(Icons.search, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.coral),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
                : _filteredKosts.isEmpty && _kosts.isNotEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada kost yang cocok.',
                          style: TextStyle(color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredKosts.length,
                        itemBuilder: (ctx, i) {
                          final k = _filteredKosts[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.tealBg, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.home_work_rounded, color: AppColors.teal),
                          ),
                          title: Text(k['nama_kost'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600, color: text)),
                          subtitle: Text(k['alamat_kost'] ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.favorite_border_rounded, color: AppColors.coral),
                          onTap: () => _addFav(k),
                        ),
                      );
                    },
                  ),
          ),
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
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image area
        Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bg2, isDark ? const Color(0xFF243447) : const Color(0xFFC5D8EE)],
            ),
          ),
          child: Stack(children: [
            if (data.foto != null && !data.foto!.toLowerCase().contains('default'))
              Positioned.fill(
                child: Image.network(
                  data.foto!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Center(child: Text(data.emoji, style: const TextStyle(fontSize: 36))),
                ),
              )
            else
              Center(child: Text(data.emoji, style: const TextStyle(fontSize: 36))),
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
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)
                    ],
                  ),
                  child: Center(
                    child: Text(
                      data.isFav ? '❤️' : '🤍',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data.name,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('📍 ${data.location}',
                style: TextStyle(fontSize: 10, color: muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(data.price,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.coral)),
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
      case 'blue':
        return PillBadge.blue(text);
      case 'teal':
        return PillBadge.teal(text);
      case 'yellow':
        return PillBadge.yellow(text);
      case 'muted':
        return PillBadge(
          text: text,
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
          bgColor: isDark ? AppColors.bg2Dark : AppColors.bg2Light,
        );
      case 'green':
      default:
        return PillBadge.teal(text); // FIX: PillBadge.green dihapus, pakai .teal
    }
  }
}

class _FavData {
  final String id;
  final String? foto;
  final String emoji, name, location, price, status, statusType, hearts;
  final bool isFav;

  const _FavData({
    required this.id,
    this.foto,
    required this.emoji,
    required this.name,
    required this.location,
    required this.price,
    required this.status,
    required this.statusType,
    required this.hearts,
    required this.isFav,
  });

  _FavData copyWith({bool? isFav}) => _FavData(
        id: id,
        foto: foto,
        emoji: emoji,
        name: name,
        location: location,
        price: price,
        status: status,
        statusType: statusType,
        hearts: hearts,
        isFav: isFav ?? this.isFav,
      );
}