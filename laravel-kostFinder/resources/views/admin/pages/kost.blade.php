@extends('admin.layouts.admin')
@section('title', 'Data Kost')
@section('page_title', 'Data Kost')

@section('content')
<div class="page active" id="page-kost">
    <div class="page-header">
        <h2>Data <em>Kost</em></h2>
        <p>Kelola semua listing kost yang terdaftar di platform.</p>
    </div>

    <div class="stats-grid">
        <div class="stat-card coral"><div class="stat-icon-wrap coral">🏘️</div><div class="stat-value" id="stat-total-kost">—</div><div class="stat-label">Total Kost</div></div>
        <div class="stat-card teal"><div class="stat-icon-wrap teal">⭐</div><div class="stat-value" id="stat-rating-tinggi">—</div><div class="stat-label">Rating di Atas ★4</div></div>
        <div class="stat-card yellow"><div class="stat-icon-wrap yellow">📊</div><div class="stat-value" id="stat-avg-rating">—</div><div class="stat-label">Avg. Rating</div></div>
        <div class="stat-card blue"><div class="stat-icon-wrap blue">⏳</div><div class="stat-value" id="stat-belum-review">—</div><div class="stat-label">Belum Ada Review</div></div>
    </div>

    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;gap:12px;flex-wrap:wrap">
        <div style="display:flex;gap:8px">
            <button class="btn-sm primary" id="view-grid-btn" onclick="setKostView('grid')">⊞ Grid</button>
            <button class="btn-sm" id="view-table-btn" onclick="setKostView('table')">☰ Tabel</button>
        </div>
        <div style="display:flex;gap:8px;align-items:center">
            <div class="search-input-sm"><span>🔍</span><input type="text" id="search-kost" placeholder="Cari nama, alamat, fasilitas..."/></div>
            <div class="filter-wrap">
                <button class="btn-sm" onclick="toggleFilter('filter-kost')">Filter ▾</button>
                <div class="filter-dropdown" id="filter-kost">
                    <div class="filter-opt active" onclick="setKostFilter('semua',this)">🏘️ Semua Kelas</div>
                    <div class="filter-sep"></div>
                    <div class="filter-opt" onclick="setKostFilter('1',this)">💚 Ekonomi</div>
                    <div class="filter-opt" onclick="setKostFilter('2',this)">🔵 Standar</div>
                    <div class="filter-opt" onclick="setKostFilter('3',this)">⭐ Premium</div>
                </div>
            </div>
            <button class="btn-sm" onclick="openCsvImport()" style="border-color:var(--teal);color:var(--teal)">📄 Import CSV</button>
            <button class="btn-sm primary" onclick="openAddKost()">+ Tambah Kost</button>
        </div>
    </div>

    <div id="kost-view-grid" class="kost-grid-dash">
        <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:14px">⏳ Memuat data kost...</div>
    </div>
    <div id="kost-view-table" style="display:none" class="table-wrap">
        <table style="min-width:1200px"><thead><tr>
            <th>Foto Kost</th>
            <th>Nama Kost</th>
            <th>Alamat Kost</th>
            <th>Wilayah Kost</th>
            <th>Kode Lokasi</th>
            <th>Kelas</th>
            <th>Tipe Kost</th>
            <th>Harga</th>
            <th>Status</th>
            <th>No Telepon</th>
            <th>Luas Kamar</th>
            <th>Fasilitas</th>
            <th>Deskripsi</th>
            <th>Aksi</th>
        </tr></thead>
        <tbody id="kost-table-body"><tr><td colspan="14" style="text-align:center;padding:32px;color:var(--muted)">⏳ Memuat data...</td></tr></tbody></table>
    </div>
</div>

{{-- MODAL TAMBAH --}}
<div class="modal-overlay" id="modal-kost-add" onclick="closeModalOutside(event,this)">
    <div class="modal-box">
        <div class="modal-header"><h3>🏘️ Tambah Kost</h3><button class="modal-close" onclick="closeModal('modal-kost-add')">✕</button></div>
        <div class="modal-body">
            <div class="mform-group"><label>Foto Kost</label>
                <div class="kost-upload-area">
                    <input type="file" accept="image/*" id="kadd-photo-input" onchange="previewKostPhoto('kadd')"/>
                    <div class="kost-photo-preview">
                        <div class="kost-photo-placeholder" id="kadd-placeholder"><span style="font-size:32px">🏘️</span><p style="font-size:12px;color:var(--muted);margin-top:6px">Klik atau seret foto kost</p><p style="font-size:11px;color:var(--muted);margin-top:2px">JPG, PNG · maks. 5 MB</p></div>
                        <img id="kadd-photo-img" alt="" style="display:none;width:100%;height:100%;object-fit:cover;border-radius:10px"/>
                    </div>
                    <button class="kost-remove-photo" id="kadd-remove-btn" onclick="removeKostPhoto('kadd',event)" style="display:none" type="button">✕ Hapus Foto</button>
                </div>
            </div>
            <div class="mform-group"><label>Nama Kost</label><input type="text" id="kadd-nama" placeholder="Nama kost..."/></div>
            <div class="mform-row">
                <div class="mform-group"><label>Alamat / Lokasi</label><input type="text" id="kadd-lokasi" placeholder="Jl. Contoh No.1, Sumbersari"/></div>
                <div class="mform-group"><label>Kelas <span style="font-size:10px;color:var(--muted);font-weight:400">(otomatis dari harga)</span></label>
                    <input type="hidden" id="kadd-tier-val" value="1"/>
                    <div id="kadd-tier-display" style="display:flex;align-items:center;gap:10px;padding:10px 14px;border:1.5px solid var(--border);border-radius:10px;background:var(--bg2);cursor:default;user-select:none">
                        <span id="kadd-tier-badge" style="display:inline-flex;align-items:center;gap:6px;padding:4px 14px;border-radius:100px;font-size:12px;font-weight:700;background:rgba(229,115,115,.12);color:#e57373">💚 Ekonomi</span>
                        <span style="font-size:12px;color:var(--muted)">Isi harga untuk menentukan kelas otomatis</span>
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Tipe Kos</label>
                    <div class="csel-wrap" id="csel-kadd-jenis">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kadd-jenis')"><span class="csel-val">3</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt" data-val="1" onclick="pickCsel('csel-kadd-jenis',this)">👨 Pria</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kadd-jenis',this)">👩 Wanita</div>
                            <div class="csel-opt active" data-val="3" onclick="pickCsel('csel-kadd-jenis',this)">👥 Campur</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>Harga / Bulan</label>
                    <div style="position:relative">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-size:12px;color:var(--muted);font-weight:600;pointer-events:none">Rp</span>
                        <input type="text" id="kadd-harga" placeholder="500.000" inputmode="numeric"
                            style="padding-left:34px"
                            oninput="formatHargaInput(this);autoUpdateKelas('kadd')" />
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Status</label>
                    <div class="csel-wrap" id="csel-kadd-status">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kadd-status')"><span class="csel-val">1</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kadd-status',this)">✅ Tersedia</div>
                            <div class="csel-opt" data-val="0" onclick="pickCsel('csel-kadd-status',this)">🔴 Penuh</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kadd-status',this)">🛏️ 2 Kamar Sisa</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kadd-status',this)">🛏️ 3 Kamar Sisa</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kadd-status',this)">🛏️ 4 Kamar Sisa</div>
                            <div class="csel-opt" data-val="5" onclick="pickCsel('csel-kadd-status',this)">🛏️ 5 Kamar Sisa</div>
                            <div class="csel-opt" data-val="6" onclick="pickCsel('csel-kadd-status',this)">🛏️ 6 Kamar Sisa</div>
                            <div class="csel-opt" data-val="7" onclick="pickCsel('csel-kadd-status',this)">🛏️ 7 Kamar Sisa</div>
                            <div class="csel-opt" data-val="8" onclick="pickCsel('csel-kadd-status',this)">🛏️ 8 Kamar Sisa</div>
                            <div class="csel-opt" data-val="9" onclick="pickCsel('csel-kadd-status',this)">🛏️ 9 Kamar Sisa</div>
                            <div class="csel-opt" data-val="10" onclick="pickCsel('csel-kadd-status',this)">🛏️ 10 Kamar Sisa</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>No. Telepon Pemilik</label><input type="tel" id="kadd-telepon" placeholder="08xxxxxxxxxx"/></div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Luas Kamar (m²)</label><input type="number" id="kadd-luas" placeholder="12" min="1" step="0.5"/></div>
                <div class="mform-group"><label>Kode Lokasi</label>
                    <div class="csel-wrap" id="csel-kadd-kodelok">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kadd-kodelok')"><span class="csel-val">1</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kadd-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kadd-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kadd-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kadd-kodelok',this)">🚌 Dekat Transportasi</div>
                            <div class="csel-opt" data-val="5" onclick="pickCsel('csel-kadd-kodelok',this)">🏡 Perumahan</div>
                            <div class="csel-opt" data-val="6" onclick="pickCsel('csel-kadd-kodelok',this)">🛍️ Dekat Pasar</div>
                            <div class="csel-opt" data-val="7" onclick="pickCsel('csel-kadd-kodelok',this)">🏭 Kawasan Industri</div>
                            <div class="csel-opt" data-val="8" onclick="pickCsel('csel-kadd-kodelok',this)">🛣️ Pinggir Jalan Utama</div>
                            <div class="csel-opt" data-val="9" onclick="pickCsel('csel-kadd-kodelok',this)">⛰️ Pedesaan/Wisata</div>
                            <div class="csel-opt" data-val="10" onclick="pickCsel('csel-kadd-kodelok',this)">📍 Lainnya</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mform-group"><label>Wilayah / Kota</label>
                <div class="csel-wrap" id="csel-kadd-wilayah" style="position:relative">
                    <div class="csel-trigger" onclick="toggleCselSearch('csel-kadd-wilayah')" style="display:flex;align-items:center;gap:6px">
                        <span class="csel-val" style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">-- Pilih Wilayah --</span>
                        <span>▾</span>
                    </div>
                    <div class="csel-dropdown" style="padding:0">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border);position:sticky;top:0;background:var(--card);z-index:2;border-radius:6px 6px 0 0">
                            <input type="text" id="kadd-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kadd')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kadd-wilayah-list" style="padding:4px"></div>
                    </div>
                </div>
                <input type="hidden" id="kadd-wilayah-id" />
            </div>
            <div class="mform-group"><label>Fasilitas</label>
                <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:10px;background:var(--bg2);border:1.5px solid var(--border);border-radius:12px;padding:16px">
                    <label class="fas-toggle"><input type="checkbox" id="kadd-listrik" value="1" checked><div class="fas-box"><span>⚡</span> Listrik</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kadd-ac" value="1"><div class="fas-box"><span>❄️</span> AC</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kadd-kmd" value="1"><div class="fas-box"><span>🚿</span> KM Dalam</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kadd-parkir" value="1"><div class="fas-box"><span>🏍️</span> Parkir Motor</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kadd-laundry" value="1"><div class="fas-box"><span>👕</span> Laundry</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kadd-wifi" value="1"><div class="fas-box"><span>📶</span> WiFi</div></label>
                </div>
            </div>
            <div class="mform-group"><label>Deskripsi</label><textarea id="kadd-deskripsi" placeholder="Deskripsi kost..." rows="3" style="width:100%;border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;font-size:13px;font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);resize:vertical"></textarea></div>
            <div id="kadd-error" class="form-error-msg" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn-sm" onclick="closeModal('modal-kost-add')">Batal</button>
            <button class="btn-sm primary" id="btn-kadd-save" onclick="submitAddKost()"><span id="btn-kadd-label">Simpan</span></button>
        </div>
    </div>
