@extends('layouts.admin')

@section('title', 'Pengguna')

@section('page_title', 'Pengguna')

@section('content')
    <div class="page active" id="page-user">
        <div class="page-header">
            <h2>Manajemen <em>Pengguna</em></h2>
            <p>Kelola semua pengguna yang terdaftar di KostFinder.</p>
        </div>

        {{-- Statistik Pengguna --}}
        <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
            <div class="stat-card teal">
                <div class="stat-icon-wrap teal">👥</div>
                <div class="stat-value" id="stat-total">0</div>
                <div class="stat-label">Total Pengguna</div>
                <div class="stat-change" id="change-total">↑ 0%</div>
            </div>
            <div class="stat-card coral">
                <div class="stat-icon-wrap coral">🟢</div>
                <div class="stat-value" id="stat-active">0</div>
                <div class="stat-label">Aktif Hari Ini</div>
                <div class="stat-change" id="change-active">↑ 0%</div>
            </div>
            <div class="stat-card yellow">
                <div class="stat-icon-wrap yellow">🆕</div>
                <div class="stat-value" id="stat-monthly">0</div>
                <div class="stat-label">Daftar Bulan Ini</div>
                <div class="stat-change" id="change-monthly">↑ 0%</div>
            </div>
        </div>

        {{-- Tabel Pengguna --}}
        <div class="table-wrap">
            <div class="table-toolbar">
                <h3>Daftar Pengguna</h3>
                <div class="table-toolbar-actions">
                    <div class="search-input-sm">
                        <span>🔍</span>
                        <input type="text" placeholder="Cari pengguna..." />
                    </div>
                    <button class="btn-sm">Filter ▾</button>
                    <button class="btn-sm primary" onclick="showToast('Fitur segera hadir!','👤')">+ Tambah</button>
                </div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Pengguna</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th>Bergabung</th>
                        <th>Favorit</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <div class="td-user">
                                <div class="td-avatar" style="background:linear-gradient(135deg,#E8430D,#FF6B3D)">AR</div>
                                <div>
                                    <div class="td-name">Aini Rahmawati</div>
                                    <div class="td-sub">Admin</div>
                                </div>
                            </div>
                        </td>
                        <td>admin@kostfinder.com</td>
                        <td><span class="pill green">● Aktif</span></td>
                        <td>12 Jan 2025</td>
                        <td>8</td>
                        <td>
                            <div class="action-btns">
                                <button class="act-btn" onclick="showToast('Edit pengguna','✏️')">✏️</button>
                                <button class="act-btn" onclick="showToast('Lihat profil','👁️')">👁️</button>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="td-user">
                                <div class="td-avatar" style="background:linear-gradient(135deg,#008F78,#00C9A7)">BS</div>
                                <div>
                                    <div class="td-name">Budi Santoso</div>
                                    <div class="td-sub">Pengguna</div>
                                </div>
                            </div>
                        </td>
                        <td>budi@mail.com</td>
                        <td><span class="pill green">● Aktif</span></td>
                        <td>3 Feb 2025</td>
                        <td>3</td>
                        <td>
                            <div class="action-btns">
                                <button class="act-btn" onclick="showToast('Edit pengguna','✏️')">✏️</button>
                                <button class="act-btn" onclick="showToast('Lihat profil','👁️')">👁️</button>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="td-user">
                                <div class="td-avatar" style="background:linear-gradient(135deg,#D48D00,#F6C244)">DS</div>
                                <div>
                                    <div class="td-name">Dewi Sartika</div>
                                    <div class="td-sub">Pengguna</div>
                                </div>
                            </div>
                        </td>
                        <td>dewi@mail.com</td>
                        <td><span class="pill yellow">● Tidak Aktif</span></td>
                        <td>20 Mar 2025</td>
                        <td>12</td>
                        <td>
                            <div class="action-btns">
                                <button class="act-btn" onclick="showToast('Edit pengguna','✏️')">✏️</button>
                                <button class="act-btn" onclick="showToast('Lihat profil','👁️')">👁️</button>
                            </div>
                        </td>
                    </tr>

                </tbody>
            </table>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        async function loadStats() {
            try {
                const response = await fetch('/api/users/stats');
                const result = await response.json();

                if (result.success) {
                    const data = result.data;

                    // 1. Update Angka Utama
                    document.getElementById('stat-total').textContent = data.total_users;
                    document.getElementById('stat-active').textContent = data.active_today;
                    document.getElementById('stat-monthly').textContent = data.new_this_month;

                    // 2. Update Persentase (Masing-masing punya datanya sendiri)
                    setChange(document.getElementById('change-total'), data.change_total);
                    setChange(document.getElementById('change-active'), data.change_active);
                    setChange(document.getElementById('change-monthly'), data.change_monthly);
                }
            } catch (error) {
                console.error('Error loadStats:', error);
            }
        }

        function setChange(el, value) {
            if (!el) return;

            // Reset style dasar (sesuaikan dengan class CSS kamu)
            el.style.padding = "2px 8px";
            el.style.borderRadius = "4px";
            el.style.fontSize = "0.85rem";
            el.style.fontWeight = "bold";
            el.style.display = "inline-block";

            if (value > 0) {
                el.innerHTML = `↑ ${value}%`;
                el.style.color = "#2ecc71";
                el.style.backgroundColor = "rgba(46, 204, 113, 0.1)"; // Background hijau transparan
            } else if (value < 0) {
                el.innerHTML = `↓ ${Math.abs(value)}%`;
                el.style.color = "#e74c3c";
                el.style.backgroundColor = "rgba(231, 76, 60, 0.1)"; // Background merah transparan
            } else {
                el.innerHTML = `↔ 0%`;
                el.style.color = "#95a5a6";
                el.style.backgroundColor = "rgba(149, 165, 166, 0.1)"; // Background abu transparan
            }
        }

        // Jalankan saat halaman dimuat
        document.addEventListener('DOMContentLoaded', () => {
            loadStats();

            // Agar "Real-time", refresh data setiap 10 detik tanpa reload halaman
            setInterval(loadStats, 10000);
        });
    </script>
@endpush
