import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'kost_screen.dart';
import 'user_screen.dart';
import '../../widgets/shared_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
      appBar: const SharedAppBar(),
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
                  TextButton(onPressed: () {}, child: const Text('Lihat semua', style: TextStyle(color: AppColors.coral, fontSize: 12, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 12),

                if (_popularKostsDynamic.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Belum ada data kost populer', style: TextStyle(color: muted, fontSize: 13))))
                else
                  ..._popularKostsDynamic.map((k) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DynamicPopularKostRow(kost: k, isDark: isDark, card: card, border: border, muted: muted, textColor: textColor),
                  )),

                const SizedBox(height: 24),

                // ── Aktivitas Terbaru ─────────────────────────────────
                Text('Aktivitas Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 12),

                if (_activitiesDynamic.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Belum ada aktivitas terbaru', style: TextStyle(color: muted, fontSize: 13))))
                else
                  Container(
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                    child: Column(
                      children: _activitiesDynamic.asMap().entries.map((e) {
                        final i = e.key; final a = e.value;
                        
                        // Parse backend color string to actual color
                        Color bgCol = AppColors.tealBg;
                        Color iconCol = AppColors.teal;
                        IconData icn = Icons.info_outline;
                        
                        final bgStr = a['bg']?.toString() ?? 'teal';
                        if (bgStr == 'coral') { bgCol = AppColors.coralBg; iconCol = AppColors.coral; }
                        else if (bgStr == 'yellow') { bgCol = AppColors.yellowBg; iconCol = AppColors.yellow; }
                        else if (bgStr == 'blue') { bgCol = AppColors.blueBg; iconCol = AppColors.blue; }
                        
                        final iconStr = a['icon']?.toString() ?? '';
                        if (iconStr == '🏘️') {
                          icn = Icons.home_work_rounded;
                        } else if (iconStr == '👤') icn = Icons.person_add_rounded;
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
                const SizedBox(height: 20),
              ],
            ),
          ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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

  @override
  Widget build(BuildContext context) {
    Color badgeBg = AppColors.tealBg;
    Color badgeColor = AppColors.teal;
    String badgeText = 'Tersedia';
    
    final bClass = kost['badge_class']?.toString() ?? 'avail';
    if (bClass == 'pop') { badgeBg = AppColors.tealBg; badgeColor = AppColors.teal; badgeText = 'Populer'; }
    else if (bClass == 'prem') { badgeBg = AppColors.yellowBg; badgeColor = AppColors.yellow; badgeText = 'Premium'; }
    else if (bClass == 'avail') { badgeBg = AppColors.blueBg; badgeColor = AppColors.blue; badgeText = 'Tersedia'; }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppColors.bg2Dark : AppColors.bg2Light, 
            borderRadius: BorderRadius.circular(10),
            image: kost['foto'] != null 
                ? DecorationImage(
                    image: NetworkImage(ApiService.getImageUrl(kost['foto']?.toString())), 
                    fit: BoxFit.cover
                  )
                : null
          ),
          child: kost['foto'] == null 
              ? Center(child: Icon(Icons.home_work_rounded, size: 24, color: badgeColor))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kost['nama']?.toString() ?? '-', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
          const SizedBox(height: 2),
          Text(kost['alamat']?.toString() ?? '-', style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 4),
          Text('Rp ${kost['harga'] ?? 0}/bln', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.coral)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(100)),
            child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
          ),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.star_rounded, size: 13, color: AppColors.yellow),
            const SizedBox(width: 3),
            Text(kost['avg_rating']?.toString() ?? '0.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
            Text(' (${kost['fav_count'] ?? 0} Fav)', style: TextStyle(fontSize: 11, color: muted)),
          ]),
        ]),
      ]),
    );
  }
}
