@extends('admin.layouts.admin')
@section('title', 'Dashboard')
@section('page_title', 'Beranda')

@section('content')
    <div class="page active" id="page-home">

        <div class="page-header">
            <h2>Selamat Datang, <em>{{ Auth::user()->name }}</em> 👋</h2>
            <p>Ringkasan aktivitas platform KostFinder hari ini.</p>
        </div>

        {{-- ─── STATISTIK ─── --}}
        <div class="stats-grid">
            <div class="stat-card coral">
                <div class="stat-icon-wrap coral">🏘️</div>
                <div class="stat-value" id="ds-total-kost">—</div>
                <div class="stat-label">Total Kost</div>
                <div class="stat-change" id="ds-kost-change">—</div>
            </div>
            <div class="stat-card teal">
                <div class="stat-icon-wrap teal">👥</div>
                <div class="stat-value" id="ds-total-user">—</div>
                <div class="stat-label">Total Pengguna</div>
                <div class="stat-change" id="ds-user-change">—</div>
            </div>
            <div class="stat-card yellow">
                <div class="stat-icon-wrap yellow">⭐</div>
                <div class="stat-value" id="ds-avg-rating">—</div>
                <div class="stat-label">Rata-rata Rating</div>
                <div class="stat-change" id="ds-rating-change">—</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-icon-wrap blue">❤️</div>
                <div class="stat-value" id="ds-total-fav">—</div>
                <div class="stat-label">Total Favorit</div>
                <div class="stat-change" id="ds-fav-change">—</div>
            </div>
        </div>

        {{-- ─── DUA KOLOM ─── --}}
        <div class="two-col">

            {{-- Chart pendaftar + distribusi kelas --}}
            <div class="widget">
                <div class="section-hd">
                    <h3>Pendaftar Pengguna</h3>
                    <a>7 Hari Terakhir</a>
                </div>
                <div class="chart-bars" id="ds-chart-bars">
                    {{-- diisi JS --}}
                    <div style="width:100%;text-align:center;color:var(--muted);font-size:13px;padding:20px 0">⏳ Memuat...
                    </div>
                </div>

                <div style="border-top:1px solid var(--border);padding-top:16px;margin-top:16px;">
                    <div class="section-hd" style="margin-bottom:12px">
                        <h3>Distribusi Kelas Kost</h3>
                    </div>
                    <div class="donut-wrap">
                        <svg width="90" height="90" viewBox="0 0 90 90" style="flex-shrink:0" id="ds-donut-svg">
                            <circle cx="45" cy="45" r="35" fill="none" stroke="var(--bg2)" stroke-width="14" />
                            {{-- segmen diisi JS --}}
                        </svg>
                        <div class="donut-legend" id="ds-donut-legend">
                            <div style="color:var(--muted);font-size:12px">⏳ Memuat...</div>
                        </div>
                    </div>
                </div>
            </div>

            {{-- Aktivitas terbaru --}}
            <div class="widget">
                <div class="section-hd">
                    <h3>Aktivitas Terbaru</h3>
                </div>
                <div class="activity-list" id="ds-activity-list">
                    <div style="text-align:center;color:var(--muted);font-size:13px;padding:20px 0">⏳ Memuat...</div>
                </div>
            </div>
        </div>

        {{-- ─── KOST TERPOPULER ─── --}}
        <div class="widget">
            <div class="section-hd">
                <h3>Kost Terpopuler</h3>
                <a href="{{ route('kost') }}">Lihat Semua →</a>
            </div>
            <div class="kost-mini-grid" id="ds-top-kost">
                <div style="text-align:center;color:var(--muted);font-size:13px;padding:20px 0">⏳ Memuat...</div>
            </div>
        </div>

    </div>
@endsection

