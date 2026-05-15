import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../services/api_service.dart';
import 'kost_screen.dart';
import 'user_screen.dart';
import '../../widgets/shared_app_bar.dart';
import '../../screens/kost_detail_screen.dart';
import '../../screens/kost_screen.dart' as user_kost;

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateKost;

  const DashboardScreen({super.key, this.onNavigateKost});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _registrations;
  List<dynamic> _popularKostsDynamic = [];
  List<dynamic> _activitiesDynamic = [];

  String _userId = '';
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final session = await ApiService.getSession();
      if (session != null) {
        final u = session['user'] ?? session;
        _userId = u['id'].toString();
        _userName = u['name'] ?? 'Pengguna';
        _userEmail = u['email'] ?? '';
        _userRole = u['role'] ?? 'user';
        
        final photo = u['profile_picture'];
        if (photo != null) {
          _userPhotoUrl = ApiService.getImageUrl(photo.toString());
        }
      }

      // Panggil satu-satu supaya kalau satu gagal tidak semua ikut gagal
      try {
        final statsRes = await ApiService.getDashboardStats()
            .timeout(const Duration(seconds: 10));
        if (statsRes['success'] == true) _stats = statsRes['data'];
        debugPrint('✅ Stats: $_stats');
      } catch (e) { debugPrint('❌ Stats error: $e'); }

      try {
        _popularKostsDynamic = await ApiService.getDashboardTopKosts()
            .timeout(const Duration(seconds: 10));
        debugPrint('✅ Top kosts: ${_popularKostsDynamic.length}');
      } catch (e) { debugPrint('❌ Top kosts error: $e'); }

      try {
        _activitiesDynamic = await ApiService.getDashboardRecentActivity()
            .timeout(const Duration(seconds: 10));
        debugPrint('✅ Activities: ${_activitiesDynamic.length}');
      } catch (e) { debugPrint('❌ Activities error: $e'); }

      try {
        final regRes = await ApiService.getDashboardRegistrations()
            .timeout(const Duration(seconds: 10));
        if (regRes['success'] == true) _registrations = regRes['data'];
        debugPrint('✅ Registrations: $_registrations');
      } catch (e) { debugPrint('❌ Registrations error: $e'); }

    } catch (e) {
      debugPrint('❌ General error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  ImageProvider? _getProfileImage(String? pathOrUrl) {
    if (pathOrUrl == null) return null;
    if (pathOrUrl.startsWith('http')) {
      return NetworkImage(pathOrUrl);
    } else {
      return FileImage(File(pathOrUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Scaffold(
      appBar: SharedAppBar(
        onNotificationPressed: (btnContext) => _showActivitiesPopup(btnContext, isDark, card, border, muted, textColor),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
        : RefreshIndicator(
            color: AppColors.coral,
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Welcome header ─────────────────────────────────────
                PageHeader(
                  title: 'Selamat Datang, ',
                  italic: _userName.split(' ').first,
                  subtitle: 'Ringkasan aktivitas platform KostFinder hari ini. 👋',
                ),
                const SizedBox(height: 20),

                // ── Big Cards & Chart ────────────────────────────────────
                if (_stats != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserScreen())),
                          child: _buildBigCard(
                            icon: Icons.people_rounded,
                            value: _stats!['total_user']?.toString() ?? '0',
                            label: 'Total Pengguna',
                            color: AppColors.teal,
                            bgColor: AppColors.tealBg,
                            textColor: textColor,
                            cardColor: card,
                            borderColor: border,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KostScreen())),
                          child: _buildBigCard(
                            icon: Icons.home_work_rounded,
                            value: _stats!['total_kost']?.toString() ?? '0',
                            label: 'Total Kost',
                            color: AppColors.coral,
                            bgColor: AppColors.coralBg,
                            textColor: textColor,
                            cardColor: card,
                            borderColor: border,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildRegistrationChart(context, isDark, card, border, muted, textColor),
                  const SizedBox(height: 24),
                ],

                // ── Kost Terpopuler ───────────────────────────────────
                Row(children: [
                  Expanded(child: Text('Kost Terpopuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor))),
                  TextButton(onPressed: () {
                    if (widget.onNavigateKost != null) {
                      widget.onNavigateKost!();
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const user_kost.KostScreen()));
                    }
                  }, child: const Text('Lihat semua', style: TextStyle(color: AppColors.coral, fontSize: 12, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 12),

                if (_popularKostsDynamic.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Belum ada data kost populer', style: TextStyle(color: muted, fontSize: 13))))
                else
                  ..._popularKostsDynamic.map((k) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DynamicPopularKostRow(kost: k, isDark: isDark, card: card, border: border, muted: muted, textColor: textColor),
                  )),


              ],
            ),
          ),
    );
  }

  void _showActivitiesPopup(BuildContext context, bool isDark, Color card, Color border, Color muted, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: muted.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('Aktivitas Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 16),
              if (_activitiesDynamic.isEmpty)
                Padding(padding: const EdgeInsets.all(32), child: Text('Belum ada aktivitas terbaru', style: TextStyle(color: muted, fontSize: 14)))
              else
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(color: isDark ? AppColors.bg2Dark : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                      child: Column(
                        children: _activitiesDynamic.asMap().entries.map((e) {
                          final i = e.key; final a = e.value;
                          Color bgCol = AppColors.tealBg;
                          Color iconCol = AppColors.teal;
                          IconData icn = Icons.info_outline;
                          final bgStr = a['bg']?.toString() ?? 'teal';
                          if (bgStr == 'coral') { bgCol = AppColors.coralBg; iconCol = AppColors.coral; }
                          else if (bgStr == 'yellow') { bgCol = AppColors.yellowBg; iconCol = AppColors.yellow; }
                          else if (bgStr == 'blue') { bgCol = AppColors.blueBg; iconCol = AppColors.blue; }
                          final iconStr = a['icon']?.toString() ?? '';
                          if (iconStr == '🏘️') { icn = Icons.home_work_rounded; }
                          else if (iconStr == '👤') icn = Icons.person_add_rounded;
                          else if (iconStr == '⭐') icn = Icons.star_rounded;
                          else if (iconStr == '❤️') icn = Icons.favorite_rounded;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: i < _activitiesDynamic.length - 1 ? Border(bottom: BorderSide(color: border)) : null,
                            ),
                            child: Row(children: [
                              Container(width: 36, height: 36, decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(10)),
                                child: Center(child: Icon(icn, size: 17, color: iconCol))),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(a['title']?.toString() ?? '-', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                                Text(a['desc']?.toString() ?? '-', style: TextStyle(fontSize: 11, color: muted)),
                              ])),
                              Text(a['time_str']?.toString() ?? '-', style: TextStyle(fontSize: 11, color: muted)),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBigCard({
    required IconData icon, required String value, required String label,
    required Color color, required Color bgColor, required Color textColor,
    required Color cardColor, required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRegistrationChart(BuildContext context, bool isDark, Color card, Color border, Color muted, Color textColor) {
    if (_registrations == null) return const SizedBox();
    
    final days = _registrations!['days'] as List<dynamic>? ?? [];
    final maxCount = (_registrations!['max'] as num?)?.toDouble() ?? 1.0;
    
    if (days.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.blueBg, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.blue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pendaftaran Pengguna', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor)),
                  Text('7 hari terakhir', style: TextStyle(fontSize: 12, color: muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((dayData) {
                final double count = (dayData['count'] as num).toDouble();
                final String label = dayData['label'].toString();
                
                final double heightPct = maxCount == 0 ? 0 : count / maxCount;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (count > 0) 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(count.toInt().toString(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor)),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutQuart,
                      height: 80 * heightPct,
                      width: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.teal, Color(0xFF6DE8AA)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: muted)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicPopularKostRow extends StatelessWidget {
  final Map<String, dynamic> kost;
  final bool isDark;
  final Color card, border, muted, textColor;

  const _DynamicPopularKostRow({required this.kost, required this.isDark, required this.card, required this.border, required this.muted, required this.textColor});

  user_kost.KostData _parseToKostData(Map<String, dynamic> k) {
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

    return user_kost.KostData(
      iconData: icon,
      iconColor: iconColor,
      name: k['nama_kost'] ?? k['nama'] ?? '-',
      location: k['alamat_kost'] ?? k['alamat'] ?? '-',
      price: formatCurrency(k['harga_kost'] ?? k['harga']),
      tier: tier,
      tierType: tierType,
      rating: k['avg_rating']?.toString() ?? '0.0',
      reviews: k['reviews_count']?.toString() ?? k['fav_count']?.toString() ?? '0',
      tags: fasList,
      ownerNumber: k['nomor_telepon'] ?? '-',
      type: jenisKost,
      roomClass: kelas,
      description: k['deskripsi'] ?? 'Kosong',
      facilities: fasList,
      id: k['id']?.toString() ?? '',
      foto: (k['foto_kost'] != null || k['foto'] != null) ? ApiService.getImageUrl((k['foto_kost'] ?? k['foto'])?.toString()) : null,
      status: k['status']?.toString() ?? 'Aktif',
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedKost = _parseToKostData(kost);
    
    Color badgeBg = AppColors.tealBg;
    Color badgeColor = AppColors.teal;
    if (parsedKost.tierType == 'coral') { badgeBg = AppColors.coralBg; badgeColor = AppColors.coral; }
    else if (parsedKost.tierType == 'yellow') { badgeBg = AppColors.yellowBg; badgeColor = AppColors.yellow; }
    else if (parsedKost.tierType == 'blue') { badgeBg = AppColors.blueBg; badgeColor = AppColors.blue; }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KostDetailScreen(kost: parsedKost)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
        child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppColors.bg2Dark : AppColors.bg2Light, 
            borderRadius: BorderRadius.circular(10),
            image: parsedKost.foto != null 
                ? DecorationImage(
                    image: NetworkImage(parsedKost.foto!), 
                    fit: BoxFit.cover
                  )
                : null
          ),
          child: parsedKost.foto == null 
              ? Center(child: Icon(parsedKost.iconData, size: 24, color: parsedKost.iconColor))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(parsedKost.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 2),
          Text(parsedKost.location, style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 4),
          Text('${parsedKost.price}/bln', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.coral)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(100)),
            child: Text(parsedKost.tier, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
          ),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.star_rounded, size: 13, color: AppColors.yellow),
            const SizedBox(width: 3),
            Text(parsedKost.rating, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
            Text(' (${parsedKost.reviews} Fav)', style: TextStyle(fontSize: 11, color: muted)),
          ]),
        ]),
      ]),
      ),
    );
  }
}