</div>

{{-- MODAL EDIT --}}
<div class="modal-overlay" id="modal-kost-edit" onclick="closeModalOutside(event,this)">
    <div class="modal-box">
        <div class="modal-header"><h3>✏️ Edit Kost</h3><button class="modal-close" onclick="closeModal('modal-kost-edit')">✕</button></div>
        <div class="modal-body">
            <input type="hidden" id="kedit-id"/>
            <div class="mform-group"><label>Foto Kost</label>
                <div class="kost-upload-area">
                    <input type="file" accept="image/*" id="kedit-photo-input" onchange="previewKostPhoto('kedit')"/>
                    <div class="kost-photo-preview">
                        <div class="kost-photo-placeholder" id="kedit-placeholder"><span style="font-size:32px">🏘️</span><p style="font-size:12px;color:var(--muted);margin-top:6px">Klik atau seret foto kost</p><p style="font-size:11px;color:var(--muted);margin-top:2px">JPG, PNG · maks. 5 MB</p></div>
                        <img id="kedit-photo-img" alt="" style="display:none;width:100%;height:100%;object-fit:cover;border-radius:10px"/>
                    </div>
                    <button class="kost-remove-photo" id="kedit-remove-btn" onclick="removeKostPhoto('kedit',event)" style="display:none" type="button">✕ Hapus Foto</button>
                </div>
            </div>
            <div class="mform-group"><label>Nama Kost</label><input type="text" id="kedit-nama"/></div>
            <div class="mform-row">
                <div class="mform-group"><label>Alamat / Lokasi</label><input type="text" id="kedit-lokasi"/></div>
                <div class="mform-group"><label>Kelas <span style="font-size:10px;color:var(--muted);font-weight:400">(otomatis dari harga)</span></label>
                    <input type="hidden" id="kedit-tier-val" value="1"/>
                    <div id="kedit-tier-display" style="display:flex;align-items:center;gap:10px;padding:10px 14px;border:1.5px solid var(--border);border-radius:10px;background:var(--bg2);cursor:default;user-select:none">
                        <span id="kedit-tier-badge" style="display:inline-flex;align-items:center;gap:6px;padding:4px 14px;border-radius:100px;font-size:12px;font-weight:700;background:rgba(229,115,115,.12);color:#e57373">💚 Ekonomi</span>
                        <span style="font-size:12px;color:var(--muted)">Sesuai harga yang diinput</span>
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Tipe Kos</label>
                    <div class="csel-wrap" id="csel-kedit-jenis">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kedit-jenis')"><span class="csel-val">3</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt" data-val="1" onclick="pickCsel('csel-kedit-jenis',this)">👨 Pria</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kedit-jenis',this)">👩 Wanita</div>
                            <div class="csel-opt active" data-val="3" onclick="pickCsel('csel-kedit-jenis',this)">👥 Campur</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>Harga / Bulan</label>
                    <div style="position:relative">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-size:12px;color:var(--muted);font-weight:600;pointer-events:none">Rp</span>
                        <input type="text" id="kedit-harga" placeholder="500.000" inputmode="numeric"
                            style="padding-left:34px"
                            oninput="formatHargaInput(this);autoUpdateKelas('kedit')" />
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Status</label>
                    <div class="csel-wrap" id="csel-kedit-status">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kedit-status')"><span class="csel-val">1</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kedit-status',this)">✅ Tersedia</div>
                            <div class="csel-opt" data-val="0" onclick="pickCsel('csel-kedit-status',this)">🔴 Penuh</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kedit-status',this)">🛏️ 2 Kamar Sisa</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kedit-status',this)">🛏️ 3 Kamar Sisa</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kedit-status',this)">🛏️ 4 Kamar Sisa</div>
                            <div class="csel-opt" data-val="5" onclick="pickCsel('csel-kedit-status',this)">🛏️ 5 Kamar Sisa</div>
                            <div class="csel-opt" data-val="6" onclick="pickCsel('csel-kedit-status',this)">🛏️ 6 Kamar Sisa</div>
                            <div class="csel-opt" data-val="7" onclick="pickCsel('csel-kedit-status',this)">🛏️ 7 Kamar Sisa</div>
                            <div class="csel-opt" data-val="8" onclick="pickCsel('csel-kedit-status',this)">🛏️ 8 Kamar Sisa</div>
                            <div class="csel-opt" data-val="9" onclick="pickCsel('csel-kedit-status',this)">🛏️ 9 Kamar Sisa</div>
                            <div class="csel-opt" data-val="10" onclick="pickCsel('csel-kedit-status',this)">🛏️ 10 Kamar Sisa</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>No. Telepon Pemilik</label><input type="tel" id="kedit-telepon" placeholder="08xxxxxxxxxx"/></div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Luas Kamar (m²)</label><input type="number" id="kedit-luas" placeholder="12" min="1" step="0.5"/></div>
                <div class="mform-group"><label>Kode Lokasi</label>
                    <div class="csel-wrap" id="csel-kedit-kodelok">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kedit-kodelok')"><span class="csel-val">1</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kedit-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kedit-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kedit-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kedit-kodelok',this)">🚌 Dekat Transportasi</div>
                            <div class="csel-opt" data-val="5" onclick="pickCsel('csel-kedit-kodelok',this)">🏡 Perumahan</div>
                            <div class="csel-opt" data-val="6" onclick="pickCsel('csel-kedit-kodelok',this)">🛍️ Dekat Pasar</div>
                            <div class="csel-opt" data-val="7" onclick="pickCsel('csel-kedit-kodelok',this)">🏭 Kawasan Industri</div>
                            <div class="csel-opt" data-val="8" onclick="pickCsel('csel-kedit-kodelok',this)">🛣️ Pinggir Jalan Utama</div>
                            <div class="csel-opt" data-val="9" onclick="pickCsel('csel-kedit-kodelok',this)">⛰️ Pedesaan/Wisata</div>
                            <div class="csel-opt" data-val="10" onclick="pickCsel('csel-kedit-kodelok',this)">📍 Lainnya</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mform-group"><label>Wilayah / Kota</label>
                <div class="csel-wrap" id="csel-kedit-wilayah" style="position:relative">
                    <div class="csel-trigger" onclick="toggleCselSearch('csel-kedit-wilayah')" style="display:flex;align-items:center;gap:6px">
                        <span class="csel-val" style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">-- Pilih Wilayah --</span>
                        <span>▾</span>
                    </div>
                    <div class="csel-dropdown" style="padding:0">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border);position:sticky;top:0;background:var(--card);z-index:2;border-radius:6px 6px 0 0">
                            <input type="text" id="kedit-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kedit')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kedit-wilayah-list" style="padding:4px"></div>
                    </div>
                </div>
                <input type="hidden" id="kedit-wilayah-id" />
            </div>
            <div class="mform-group"><label>Fasilitas</label>
                <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:10px;background:var(--bg2);border:1.5px solid var(--border);border-radius:12px;padding:16px">
                    <label class="fas-toggle"><input type="checkbox" id="kedit-listrik" value="1"><div class="fas-box"><span>⚡</span> Listrik</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kedit-ac" value="1"><div class="fas-box"><span>❄️</span> AC</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kedit-kmd" value="1"><div class="fas-box"><span>🚿</span> KM Dalam</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kedit-parkir" value="1"><div class="fas-box"><span>🏍️</span> Parkir Motor</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kedit-laundry" value="1"><div class="fas-box"><span>👕</span> Laundry</div></label>
                    <label class="fas-toggle"><input type="checkbox" id="kedit-wifi" value="1"><div class="fas-box"><span>📶</span> WiFi</div></label>
                </div>
            </div>
            <div class="mform-group"><label>Deskripsi</label><textarea id="kedit-deskripsi" placeholder="Deskripsi kost..." rows="3" style="width:100%;border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;font-size:13px;font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);resize:vertical"></textarea></div>
            <div id="kedit-error" class="form-error-msg" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn-sm" onclick="closeModal('modal-kost-edit')">Batal</button>
            <button class="btn-sm primary" id="btn-kedit-save" onclick="submitEditKost()"><span id="btn-kedit-label">Simpan</span></button>
        </div>
    </div>