@push('scripts')
    <script>
        /* ══════════════════════════════════════════════════
           INIT
        ══════════════════════════════════════════════════ */
        document.addEventListener('DOMContentLoaded', () => {
            loadStats();
            loadRegistrations();
            loadKelasDistribution();
            loadRecentActivity();
            loadTopKost();
        });

        /* ══════════════════════════════════════════════════
           STATISTIK UTAMA
        ══════════════════════════════════════════════════ */
        async function loadStats() {
            try {
                const res = await fetch('/api/dashboard/stats');
                const result = await res.json();
                if (!result.success) return;
                const d = result.data;

                document.getElementById('ds-total-kost').textContent = Number(d.total_kost).toLocaleString('id-ID');
                document.getElementById('ds-total-user').textContent = Number(d.total_user).toLocaleString('id-ID');
                document.getElementById('ds-avg-rating').textContent = d.avg_rating;
                document.getElementById('ds-total-fav').textContent = Number(d.total_fav).toLocaleString('id-ID');

                setStatChange('ds-kost-change', d.kost_change, 'bulan ini');
                setStatChange('ds-user-change', d.user_change, 'bulan ini');
                setStatChange('ds-rating-change', d.rating_change, 'bulan ini');
                setStatChange('ds-fav-change', d.fav_change, 'bulan ini');
            } catch (err) {
                console.error('loadStats:', err);
            }
        }

        function setStatChange(elId, value, suffix) {
            const el = document.getElementById(elId);
            const num = parseFloat(value) || 0;
            el.className = 'stat-change ' + (num > 0 ? 'up' : num < 0 ? 'down' : '');
            const arrow = num > 0 ? '↑' : num < 0 ? '↓' : '↔';
            el.textContent = `${arrow} ${Math.abs(num)}% ${suffix}`;
        }

        /* ══════════════════════════════════════════════════
           CHART BATANG — pendaftar 7 hari terakhir
        ══════════════════════════════════════════════════ */
        async function loadRegistrations() {
            try {
                const res = await fetch('/api/dashboard/registrations');
                const result = await res.json();
                if (!result.success) return;

                const { days, max } = result.data;
                const container = document.getElementById('ds-chart-bars');

                if (!days.length) {
                    container.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:13px;padding:20px 0">Belum ada data.</div>';
                    return;
                }

                // Cari hari dengan jumlah tertinggi untuk tandai "active"
                const maxCount = Math.max(...days.map(d => d.count));

                container.innerHTML = days.map(d => {
                    const pct = max > 0 && d.count > 0 ? Math.max(4, Math.round((d.count / max) * 100)) : 0;
                    const isMax = d.count === maxCount && maxCount > 0;
                    return `
                <div class="bar-wrap">
                    <div class="bar${isMax ? ' active' : ''}" style="height:${pct}%" title="${d.count} pendaftar"></div>
                    <div class="bar-label">${d.label}</div>
                </div>`;
                }).join('');
            } catch (err) {
                console.error('loadRegistrations:', err);
            }
        }

        /* ══════════════════════════════════════════════════
           DONUT — distribusi kelas kost
        ══════════════════════════════════════════════════ */
        async function loadKelasDistribution() {
            try {
                const res = await fetch('/api/dashboard/kelas-distribution');
                const result = await res.json();
                if (!result.success) return;

                const dist = result.data;
                const colors = { Ekonomi: 'var(--coral)', Standar: 'var(--teal)', Premium: 'var(--yellow)' };
                const total = dist.reduce((s, d) => s + d.count, 0);

                if (total === 0) {
                    document.getElementById('ds-donut-legend').innerHTML =
                        '<div style="color:var(--muted);font-size:12px">Belum ada data.</div>';
                    return;
                }

                // Hitung segmen SVG
                const circumference = 2 * Math.PI * 35; // r=35
                let offset = 0;
                let svgSegments = `<circle cx="45" cy="45" r="35" fill="none" stroke="var(--bg2)" stroke-width="14"/>`;

                dist.forEach(d => {
                    const arc = (d.count / total) * circumference;
                    svgSegments += `
                <circle cx="45" cy="45" r="35" fill="none"
                    stroke="${colors[d.kelas] || 'var(--muted)'}"
                    stroke-width="14"
                    stroke-dasharray="${arc.toFixed(2)} ${(circumference - arc).toFixed(2)}"
                    stroke-dashoffset="${(-offset).toFixed(2)}"
                    stroke-linecap="round"
                    transform="rotate(-90 45 45)"/>`;
                    offset += arc;
                });

                document.getElementById('ds-donut-svg').innerHTML = svgSegments;

                // Legend
                document.getElementById('ds-donut-legend').innerHTML = dist.map(d => `
            <div class="legend-item">
                <div class="legend-dot" style="background:${colors[d.kelas] || 'var(--muted)'}"></div>
                ${d.kelas} — ${d.persen}%
            </div>`).join('');
            } catch (err) {
                console.error('loadKelasDistribution:', err);
            }
        }

        /* ══════════════════════════════════════════════════
           AKTIVITAS TERBARU
        ══════════════════════════════════════════════════ */
        async function loadRecentActivity() {
            try {
                const res = await fetch('/api/dashboard/recent-activity');
                const result = await res.json();
                if (!result.success) return;

                const list = document.getElementById('ds-activity-list');
                const data = result.data;

                if (!data.length) {
                    list.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:13px;padding:20px 0">Belum ada aktivitas.</div>';
                    return;
                }

                list.innerHTML = data.map(a => `
            <div class="activity-item">
                <div class="activity-icon" style="background:var(--${a.bg}-bg)">${a.icon}</div>
                <div class="activity-body">
                    <strong>${a.title}</strong>
                    <span>${a.desc}</span>
                </div>
                <div class="activity-time">${a.time_str}</div>
            </div>`).join('');
            } catch (err) {
                console.error('loadRecentActivity:', err);
            }
        }

        /* ══════════════════════════════════════════════════
           KOST TERPOPULER
        ══════════════════════════════════════════════════ */
        async function loadTopKost() {
            try {
                const res = await fetch('/api/dashboard/top-kost');
                const result = await res.json();
                if (!result.success) return;

                const grid = document.getElementById('ds-top-kost');
                const data = result.data;

                if (!data.length) {
                    grid.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:13px;padding:20px 0">Belum ada data kost.</div>';
                    return;
                }

                const badgeLabel = { avail: 'Tersedia', pop: 'Populer', prem: 'Premium' };

                grid.innerHTML = data.map(k => {
                    // Avatar: foto jika ada, emoji default jika tidak
                    const imgHtml = k.foto
                        ? `<img src="${k.foto}" style="width:100%;height:100%;object-fit:cover;border-radius:10px;"/>`
                        : '<span style="font-size:24px">🏘️</span>';

                    return `
                <div class="kost-mini">
                    <div class="km-img" style="overflow:hidden;position:relative">${imgHtml}</div>
                    <div class="km-body">
                        <div class="km-name">${k.nama}</div>
                        <div class="km-loc">📍 ${k.alamat}</div>
                        <div class="km-price">${formatRupiah(k.harga)}/bln</div>
                    </div>
                    <span class="km-badge ${k.badge_class}">${badgeLabel[k.badge_class] ?? k.kelas}</span>
                </div>`;
                }).join('');
            } catch (err) {
                console.error('loadTopKost:', err);
            }
        }

        /* ── Utility ── */
        function formatRupiah(n) {
            return 'Rp ' + Number(n || 0).toLocaleString('id-ID');
        }
    </script>
@endpush
