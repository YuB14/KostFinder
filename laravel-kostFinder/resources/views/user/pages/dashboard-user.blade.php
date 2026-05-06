@extends('user.layouts.auth-user')
@section('title', 'Dashboard')
@section('page_title', 'Beranda')

@section('content')
    <div class="page-header">
        <h2>Halo, <em>{{ Auth::user()->name }}</em> 👋</h2>
        <p>Selamat datang kembali di KostFinder.</p>
    </div>

    {{-- STATISTIK --}}
    <div class="stats-grid">
        <div class="stat-card coral">
            <div class="stat-icon-wrap coral">❤️</div>
            <div class="stat-value" id="ds-fav">—</div>
            <div class="stat-label">Kost Favorit</div>
        </div>
        <div class="stat-card teal">
            <div class="stat-icon-wrap teal">⭐</div>
            <div class="stat-value" id="ds-review">—</div>
            <div class="stat-label">Ulasan Ditulis</div>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon-wrap yellow">🏘️</div>
            <div class="stat-value" id="ds-kost">—</div>
            <div class="stat-label">Total Kost Tersedia</div>
        </div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px">

        {{-- Favorit terbaru --}}
        <div class="widget">
            <div class="section-hd">
                <h3>❤️ Favorit Terbaru</h3>
                <a href="{{ route('user.favorite') }}" style="font-size:12px;color:var(--coral);text-decoration:none">Lihat Semua →</a>
            </div>
            <div id="ds-fav-list">
                <div style="text-align:center;color:var(--muted);font-size:13px;padding:20px 0">⏳ Memuat...</div>
            </div>
        </div>

        {{-- Ulasan terbaru --}}
        <div class="widget">
            <div class="section-hd">
                <h3>⭐ Ulasan Terbaru</h3>
                <a href="{{ route('user.review') }}" style="font-size:12px;color:var(--coral);text-decoration:none">Lihat Semua →</a>
            </div>
            <div id="ds-review-list">
                <div style="text-align:center;color:var(--muted);font-size:13px;padding:20px 0">⏳ Memuat...</div>
            </div>
        </div>
    </div>

    {{-- Rekomendasi kost --}}
    <div class="widget" style="margin-top:20px">
        <div class="section-hd">
            <h3>🏘️ Kost Populer Untukmu</h3>
            <a href="{{ route('user.kost') }}" style="font-size:12px;color:var(--coral);text-decoration:none">Lihat Semua →</a>
        </div>
        <div class="kost-grid-user" id="ds-kost-populer">
            <div style="grid-column:1/-1;text-align:center;color:var(--muted);font-size:13px;padding:20px 0">⏳ Memuat...</div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            loadDashboardStats();
            loadFavoritTerbaru();
            loadUlasanTerbaru();
            loadKostPopuler();
        });

        // ── Stats ─────────────────────────────────────────────
        async function loadDashboardStats() {
            try {
                const res    = await fetch('/api/user/stats');
                const result = await res.json();
                if (result.success) {
                    document.getElementById('ds-fav').textContent    = result.data.total_favorit ?? 0;
                    document.getElementById('ds-review').textContent = result.data.total_review  ?? 0;
                    document.getElementById('ds-kost').textContent   = result.data.total_kost    ?? 0;
                }
            } catch (err) { console.error('loadDashboardStats:', err); }
        }

        // ── Favorit terbaru ────────────────────────────────────
        async function loadFavoritTerbaru() {
            const el = document.getElementById('ds-fav-list');
            try {
                const res    = await fetch('/api/user/favorite');
                const result = await res.json();
                if (!result.success || !result.data.length) {
                    el.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:12px;padding:16px 0">Belum ada favorit.</div>';
                    return;
                }
                el.innerHTML = result.data.slice(0, 3).map(f => `
                    <div style="display:flex;align-items:center;gap:10px;padding:8px 0;border-bottom:1px solid var(--border)">
                        <div style="width:40px;height:40px;border-radius:8px;background:var(--bg2);display:flex;align-items:center;justify-content:center;font-size:20px;overflow:hidden;flex-shrink:0">
                            ${f.kost_foto ? `<img src="${f.kost_foto}" style="width:100%;height:100%;object-fit:cover;">` : '🏘️'}
                        </div>
                        <div style="min-width:0;flex:1">
                            <div style="font-size:13px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${f.kost_nama || '-'}</div>
                            <div style="font-size:11px;color:var(--muted)">📍 ${f.kost_alamat || '-'}</div>
                        </div>
                        <div style="margin-left:auto;font-size:12px;font-weight:700;color:var(--coral);white-space:nowrap">${formatRupiah(f.kost_harga)}</div>
                    </div>`).join('');
            } catch (err) {
                el.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:12px;padding:16px 0">Gagal memuat favorit.</div>';
                console.error('loadFavoritTerbaru:', err);
            }
        }

        // ── Ulasan terbaru ─────────────────────────────────────
        async function loadUlasanTerbaru() {
            const el = document.getElementById('ds-review-list');
            try {
                const res    = await fetch('/api/user/review');
                const result = await res.json();
                if (!result.success || !result.data.length) {
                    el.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:12px;padding:16px 0">Belum ada ulasan.</div>';
                    return;
                }
                el.innerHTML = result.data.slice(0, 3).map(r => `
                    <div style="padding:8px 0;border-bottom:1px solid var(--border)">
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:4px">
                            <span style="font-size:13px;font-weight:700">${r.kost_name || '-'}</span>
                            <span style="color:var(--yellow);font-size:13px">${renderStars(r.rating)}</span>
                        </div>
                        <div style="font-size:12px;color:var(--muted);overflow:hidden;text-overflow:ellipsis;white-space:nowrap">"${r.komentar || ''}"</div>
                    </div>`).join('');
            } catch (err) {
                el.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:12px;padding:16px 0">Gagal memuat ulasan.</div>';
                console.error('loadUlasanTerbaru:', err);
            }
        }

        // ── Kost populer ───────────────────────────────────────
        async function loadKostPopuler() {
            const grid = document.getElementById('ds-kost-populer');
            try {
                const res    = await fetch('/api/user/kost');
                const result = await res.json();
                if (!result.success || !result.data.length) {
                    grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;color:var(--muted);font-size:12px;padding:16px 0">Belum ada kost.</div>';
                    return;
                }
                const KELAS_LABEL = {1:'Ekonomi', 2:'Standar', 3:'Premium'};
                // Urutkan berdasarkan avg_rating tertinggi, ambil 4 teratas
                const sorted = [...result.data].sort((a,b) => (b.avg_rating||0) - (a.avg_rating||0)).slice(0, 4);
                grid.innerHTML = sorted.map(k => {
                    const kelasInt   = parseInt(k.kelas ?? 1);
                    const kelasLabel = k.kelas_label || KELAS_LABEL[kelasInt] || 'Ekonomi';
                    return `
                    <div class="kost-card-user" onclick="window.location='{{ route('user.kost') }}'">
                        <div class="kcu-img">
                            ${k.foto_kost ? `<img src="${k.foto_kost}" style="width:100%;height:100%;object-fit:cover;">` : '<span style="font-size:48px">🏘️</span>'}
                            <span class="pill ${kelasClass(kelasInt)}" style="position:absolute;top:8px;left:8px">${kelasLabel}</span>
                        </div>
                        <div class="kcu-body">
                            <div class="kcu-name">${k.nama_kost}</div>
                            <div class="kcu-loc">📍 ${k.alamat_kost || '-'}</div>
                            <div class="kcu-price">${formatRupiah(k.harga_kost)}<span>/bulan</span></div>
                        </div>
                        <div class="kcu-footer">
                            <span class="kcu-stars">${renderStars(k.avg_rating || 0)}</span>
                            <span style="font-size:11px;color:var(--muted)">${k.reviews_count || 0} ulasan</span>
                        </div>
                    </div>`;
                }).join('');
            } catch (err) {
                grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;color:var(--muted);font-size:12px;padding:16px 0">Gagal memuat kost.</div>';
                console.error('loadKostPopuler:', err);
            }
        }

        function kelasClass(n) {
            const k = parseInt(n ?? 0);
            return k === 1 ? 'green' : k === 2 ? 'blue' : k === 3 ? 'yellow' : 'muted';
        }
    </script>
@endpush