</div>

{{-- MODAL VIEW --}}
<div class="modal-overlay" id="modal-kost-view" onclick="closeModalOutside(event,this)">
    <div class="modal-box">
        <div class="modal-header"><h3>🏘️ Detail Kost</h3><button class="modal-close" onclick="closeModal('modal-kost-view')">✕</button></div>
        <div class="modal-body">
            <div id="vk-foto-wrap" style="width:100%;height:180px;border-radius:12px;overflow:hidden;margin-bottom:18px;background:var(--bg2);display:flex;align-items:center;justify-content:center;font-size:56px;"></div>
            <div style="display:flex;align-items:flex-start;gap:14px;margin-bottom:16px;padding-bottom:16px;border-bottom:1px solid var(--border)">
                <div style="flex:1"><div id="vk-nama" style="font-family:'Syne',sans-serif;font-size:18px;font-weight:800;line-height:1.2"></div><div id="vk-lokasi" style="font-size:12px;color:var(--muted);margin-top:4px"></div></div>
                <div id="vk-tier-badge" style="padding:4px 12px;border-radius:100px;font-size:11px;font-weight:700;flex-shrink:0"></div>
            </div>
            <div class="detail-row"><span class="detail-label">Wilayah Kost</span><span class="detail-val" id="vk-wilayah"></span></div>
            <div class="detail-row"><span class="detail-label">Kode Lokasi</span><span class="detail-val" id="vk-kode-lokasi"></span></div>
            <div class="detail-row"><span class="detail-label">Tipe Kost</span><span class="detail-val" id="vk-tipe-kos"></span></div>
            <div class="detail-row"><span class="detail-label">Harga</span><span class="detail-val" id="vk-harga" style="color:var(--coral);font-size:15px;font-family:'Syne',sans-serif"></span></div>
            <div class="detail-row"><span class="detail-label">Status</span><span class="detail-val" id="vk-status"></span></div>
            <div class="detail-row"><span class="detail-label">Rating</span><span class="detail-val" id="vk-rating"></span></div>
            <div class="detail-row"><span class="detail-label">Ulasan</span><span class="detail-val" id="vk-ulasan"></span></div>
            <div class="detail-row"><span class="detail-label">Fasilitas</span><span class="detail-val" id="vk-fasilitas"></span></div>
            <div class="detail-row"><span class="detail-label">Luas Kamar</span><span class="detail-val" id="vk-ukuran"></span></div>
            <div class="detail-row"><span class="detail-label">No. Telepon</span><span class="detail-val" id="vk-telepon"></span></div>
            <div class="detail-row" style="flex-direction:column;gap:6px"><span class="detail-label">Deskripsi</span><span class="detail-val" id="vk-deskripsi" style="white-space:pre-wrap"></span></div>
        </div>
        <div class="modal-footer">
            <button class="btn-sm" onclick="closeModal('modal-kost-view')">Tutup</button>
            <button class="btn-sm primary" id="vk-btn-wa" onclick="hubungiWhatsApp(this.dataset.phone)">💬 Hubungi Pemilik</button>
        </div>
    </div>
</div>

{{-- MODAL HAPUS --}}
<div id="modal-kost-hapus" class="modal-overlay" onclick="closeModalOutside(event,this)">
    <div class="modal-box" style="max-width:380px;text-align:center">
        <div class="modal-body" style="padding-top:28px">
            <div style="width:56px;height:56px;border-radius:16px;background:rgba(229,62,62,.1);display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 14px">🗑️</div>
            <h3 style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800;margin-bottom:8px">Hapus Kost?</h3>
            <p style="font-size:13px;color:var(--muted);line-height:1.6" id="kost-hapus-msg">Data kost akan dihapus permanen.</p>
        </div>
        <div class="modal-footer" style="justify-content:center;gap:10px">
            <button class="btn-sm" onclick="closeModal('modal-kost-hapus')">Batal</button>
            <button class="btn-sm" id="btn-kost-hapus-confirm" style="background:#E53E3E;color:white;border-color:#E53E3E">Ya, Hapus</button>
        </div>
    </div>
