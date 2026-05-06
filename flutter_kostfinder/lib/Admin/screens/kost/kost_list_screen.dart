import 'package:flutter/material.dart';
import '../../models/kost.dart';
import '../../services/api_service.dart';
import '../favorite/favorite_screen.dart';
import '../profile/profile_screen.dart';
import 'kost_detail_screen.dart';

class KostListScreen extends StatefulWidget {
  const KostListScreen({super.key});

  @override
  State<KostListScreen> createState() => _KostListScreenState();
}

class _KostListScreenState extends State<KostListScreen> {
  List<Kost> _kosts = [];
  List<Kost> _filtered = [];
  bool _loading = true;
  int _selectedIndex = 0;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKosts();
  }

  Future<void> _loadKosts() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.getKosts();
      final kosts = raw.map((e) => Kost.fromJson(e)).toList();
      setState(() {
        _kosts = kosts;
        _filtered = kosts;
      });
    } catch (e) {
      _showSnack('Gagal memuat kost: $e');
    }
    setState(() => _loading = false);
  }

  void _search(String q) {
    setState(() {
      _filtered = _kosts
          .where((k) =>
              k.namaKost.toLowerCase().contains(q.toLowerCase()) ||
              k.alamat.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildKostContent(),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF4CAF82).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF4CAF82)),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite, color: Color(0xFF4CAF82)),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF4CAF82)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildKostContent() {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF82)))
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadKosts,
                        color: const Color(0xFF4CAF82),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _buildKostCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF82), Color(0xFF2D8A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home_work, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text('KostFinder', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_kosts.length} Kost', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Temukan kost terbaik untukmu 🏠', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: 'Cari nama kost atau alamat...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF82)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchCtrl.clear();
                    _search('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildKostCard(Kost kost) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KostDetailScreen(kostId: kost.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF82).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_work, color: Color(0xFF4CAF82), size: 36),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kost.namaKost,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(kost.alamat,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _buildChip(kost.wifi == 'Ada' ? '📶 WiFi' : '📵 No WiFi'),
                    const SizedBox(width: 6),
                    _buildChip('📐 ${kost.ukuranKamar}'),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatHarga(kost.harga)}/bulan',
                    style: const TextStyle(
                        color: Color(0xFF4CAF82), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Kost tidak ditemukan', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      ]),
    );
  }

  String _formatHarga(double harga) {
    return harga.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
