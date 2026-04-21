@extends('layouts.admin')

@section('title', 'Data Kost')

@section('page_title', 'Data Kost')

@section('content')
<div class="page active" id="page-kost">
    <div class="page-header">
        <h2>Data <em>Kost</em></h2>
        <p>Kelola semua listing kost yang terdaftar di platform.</p>
    </div>

    {{-- Statistik Kost --}}
    <div class="stats-grid">
        <div class="stat-card coral">
            <div class="stat-icon-wrap coral">🏘️</div>
            <div class="stat-value">6</div>
            <div class="stat-label">Total Kost Aktif</div>
        </div>
        <div class="stat-card teal">
            <div class="stat-icon-wrap teal">✅</div>
            <div class="stat-value">5</div>
            <div class="stat-label">Sudah Terverifikasi</div>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon-wrap yellow">⭐</div>
            <div class="stat-value">4.87</div>
            <div class="stat-label">Avg. Rating</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-icon-wrap blue">⏳</div>
            <div class="stat-value">1</div>
            <div class="stat-label">Menunggu Review</div>
        </div>
    </div>

    {{-- Toolbar Aksi --}}
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;gap:12px;flex-wrap:wrap">
        <div style="display:flex;gap:8px">
            {{-- Tombol ini akan memicu fungsi setKostView() di script.js --}}
            <button class="btn-sm primary" id="view-grid-btn" onclick="setKostView('grid')">⊞ Grid</button>
            <button class="btn-sm" id="view-table-btn" onclick="setKostView('table')">☰ Tabel</button>
        </div>
        <div style="display:flex;gap:8px">
            <div class="search-input-sm">
                <span>🔍</span>
                <input type="text" placeholder="Cari kost..." />
            </div>
            <button class="btn-sm primary" onclick="showToast('Form tambah kost!','🏘️')">+ Tambah Kost</button>
        </div>
    </div>

    {{-- VIEW 1: GRID MODE --}}
    <div id="kost-view-grid" class="kost-grid-dash">
        <div class="kost-card-dash">
            <div class="kc-img">🌸<span class="kc-badge coral">Tersedia</span></div>
            <div class="kc-body">
                <div class="kc-name">Kost Melati Putih</div>
                <div class="kc-loc">📍 Jember Kota, Jember</div>
                <div class="kc-price">Rp 450.000<span>/bulan</span></div>
                <div class="kc-tags"><span class="kc-tag">WiFi</span><span class="kc-tag">Air Panas</span><span class="kc-tag">Parkir</span></div>
            </div>
            <div class="kc-footer">
                <div class="kc-rating"><span class="kc-stars">★★★★☆</span><strong>4.2</strong><span style="color:var(--muted);font-size:11px">(24)</span></div>
                <button class="kc-footer-btn" onclick="showToast('Edit kost','✏️')">Edit</button>
            </div>
        </div>

        <div class="kost-card-dash">
            <div class="kc-img">🏡<span class="kc-badge teal">Populer</span></div>
            <div class="kc-body">
                <div class="kc-name">Kost Griya Asri</div>
                <div class="kc-loc">📍 Sumbersari, Jember</div>
                <div class="kc-price">Rp 750.000<span>/bulan</span></div>
                <div class="kc-tags"><span class="kc-tag">WiFi</span><span class="kc-tag">AC</span><span class="kc-tag">KM Dalam</span></div>
            </div>
            <div class="kc-footer">
                <div class="kc-rating"><span class="kc-stars">★★★★★</span><strong>4.6</strong><span style="color:var(--muted);font-size:11px">(38)</span></div>
                <button class="kc-footer-btn" onclick="showToast('Edit kost','✏️')">Edit</button>
            </div>
        </div>

        <div class="kost-card-dash">
            <div class="kc-img">🏢<span class="kc-badge yellow">Premium</span></div>
            <div class="kc-body">
                <div class="kc-name">Kost Residence 88</div>
                <div class="kc-loc">📍 Patrang, Jember</div>
                <div class="kc-price">Rp 1.500.000<span>/bulan</span></div>
                <div class="kc-tags"><span class="kc-tag">WiFi</span><span class="kc-tag">AC</span><span class="kc-tag">Gym</span></div>
            </div>
            <div class="kc-footer">
                <div class="kc-rating"><span class="kc-stars">★★★★★</span><strong>4.9</strong><span style="color:var(--muted);font-size:11px">(61)</span></div>
                <button class="kc-footer-btn" onclick="showToast('Edit kost','✏️')">Edit</button>
            </div>
        </div>

        <div class="kost-card-dash">
            <div class="kc-img">🏰<span class="kc-badge yellow">Eksklusif</span></div>
            <div class="kc-body">
                <div class="kc-name">Kost Villa Elok</div>
                <div class="kc-loc">📍 Manglli, Jember</div>
                <div class="kc-price">Rp 2.200.000<span>/bulan</span></div>
                <div class="kc-tags"><span class="kc-tag">Kolam</span><span class="kc-tag">AC</span><span class="kc-tag">TV</span></div>
            </div>
            <div class="kc-footer">
                <div class="kc-rating"><span class="kc-stars">★★★★★</span><strong>5.0</strong><span style="color:var(--muted);font-size:11px">(29)</span></div>
                <button class="kc-footer-btn" onclick="showToast('Edit kost','✏️')">Edit</button>
            </div>
        </div>

    </div>

    {{-- VIEW 2: TABLE MODE (Default hidden) --}}
    <div id="kost-view-table" style="display:none" class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Nama Kost</th>
                    <th>Lokasi</th>
                    <th>Tier</th>
                    <th>Harga</th>
                    <th>Rating</th>
                    <th>Status</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><b>🌸 Kost Melati Putih</b></td>
                    <td>Jember Kota</td>
                    <td><span class="pill coral">Ekonomis</span></td>
                    <td>Rp 450.000</td>
                    <td>⭐ 4.2</td>
                    <td><span class="pill green">Aktif</span></td>
                    <td>
                        <div class="action-btns">
                            <button class="act-btn" onclick="showToast('Edit','✏️')">✏️</button>
                            <button class="act-btn" onclick="showToast('Hapus','🗑️')">🗑️</button>
                        </div>
                    </td>
                </tr>

                <tr>
                    <td><b>🏡 Kost Griya Asri</b></td>
                    <td>Sumbersari</td>
                    <td><span class="pill teal">Standar</span></td>
                    <td>Rp 750.000</td>
                    <td>⭐ 4.6</td>
                    <td><span class="pill green">Aktif</span></td>
                    <td>
                        <div class="action-btns">
                            <button class="act-btn" onclick="showToast('Edit','✏️')">✏️</button>
                            <button class="act-btn" onclick="showToast('Hapus','🗑️')">🗑️</button>
                        </div>
                    </td>
                </tr>

                <tr>
                    <td><b>🏢 Kost Residence 88</b></td>
                    <td>Sumbersari</td>
                    <td><span class="pill yellow">Premium</span></td>
                    <td>Rp 1.500.000</td>
                    <td>⭐ 4.9</td>
                    <td><span class="pill green">Aktif</span></td>
                    <td>
                        <div class="action-btns">
                            <button class="act-btn" onclick="showToast('Edit','✏️')">✏️</button>
                            <button class="act-btn" onclick="showToast('Hapus','🗑️')">🗑️</button>
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
    console.log('Halaman Data Kost Berhasil Dimuat');
</script>
@endpush