</div>

{{-- MODAL CSV IMPORT --}}
<div class="modal-overlay" id="modal-csv-import" onclick="closeModalOutside(event,this)">
    <div class="modal-box" style="max-width:520px">
        <div class="modal-header"><h3>📄 Import Kost dari CSV</h3><button class="modal-close" onclick="closeModal('modal-csv-import')">✕</button></div>
        <div class="modal-body">
            <p style="font-size:13px;color:var(--muted);margin-bottom:14px;line-height:1.6">Upload file CSV dengan kolom: <code style="background:var(--bg);padding:2px 6px;border-radius:4px;font-size:12px">nama_kost, alamat_kost, kelas, jenis_kost, status, fasilitas, harga_kost, nomor_telepon, deskripsi, ukuran_kamar</code></p>
            <div class="kost-upload-area" style="margin-bottom:14px">
                <input type="file" accept=".csv,.txt" id="csv-file-input" onchange="previewCsvFile()"/>
                <div class="kost-photo-preview" style="height:100px">
                    <div id="csv-placeholder" style="text-align:center;padding:16px"><span style="font-size:32px">📄</span><p style="font-size:12px;color:var(--muted);margin-top:6px">Klik atau seret file CSV</p></div>
                    <div id="csv-file-info" style="display:none;text-align:center;padding:16px"><span style="font-size:28px">✅</span><p id="csv-file-name" style="font-size:13px;font-weight:600;margin-top:6px"></p></div>
                </div>
            </div>
            <div id="csv-error" class="form-error-msg" style="display:none"></div>
            <div id="csv-result" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:10px;padding:14px;font-size:13px;margin-top:10px"></div>
        </div>
        <div class="modal-footer">
            <button class="btn-sm" onclick="closeModal('modal-csv-import')">Tutup</button>
            <button class="btn-sm primary" id="btn-csv-import" onclick="submitCsvImport()"><span id="btn-csv-label">Import</span></button>
        </div>
    </div>
</div>

