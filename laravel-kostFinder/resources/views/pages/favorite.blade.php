@extends('layouts.admin')

@section('title', 'Favorit')

@section('page_title', 'Favorit')

@section('content')
<div class="page active" id="page-favorite">
    <div class="page-header">
        <h2>Kost <em>Favorit</em> ❤️</h2>
        <p>Daftar kost yang disimpan dan difavoritkan pengguna.</p>
    </div>

    {{-- Statistik Favorit --}}
    <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
        <div class="stat-card coral">
            <div class="stat-icon-wrap coral">❤️</div>
            <div class="stat-value">9.312</div>
            <div class="stat-label">Total Favorit</div>
            <div class="stat-change up">↑ 5.4%</div>
        </div>
        <div class="stat-card teal">
            <div class="stat-icon-wrap teal">🏆</div>
            <div class="stat-value" style="font-size:18px">Griya Asri</div>
            <div class="stat-label">Paling Banyak Difavoritkan</div>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon-wrap yellow">👤</div>
            <div class="stat-value">12</div>
            <div class="stat-label">Avg. Favorit per User</div>
        </div>
    </div>

    {{-- Grid Favorit --}}
    <div class="fav-grid">
        {{-- Card 1 --}}
        <div class="fav-card">
            <div class="fav-img">
                🌸
                <div class="fav-heart" onclick="showToast('Dihapus dari favorit','💔')">❤️</div>
            </div>
            <div class="fav-body">
                <div class="fav-name">Kost Melati Putih</div>
                <div class="fav-loc">📍 Jember Kota, Jember</div>
                <div class="fav-price">Rp 450.000<span>/bulan</span></div>
            </div>
            <div class="fav-footer">
                <span class="pill green">Tersedia</span>
                <span style="font-size:11px;color:var(--muted)">❤️ 842</span>
            </div>
        </div>

        {{-- Card 2 --}}
        <div class="fav-card">
            <div class="fav-img">
                🏡
                <div class="fav-heart" onclick="showToast('Dihapus dari favorit','💔')">❤️</div>
            </div>
            <div class="fav-body">
                <div class="fav-name">Kost Griya Asri</div>
                <div class="fav-loc">📍 Sumbersari, Jember</div>
                <div class="fav-price">Rp 750.000<span>/bulan</span></div>
            </div>
            <div class="fav-footer">
                <span class="pill teal">Populer</span>
                <span style="font-size:11px;color:var(--muted)">❤️ 2.341</span>
            </div>
        </div>

        {{-- Card 3 --}}
        <div class="fav-card">
            <div class="fav-img">
                🏢
                <div class="fav-heart" onclick="showToast('Dihapus dari favorit','💔')">❤️</div>
            </div>
            <div class="fav-body">
                <div class="fav-name">Kost Residence 88</div>
                <div class="fav-loc">📍 Patrang, Jember</div>
                <div class="fav-price">Rp 1.500.000<span>/bulan</span></div>
            </div>
            <div class="fav-footer">
                <span class="pill yellow">Premium</span>
                <span style="font-size:11px;color:var(--muted)">❤️ 1.987</span>
            </div>
        </div>

        {{-- Card 4 --}}
        <div class="fav-card">
            <div class="fav-img">
                🌿
                <div class="fav-heart" onclick="showToast('Dihapus dari favorit','💔')">❤️</div>
            </div>
            <div class="fav-body">
                <div class="fav-name">Kost Barokah</div>
                <div class="fav-loc">📍 Kaliwates, Jember</div>
                <div class="fav-price">Rp 380.000<span>/bulan</span></div>
            </div>
            <div class="fav-footer">
                <span class="pill green">Tersedia</span>
                <span style="font-size:11px;color:var(--muted)">❤️ 614</span>
            </div>
        </div>

        {{-- Card 5 --}}
        <div class="fav-card">
            <div class="fav-img">
                ⭐
                <div class="fav-heart" onclick="showToast('Dihapus dari favorit','💔')">❤️</div>
            </div>
            <div class="fav-body">
                <div class="fav-name">Kost Bintang Mas</div>
                <div class="fav-loc">📍 Tegalboto, Jember</div>
                <div class="fav-price">Rp 950.000<span>/bulan</span></div>
            </div>
            <div class="fav-footer">
                <span class="pill teal">Baru</span>
                <span style="font-size:11px;color:var(--muted)">❤️ 1.203</span>
            </div>
        </div>

        {{-- Card 6 --}}
        <div class="fav-card">
            <div class="fav-img">
                🏰
                <div class="fav-heart" onclick="showToast('Dihapus dari favorit','💔')">❤️</div>
            </div>
            <div class="fav-body">
                <div class="fav-name">Kost Villa Elok</div>
                <div class="fav-loc">📍 Mangli, Jember</div>
                <div class="fav-price">Rp 2.200.000<span>/bulan</span></div>
            </div>
            <div class="fav-footer">
                <span class="pill yellow">Eksklusif</span>
                <span style="font-size:11px;color:var(--muted)">❤️ 2.121</span>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    console.log('Halaman Favorit Berhasil Dimuat');
</script>
@endpush