<style>
.form-error-msg{background:rgba(229,62,62,.08);border:1px solid rgba(229,62,62,.2);border-radius:8px;padding:10px 13px;font-size:12px;color:#E53E3E;margin-top:4px;}
.kost-upload-area{position:relative;border-radius:10px;overflow:hidden;border:1.5px dashed var(--border);background:var(--bg);transition:border-color .2s,background .2s;}
.kost-upload-area:hover{border-color:var(--coral);background:var(--coral-bg);}
.kost-upload-area input[type=file]{position:absolute;inset:0;opacity:0;cursor:pointer;z-index:2;width:100%;height:100%;}
.kost-photo-preview{width:100%;height:160px;display:flex;align-items:center;justify-content:center;border-radius:10px;overflow:hidden;}
.kost-photo-placeholder{text-align:center;padding:16px;}
.kost-remove-photo{position:relative;z-index:3;width:100%;padding:8px;background:rgba(229,62,62,.08);border:none;border-top:1px solid rgba(229,62,62,.2);color:#E53E3E;font-size:12px;font-weight:600;cursor:pointer;font-family:'DM Sans',sans-serif;transition:background .2s;}
.kost-remove-photo:hover{background:rgba(229,62,62,.15);}
.kc-rating-wrap{display:flex;align-items:center;gap:5px;font-size:13px;}
.kc-stars-filled{color:var(--yellow);font-size:12px;letter-spacing:-1px;}
.kc-rating-num{font-weight:700;font-size:13px;}
.kc-review-count{font-size:11px;color:var(--muted);}
.tier-badge-ekonomis{background:var(--coral-bg);color:var(--coral);}
.tier-badge-standar{background:var(--teal-bg);color:var(--teal);}
.tier-badge-premium{background:var(--yellow-bg);color:var(--yellow);}
.fas-toggle { cursor:pointer; user-select:none; }
.fas-toggle input { display:none; }
.fas-toggle .fas-box { display:flex; align-items:center; gap:8px; font-size:13px; padding:10px 14px; border:1px solid var(--border); border-radius:8px; background:var(--bg); transition:all .2s; }
.fas-toggle input:checked + .fas-box { background:rgba(49, 151, 149, 0.1); border-color:var(--teal); color:var(--teal); font-weight:600; }
</style>
@endsection

@push('scripts')
<script>
let allKosts=[],activeKostFilter='semua',kostSearchQuery='',addKostPhoto=null,editKostPhoto=null,hapusKostId=null;

document.addEventListener('DOMContentLoaded', async ()=>{
    await loadWilayahOptions();
    loadKosts();
    document.getElementById('search-kost').addEventListener('input',e=>{kostSearchQuery=e.target.value;applyKostFilter();});
});

/* loadWilayahOptions defined at bottom of script */

/* LOAD — field dari controller: id,nama_kost,foto_kost,alamat_kost,kelas,
   status,fasilitas,harga_kost,nomor_telepon,avg_rating,reviews_count */
async function loadKosts(){
    try{
        const res=await fetch('/api/kost');
        const result=await res.json();
        if(!result.success)throw new Error(result.message??'Gagal');
        allKosts=result.data;
        applyKostFilter();
        renderStats();
    }catch(err){
        console.error('loadKosts:',err); alert('ERROR: ' + err.message + '\n' + err.stack);
        document.getElementById('kost-view-grid').innerHTML='<div style="grid-column:1/-1;text-align:center;padding:48px;color:#E53E3E;font-size:13px">Gagal memuat data kost.</div>';
    }
}

function renderStats(){
    const total=allKosts.length;
    const ratingTinggi=allKosts.filter(k=>parseFloat(k.avg_rating??0)>4).length;
    const avgRating=total?(allKosts.reduce((s,k)=>s+parseFloat(k.avg_rating??0),0)/total).toFixed(2):'0.00';
    const belumReview=allKosts.filter(k=>(k.reviews_count??0)===0).length;
    document.getElementById('stat-total-kost').textContent=total;
    document.getElementById('stat-rating-tinggi').textContent=ratingTinggi;
    document.getElementById('stat-avg-rating').textContent=avgRating;
    document.getElementById('stat-belum-review').textContent=belumReview;
}

function setKostFilter(val,el){
    activeKostFilter=val;
    document.querySelectorAll('#filter-kost .filter-opt').forEach(o=>o.classList.remove('active'));
    el.classList.add('active');
    document.getElementById('filter-kost').classList.remove('open');
    applyKostFilter();
}

function applyKostFilter(){
    const q=kostSearchQuery.toLowerCase();
    const KELAS_LABEL={1:'Ekonomi',2:'Standar',3:'Premium'};
    const filtered=allKosts.filter(k=>{
        const kelasInt=parseInt(k.kelas??0);
        const kelasLabel=(KELAS_LABEL[kelasInt]||'').toLowerCase();
        // Filter berdasarkan integer kelas (bukan label string)
        const matchKelas=activeKostFilter==='semua'||String(kelasInt)===activeKostFilter;
        const matchSearch=!q||(k.nama_kost??'').toLowerCase().includes(q)||(k.alamat_kost??'').toLowerCase().includes(q)||kelasLabel.includes(q)||(k.status_label??'').toLowerCase().includes(q)||formatRupiah(k.harga_kost).toLowerCase().includes(q)||String(k.avg_rating??'').includes(q);
        return matchKelas&&matchSearch;
    });
    renderGrid(filtered);
    renderTable(filtered);
}

function formatRupiah(n){return 'Rp '+Number(n??0).toLocaleString('id-ID');}
function renderStars(r){const v=parseFloat(r)||0,f=Math.floor(v),h=(v-f)>=0.5;let s='';for(let i=0;i<5;i++)s+=i<f?'★':(i===f&&h?'½':'☆');return s;}
function kelasClass(k){const t=String(k||'').toLowerCase();return (t==='ekonomi'||t==='ekonomis'||t==='1')?'coral':(t==='standar'||t==='2')?'teal':(t==='premium'||t==='3')?'yellow':'blue';}
function statusClass(s){const v=String(s||'').toLowerCase();return (v==='tersedia'||v==='1')?'green':(v==='penuh'||v==='0')?'coral':'muted';}

/* packKost — semua field dari formatKost() controller sudah ada */
function packKost(k){
    return JSON.stringify({
        id:k.id??'',
        nama_kost:k.nama_kost??'',
        foto_kost:k.foto_kost??'',
        alamat_kost:k.alamat_kost??'',
        kelas:k.kelas??1,
        kelas_label:k.kelas_label??'Ekonomi',
        tipe_kos:k.tipe_kos??3,
        tipe_kos_label:k.tipe_kos_label??'Campur',
        status:k.status??1,
        status_label:k.status_label??'Tersedia',
        luas_kamar:k.luas_kamar??0,
        kode_lokasi:k.kode_lokasi??1,
        lokasi_label:k.lokasi_label??'',
        wilayah_id:k.wilayah_id??'',
        wilayah_nama:k.wilayah_nama??null,
        listrik:k.listrik??0,
        ac:k.ac??0,
        kamar_mandi_dalam:k.kamar_mandi_dalam??0,
        parkir_motor:k.parkir_motor??0,
        laundry:k.laundry??0,
        wifi:k.wifi??0,
        harga_kost:k.harga_kost??0,
        nomor_telepon:k.nomor_telepon??'',
        deskripsi:k.deskripsi??'',
        rating:parseFloat(k.avg_rating??0).toFixed(1),
        ulasan:parseInt(k.reviews_count??0),
    }).replace(/'/g,"&#39;");
}

function renderGrid(kosts){
    const KELAS_LABEL={1:'Ekonomi',2:'Standar',3:'Premium'};
    const TIPE_LABEL={1:'Pria',2:'Wanita',3:'Campur'};
    const grid=document.getElementById('kost-view-grid');
    if(!kosts.length){grid.innerHTML='<div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:13px">Tidak ada kost ditemukan.</div>';return;}
    grid.innerHTML=kosts.map(k=>{
        const rating=parseFloat(k.avg_rating??0).toFixed(1),ulasan=parseInt(k.reviews_count??0);
        const stars=renderStars(rating);
        const kelasInt=parseInt(k.kelas??1);
        const kelasLabel=k.kelas_label||KELAS_LABEL[kelasInt]||'Ekonomi';
        const kelasCls=kelasClass(kelasLabel);
        const statusLabel=k.status_label||(k.status===0?'Penuh':k.status===1?'Tersedia':k.status+' Kamar Sisa');
        const fasList=[];
        if(k.listrik)fasList.push('⚡');if(k.ac)fasList.push('❄️');if(k.wifi)fasList.push('📶');
        if(k.kamar_mandi_dalam)fasList.push('🚿');if(k.parkir_motor)fasList.push('🏍️');if(k.laundry)fasList.push('👕');
        const tags=fasList.slice(0,3).map(f=>`<span class="kc-tag">${f}</span>`).join('');
        const fotoHtml=k.foto_kost?`<img src="${k.foto_kost}" style="width:100%;height:100%;object-fit:cover;"/>`:'<span style="font-size:48px">🏘️</span>';
        const d=packKost(k),namaEsc=(k.nama_kost??'').replace(/'/g,"\\'");
        return `<div class="kost-card-dash" data-kelas="${kelasInt}" data-id="${k.id}">
<div class="kc-img" style="padding:0;overflow:hidden;display:flex;align-items:center;justify-content:center;background:var(--bg2)">${fotoHtml}<span class="kc-badge ${kelasCls}" style="position:absolute;top:10px;left:10px">${kelasLabel}</span></div>
<div class="kc-body"><div class="kc-name">${k.nama_kost}</div><div class="kc-loc">📍 ${k.alamat_kost}</div><div class="kc-price">${formatRupiah(k.harga_kost)}<span>/bulan</span></div><div class="kc-tags">${tags}</div></div>
<div class="kc-footer"><div class="kc-rating-wrap"><span class="kc-stars-filled">${stars}</span><span class="kc-rating-num">${rating}</span><span class="kc-review-count">(${ulasan})</span></div>
<div style="display:flex;gap:6px">
<button class="kc-footer-btn" onclick='openViewKost(${d})'>👁️ Lihat</button>
<button class="kc-footer-btn" onclick='openEditKost(${d})'>✏️ Edit</button>
<button class="kc-footer-btn" style="color:#E53E3E;background:rgba(229,62,62,.08)" onclick="openHapusKost('${k.id}','${namaEsc}')">🗑️</button>
</div></div></div>`;
    }).join('');
}

function renderTable(kosts){
    const tbody=document.getElementById('kost-table-body');
    if(!kosts.length){tbody.innerHTML='<tr><td colspan="14" style="text-align:center;padding:32px;color:var(--muted)">Tidak ada kost ditemukan.</td></tr>';return;}
    tbody.innerHTML=kosts.map(k=>{
        const rating=parseFloat(k.avg_rating??0).toFixed(1),ulasan=parseInt(k.reviews_count??0);
        const stars=renderStars(rating),kelasCls=kelasClass(k.kelas),stsCls=statusClass(k.status);
        const d=packKost(k),namaEsc=(k.nama_kost??'').replace(/'/g,"\\'");
        const fotoHtml=k.foto_kost?`<img src="${k.foto_kost}" style="width:44px;height:44px;border-radius:6px;object-fit:cover;"/>`:'<div style="width:44px;height:44px;border-radius:6px;background:var(--bg2);display:flex;align-items:center;justify-content:center;font-size:20px">🏘️</div>';
        const fasList=[];
        if(k.listrik)fasList.push('⚡');if(k.ac)fasList.push('❄️');if(k.wifi)fasList.push('📶');
        if(k.kamar_mandi_dalam)fasList.push('🚿');if(k.parkir_motor)fasList.push('🏍️');if(k.laundry)fasList.push('👕');
        return `<tr data-kelas="${k.kelas}" data-id="${k.id}">
<td>${fotoHtml}</td>
<td><b>${k.nama_kost}</b></td>
<td>${k.alamat_kost}</td>
<td>${k.wilayah_nama||'-'}</td>
<td><span class="pill" style="background:var(--bg2);color:var(--text);border:1px solid var(--border)">${k.lokasi_label || k.kode_lokasi}</span></td>
<td><span class="pill ${kelasCls}">${k.kelas_label || k.kelas}</span></td>
<td>${k.tipe_kos_label || (k.tipe_kos===1?'Pria':k.tipe_kos===2?'Wanita':'Campur')}</td>
<td>${formatRupiah(k.harga_kost)}</td>
<td><span class="pill ${stsCls}">${k.status_label || (k.status===0?'Penuh':k.status===1?'Tersedia':k.status+' Sisa')}</span></td>
<td>${k.nomor_telepon || '-'}</td>
<td>${k.luas_kamar ? k.luas_kamar+' m²' : '-'}</td>
<td><div style="display:flex;gap:4px;flex-wrap:wrap;max-width:80px">${fasList.map(f=>`<span title="Fasilitas" style="font-size:14px">${f}</span>`).join('')}</div></td>
<td><div style="max-width:140px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;" title="${(k.deskripsi||'').replace(/"/g,'&quot;')}">${k.deskripsi||'-'}</div></td>
<td><div class="action-btns">
<button class="act-btn" title="Lihat" onclick='openViewKost(${d})'>👁️</button>
<button class="act-btn" title="Edit" onclick='openEditKost(${d})'>✏️</button>
<button class="act-btn" title="Hapus" onclick="openHapusKost('${k.id}','${namaEsc}')">🗑️</button>
</div></td></tr>`;
    }).join('');
}

/* FOTO — ID HTML: kadd-photo-input, kadd-photo-img, kadd-placeholder, kadd-remove-btn */
function previewKostPhoto(mode){
    const file=document.getElementById(`${mode}-photo-input`).files[0];
    if(!file)return;
    if(mode==='kadd')addKostPhoto=file;else editKostPhoto=file;
    const r=new FileReader();
    r.onload=e=>{
        document.getElementById(`${mode}-photo-img`).src=e.target.result;
        document.getElementById(`${mode}-photo-img`).style.display='block';
        document.getElementById(`${mode}-placeholder`).style.display='none';
        document.getElementById(`${mode}-remove-btn`).style.display='block';
    };
    r.readAsDataURL(file);
}

function removeKostPhoto(mode,e){
    e.stopPropagation();
    document.getElementById(`${mode}-photo-img`).src='';
    document.getElementById(`${mode}-photo-img`).style.display='none';
    document.getElementById(`${mode}-placeholder`).style.display='';
    document.getElementById(`${mode}-remove-btn`).style.display='none';
    document.getElementById(`${mode}-photo-input`).value='';
    if(mode==='kadd')addKostPhoto=null;else editKostPhoto=null;
}

/* VIEW — id HTML: vk-nama, vk-lokasi, vk-harga, vk-telepon, vk-tier-badge, vk-deskripsi, vk-ukuran */
function openViewKost(d){
    document.getElementById('vk-foto-wrap').innerHTML=d.foto_kost?`<img src="${d.foto_kost}" style="width:100%;height:100%;object-fit:cover;"/>`:'<span style="font-size:56px">🏘️</span>';
    const KELAS_LABEL={1:'Ekonomi',2:'Standar',3:'Premium'};
    const kelasMap={1:'tier-badge-ekonomis',2:'tier-badge-standar',3:'tier-badge-premium'};
    const kelasInt=parseInt(d.kelas??1);
    const kelasLabel=d.kelas_label||KELAS_LABEL[kelasInt]||'Ekonomi';
    const badge=document.getElementById('vk-tier-badge');
    if(badge){badge.textContent=kelasLabel;badge.className=kelasMap[kelasInt]||'tier-badge-standar';}
    document.getElementById('vk-nama').textContent=d.nama_kost;
    document.getElementById('vk-lokasi').textContent='📍 '+d.alamat_kost;
    document.getElementById('vk-harga').textContent=formatRupiah(d.harga_kost)+'/bulan';
    document.getElementById('vk-status').textContent=d.status_label||(d.status>=1?'Tersedia':'Penuh');
    document.getElementById('vk-rating').innerHTML=`<span style="color:var(--yellow)">${renderStars(d.rating)}</span> ${d.rating}`;
    document.getElementById('vk-ulasan').textContent=d.ulasan+' ulasan';
    
    const wilEl=document.getElementById('vk-wilayah'); if(wilEl) wilEl.textContent=d.wilayah_nama||'-';
    const kodEl=document.getElementById('vk-kode-lokasi'); if(kodEl) kodEl.textContent=d.lokasi_label||d.kode_lokasi;
    const tipeEl=document.getElementById('vk-tipe-kos'); if(tipeEl) tipeEl.textContent=d.tipe_kos_label||(d.tipe_kos===1?'Pria':d.tipe_kos===2?'Wanita':'Campur');

    // Bangun daftar fasilitas dari field binary
    const fasList=[];
    if(d.listrik)fasList.push('⚡ Listrik');if(d.ac)fasList.push('❄️ AC');if(d.wifi)fasList.push('📶 WiFi');
    if(d.kamar_mandi_dalam)fasList.push('🚿 KM Dalam');if(d.parkir_motor)fasList.push('🏍️ Parkir Motor');if(d.laundry)fasList.push('👕 Laundry');
    document.getElementById('vk-fasilitas').textContent=fasList.length?fasList.join(', '):'-';
    document.getElementById('vk-ukuran').textContent=d.luas_kamar?d.luas_kamar+' m²':'-';
    document.getElementById('vk-telepon').textContent=d.nomor_telepon||'-';
    document.getElementById('vk-deskripsi').textContent=d.deskripsi||'-';
    document.getElementById('vk-btn-wa').dataset.phone=d.nomor_telepon||'';
    openModal('modal-kost-view');
}

function hubungiWhatsApp(phone) {
    if(!phone || phone === '-' || phone.trim() === '') {
        alert('Nomor telepon pemilik tidak tersedia');
        return;
    }
    let cp = phone.replace(/\D/g, '');
    if(cp.startsWith('0')) {
        cp = '62' + cp.substring(1);
    } else if(!cp.startsWith('62')) {
        cp = '62' + cp;
    }
    window.open('https://wa.me/' + cp, '_blank');
}

/* TAMBAH — id HTML: kadd-nama, kadd-lokasi, kadd-harga, kadd-telepon, kadd-fasilitas, kadd-deskripsi, kadd-ukuran */
function openAddKost(){
    ['kadd-nama','kadd-lokasi','kadd-harga','kadd-telepon','kadd-luas'].forEach(id=>document.getElementById(id).value='');
    document.getElementById('kadd-deskripsi').value='';
    document.getElementById('kadd-error').style.display='none';
    ['kadd-listrik','kadd-ac','kadd-kmd','kadd-parkir','kadd-laundry','kadd-wifi'].forEach(id=>{
        const el=document.getElementById(id);if(el)el.checked=(id==='kadd-listrik');
    });
    removeKostPhoto('kadd',{stopPropagation:()=>{}});
    setKelasDisplay('kadd',1);setCselVal('csel-kadd-status','1');setCselVal('csel-kadd-jenis','3');setCselVal('csel-kadd-kodelok','1');
    document.getElementById('kadd-wilayah-id').value='';
    document.getElementById('csel-kadd-wilayah').querySelector('.csel-val').textContent='-- Pilih Wilayah --';
    openModal('modal-kost-add');
}

async function submitAddKost(){
    const namaKost=document.getElementById('kadd-nama').value.trim();
    const alamatKost=document.getElementById('kadd-lokasi').value.trim();
    const hargaKost=getRawHarga('kadd-harga');
    const nomorTelepon=document.getElementById('kadd-telepon').value.trim();
    const deskripsi=document.getElementById('kadd-deskripsi').value.trim();
    const luasKamar=document.getElementById('kadd-luas').value||0;
    const kelas=document.getElementById('kadd-tier-val').value||'1',status=getCselVal('csel-kadd-status'),tipeKos=getCselVal('csel-kadd-jenis');
    const wilayahId = document.getElementById('kadd-wilayah-id').value; const kodeLokas = getCselVal('csel-kadd-kodelok') || 1;
    const errorEl=document.getElementById('kadd-error');
    if(!namaKost||!alamatKost||!hargaKost){showFormError(errorEl,'Nama kost, alamat, dan harga wajib diisi.');return;}
    setBtnLoading('btn-kadd-save','btn-kadd-label',true,'Menyimpan...');
    try{
        const body=new FormData();
        body.append('nama_kost',namaKost);body.append('alamat_kost',alamatKost);
        body.append('harga_kost',hargaKost);body.append('kelas',kelas);body.append('status',status);
        body.append('tipe_kos',tipeKos);body.append('luas_kamar',luasKamar);
        body.append('kode_lokasi',kodeLokas);if(wilayahId)body.append('wilayah_id',wilayahId);
        body.append('nomor_telepon',nomorTelepon);body.append('deskripsi',deskripsi);
        body.append('listrik',document.getElementById('kadd-listrik').checked?1:0);
        body.append('ac',document.getElementById('kadd-ac').checked?1:0);
        body.append('kamar_mandi_dalam',document.getElementById('kadd-kmd').checked?1:0);
        body.append('parkir_motor',document.getElementById('kadd-parkir').checked?1:0);
        body.append('laundry',document.getElementById('kadd-laundry').checked?1:0);
        body.append('wifi',document.getElementById('kadd-wifi').checked?1:0);
        if(addKostPhoto)body.append('foto_kost',addKostPhoto);
        const res=await fetch('/api/kost',{method:'POST',headers:{'Accept':'application/json','X-CSRF-TOKEN':'{{ csrf_token() }}'},body});
        const data=await res.json();
        if(data.success||res.ok){
            allKosts.unshift(data.data??{});
            applyKostFilter();renderStats();closeModal('modal-kost-add');showToast('Kost berhasil ditambahkan','✅');
        }else{showFormError(errorEl,data.message||Object.values(data.errors??{}).flat().join(' ')||'Gagal menyimpan.');}
    }catch(err){console.error(err);showFormError(errorEl,'Terjadi kesalahan server.');}
    finally{setBtnLoading('btn-kadd-save','btn-kadd-label',false,'Simpan');}
}

/* EDIT — id HTML: kedit-nama, kedit-lokasi, kedit-harga, kedit-telepon, kedit-fasilitas, kedit-deskripsi, kedit-ukuran */
function openEditKost(d){
    document.getElementById('kedit-id').value=d.id;
    document.getElementById('kedit-nama').value=d.nama_kost;
    document.getElementById('kedit-lokasi').value=d.alamat_kost;
    document.getElementById('kedit-harga').value=d.harga_kost?Number(d.harga_kost).toLocaleString('id-ID'):'';
    document.getElementById('kedit-telepon').value=d.nomor_telepon||'';
    document.getElementById('kedit-luas').value=d.luas_kamar||'';
    document.getElementById('kedit-deskripsi').value=d.deskripsi||'';
    document.getElementById('kedit-error').style.display='none';
    setKelasDisplay('kedit',parseInt(d.kelas||1));
    setCselVal('csel-kedit-status',String(d.status??1));
    setCselVal('csel-kedit-jenis',String(d.tipe_kos||3));
    setCselVal('csel-kedit-kodelok',String(d.kode_lokasi||1));
    const wilayahOpt = (K_WILAYAH_OPTS || []).find(w => w.id === d.wilayah_id);
    document.getElementById('kedit-wilayah-id').value = d.wilayah_id || '';
    document.getElementById('csel-kedit-wilayah').querySelector('.csel-val').textContent = wilayahOpt ? wilayahOpt.nama_wilayah : '-- Pilih Wilayah --';
    document.getElementById('kedit-listrik').checked=d.listrik==1;
    document.getElementById('kedit-ac').checked=d.ac==1;
    document.getElementById('kedit-kmd').checked=d.kamar_mandi_dalam==1;
    document.getElementById('kedit-parkir').checked=d.parkir_motor==1;
    document.getElementById('kedit-laundry').checked=d.laundry==1;
    document.getElementById('kedit-wifi').checked=d.wifi==1;
    editKostPhoto=null;document.getElementById('kedit-photo-input').value='';
    const img=document.getElementById('kedit-photo-img'),ph=document.getElementById('kedit-placeholder'),btn=document.getElementById('kedit-remove-btn');
    if(d.foto_kost){img.src=d.foto_kost;img.style.display='block';ph.style.display='none';btn.style.display='block';}
    else{img.src='';img.style.display='none';ph.style.display='';btn.style.display='none';}
    openModal('modal-kost-edit');
}

async function submitEditKost(){
    const id=document.getElementById('kedit-id').value;
    const namaKost=document.getElementById('kedit-nama').value.trim();
    const alamatKost=document.getElementById('kedit-lokasi').value.trim();
    const hargaKost=getRawHarga('kedit-harga');
    const nomorTelepon=document.getElementById('kedit-telepon').value.trim();
    const deskripsi=document.getElementById('kedit-deskripsi').value.trim();
    const luasKamar=document.getElementById('kedit-luas').value||0;
    const kelas=document.getElementById('kedit-tier-val').value||'1',status=getCselVal('csel-kedit-status'),tipeKos=getCselVal('csel-kedit-jenis');
    const wilayahId = document.getElementById('kedit-wilayah-id').value; const kodeLokas = getCselVal('csel-kedit-kodelok') || 1;
    const errorEl=document.getElementById('kedit-error');
    if(!namaKost||!alamatKost||!hargaKost){showFormError(errorEl,'Nama kost, alamat, dan harga wajib diisi.');return;}
    setBtnLoading('btn-kedit-save','btn-kedit-label',true,'Menyimpan...');
    try{
        const body=new FormData();
        body.append('_method','PUT');body.append('nama_kost',namaKost);body.append('alamat_kost',alamatKost);
        body.append('harga_kost',hargaKost);body.append('kelas',kelas);body.append('status',status);
        body.append('tipe_kos',tipeKos);body.append('luas_kamar',luasKamar);
        body.append('kode_lokasi',kodeLokas);if(wilayahId)body.append('wilayah_id',wilayahId);
        body.append('nomor_telepon',nomorTelepon);body.append('deskripsi',deskripsi);
        body.append('listrik',document.getElementById('kedit-listrik').checked?1:0);
        body.append('ac',document.getElementById('kedit-ac').checked?1:0);
        body.append('kamar_mandi_dalam',document.getElementById('kedit-kmd').checked?1:0);
        body.append('parkir_motor',document.getElementById('kedit-parkir').checked?1:0);
        body.append('laundry',document.getElementById('kedit-laundry').checked?1:0);
        body.append('wifi',document.getElementById('kedit-wifi').checked?1:0);
        if(editKostPhoto)body.append('foto_kost',editKostPhoto);
        const res=await fetch(`/api/kost/${id}`,{method:'POST',headers:{'Accept':'application/json','X-CSRF-TOKEN':'{{ csrf_token() }}'},body});
        const data=await res.json();
        if(data.success||res.ok){
            const idx=allKosts.findIndex(k=>String(k.id)===String(id));
            if(idx!==-1)allKosts[idx]=data.data??{...allKosts[idx]};
            applyKostFilter();renderStats();closeModal('modal-kost-edit');showToast('Data kost diperbarui','✅');
        }else{showFormError(errorEl,data.message||Object.values(data.errors??{}).flat().join(' ')||'Gagal menyimpan.');}
    }catch(err){console.error(err);showFormError(errorEl,'Terjadi kesalahan server.');}
    finally{setBtnLoading('btn-kedit-save','btn-kedit-label',false,'Simpan');}
}

/* HAPUS */
function openHapusKost(id,nama){
    hapusKostId=id;
    document.getElementById('kost-hapus-msg').textContent=`"${nama}" akan dihapus permanen.`;
    document.getElementById('btn-kost-hapus-confirm').onclick=confirmHapusKost;
    openModal('modal-kost-hapus');
}
async function confirmHapusKost(){
    if(!hapusKostId)return;
    const btn=document.getElementById('btn-kost-hapus-confirm');
    btn.disabled=true;btn.textContent='Menghapus...';
    try{
        const res=await fetch(`/api/kost/${hapusKostId}`,{method:'DELETE',headers:{'Accept':'application/json','X-CSRF-TOKEN':'{{ csrf_token() }}'}});
        const data=await res.json();
        if(data.success||res.ok){
            allKosts=allKosts.filter(k=>String(k.id)!==String(hapusKostId));
            applyKostFilter();renderStats();closeModal('modal-kost-hapus');showToast('Kost berhasil dihapus','🗑️');
        }else{showToast(data.message||'Gagal menghapus.','❌');}
    }catch(err){console.error(err);showToast('Terjadi kesalahan server.','❌');}
    finally{btn.disabled=false;btn.textContent='Ya, Hapus';hapusKostId=null;}
}

/* TOGGLE VIEW */
function setKostView(view){
    document.getElementById('kost-view-grid').style.display=view==='grid'?'grid':'none';
    document.getElementById('kost-view-table').style.display=view==='table'?'block':'none';
    document.getElementById('view-grid-btn').className='btn-sm'+(view==='grid'?' primary':'');
    document.getElementById('view-table-btn').className='btn-sm'+(view==='table'?' primary':'');
}

function showFormError(el,msg){el.textContent=msg;el.style.display='block';}
function setBtnLoading(bId,lId,load,text){document.getElementById(bId).disabled=load;document.getElementById(lId).textContent=text;}

/* FORMAT harga — titik pemisah ribuan saat mengetik */
function formatHargaInput(el){
    const raw=el.value.replace(/\D/g,'');
    el.value=raw?Number(raw).toLocaleString('id-ID'):'';
}
function getRawHarga(id){
    return (document.getElementById(id).value||'').replace(/\./g,'').replace(/,/g,'');
}

/* KELAS OTOMATIS berdasarkan harga */
function getKelasByHarga(harga) {
    const h = parseInt(harga) || 0;
    if (h > 1500000) return 3;  // Premium
    if (h >= 1000000) return 2; // Standar
    return 1;                   // Ekonomi
}

function setKelasDisplay(prefix, kelasInt) {
    const KELAS_INFO = {
        1: { label: '💚 Ekonomi',  bg: 'rgba(56,161,105,.12)',  color: '#38a169' },
        2: { label: '🔵 Standar',  bg: 'rgba(49,130,206,.12)',  color: '#3182ce' },
        3: { label: '⭐ Premium',  bg: 'rgba(236,201,75,.15)',   color: '#b7791f' },
    };
    const info = KELAS_INFO[kelasInt] || KELAS_INFO[1];
    const badge = document.getElementById(prefix+'-tier-badge');
    const hidden = document.getElementById(prefix+'-tier-val');
    if (badge) { badge.textContent = info.label; badge.style.background = info.bg; badge.style.color = info.color; }
    if (hidden) hidden.value = kelasInt;
}

function autoUpdateKelas(prefix) {
    const raw = getRawHarga(prefix+'-harga');
    const kelas = getKelasByHarga(raw);
    setKelasDisplay(prefix, kelas);
}

if(typeof getCselVal==='undefined'){window.getCselVal=id=>{const w=document.getElementById(id);return w?(w.dataset.value||w.querySelector('.csel-val')?.textContent.trim()||''):'';};}
if(typeof setCselVal==='undefined'){window.setCselVal=(id,val)=>{const w=document.getElementById(id);if(!w)return;const opt=[...w.querySelectorAll('.csel-opt')].find(o=>o.dataset.val===val||o.textContent.trim().includes(val));if(opt){w.querySelector('.csel-val').textContent=opt.textContent.trim();w.dataset.value=opt.dataset.val;w.querySelectorAll('.csel-opt').forEach(o=>o.classList.remove('active'));opt.classList.add('active');}};
}

/* toggleCselSearch, filterWilayah, pickWilayah — defined below (single source of truth) */

/* ─── CSV IMPORT ─── */
function openCsvImport(){
    document.getElementById('csv-file-input').value='';
    document.getElementById('csv-placeholder').style.display='';
    document.getElementById('csv-file-info').style.display='none';
    document.getElementById('csv-error').style.display='none';
    document.getElementById('csv-result').style.display='none';
    openModal('modal-csv-import');
}

function previewCsvFile(){
    const file=document.getElementById('csv-file-input').files[0];
    if(!file)return;
    document.getElementById('csv-placeholder').style.display='none';
    document.getElementById('csv-file-info').style.display='';
    document.getElementById('csv-file-name').textContent=file.name+' ('+Math.round(file.size/1024)+' KB)';
}

async function submitCsvImport(){
    const file=document.getElementById('csv-file-input').files[0];
    const errorEl=document.getElementById('csv-error');
    const resultEl=document.getElementById('csv-result');
    if(!file){showFormError(errorEl,'Pilih file CSV terlebih dahulu.');return;}
    errorEl.style.display='none';resultEl.style.display='none';
    setBtnLoading('btn-csv-import','btn-csv-label',true,'Mengimpor...');
    try{
        const body=new FormData();
        body.append('csv_file',file);
        const res=await fetch('/api/kost/import-csv',{method:'POST',headers:{'Accept':'application/json','X-CSRF-TOKEN':'{{ csrf_token() }}'},body});
        const data=await res.json();
        if(data.success){
            let html=`<div style="font-weight:700;color:var(--teal);margin-bottom:8px">✅ ${data.message}</div>`;
            if(data.errors&&data.errors.length){
                html+=`<div style="margin-top:8px;color:#E53E3E;font-size:12px"><b>Peringatan:</b><ul style="margin:4px 0 0 16px">`;
                data.errors.forEach(e=>html+=`<li>${e}</li>`);
                html+=`</ul></div>`;
            }
            resultEl.innerHTML=html;resultEl.style.display='block';
            loadKosts();
            showToast(`${data.imported} kost berhasil diimpor`,'📄');
        }else{showFormError(errorEl,data.message||'Gagal mengimpor CSV.');}
    }catch(err){console.error(err);showFormError(errorEl,'Terjadi kesalahan server.');}
    finally{setBtnLoading('btn-csv-import','btn-csv-label',false,'Import');}
}

// Wilayah Search Function
function toggleCselSearch(id) {
    const wrap = document.getElementById(id);
    if (!wrap) return;
    const dd = wrap.querySelector('.csel-dropdown');
    const trig = wrap.querySelector('.csel-trigger');
    const isOpen = dd.classList.contains('open');

    // tutup semua csel lain
    document.querySelectorAll('.csel-dropdown.open').forEach(d => {
        d.classList.remove('open');
        const w = d.closest('.csel-wrap');
        if(w) {
            const t = w.querySelector('.csel-trigger');
            if(t) t.classList.remove('open');
        }
    });

    if (!isOpen) {
        dd.classList.add('open');
        if(trig) trig.classList.add('open');
        
        const inp = wrap.querySelector('input[type="text"]');
        if (inp) { inp.value = ''; inp.focus(); }
        filterWilayah(id.replace('csel-', '').split('-')[0]);
    } else {
        dd.classList.remove('open');
        if(trig) trig.classList.remove('open');
    }
}
function filterWilayah(prefix) {
    const q = (document.getElementById(prefix + '-wilayah-search').value || '').toLowerCase();
    const list = document.getElementById(prefix + '-wilayah-list');
    const opts = K_WILAYAH_OPTS || [];
    const filtered = opts.filter(o => o.nama_wilayah.toLowerCase().includes(q));
    list.innerHTML = filtered.map(o => `<div class="csel-opt" style="padding:8px 12px;font-size:13px;cursor:pointer;border-bottom:1px solid var(--border)" onclick="pickWilayah('${prefix}', '${o.id}', this.textContent)">${o.nama_wilayah}</div>`).join('');
    if (!filtered.length) list.innerHTML = '<div style="padding:8px 12px;font-size:12px;color:var(--muted);text-align:center">Tidak ditemukan</div>';
}
function pickWilayah(prefix, id, nama) {
    document.getElementById(prefix + '-wilayah-id').value = id;
    const wrap = document.getElementById('csel-' + prefix + '-wilayah');
    const valEl = wrap.querySelector('.csel-val');
    valEl.textContent = nama;
    valEl.classList.remove('csel-placeholder');
    wrap.dataset.value = id;
    const dd = wrap.querySelector('.csel-dropdown');
    const trig = wrap.querySelector('.csel-trigger');
    if(dd) dd.classList.remove('open');
    if(trig) trig.classList.remove('open');
}
let K_WILAYAH_OPTS = [];
async function loadWilayahOptions() {
    try {
        const res = await fetch('/api/wilayah');
        const d = await res.json();
        if (!d.success) return;
        K_WILAYAH_OPTS = d.data.map(w => ({ id: w.id, kode_lokasi: w.kode_lokasi, nama_wilayah: w.nama_wilayah }));
    } catch(e) { console.warn('loadWilayah error', e); }
}

</script>
@endpush


