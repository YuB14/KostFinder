@extends('user.layouts.auth-user')
@section('title', 'Cari Kost')
@section('page_title', 'Cari Kost')

@section('content')
    <div class="page-header">
        <h2>Temukan <em>Kost</em> Idamanmu 🏘️</h2>
        <p>Jelajahi ratusan kost terbaik di sekitarmu.</p>
    </div>

    {{-- FILTER & SEARCH --}}
    <div style="display:flex;align-items:center;gap:10px;margin-bottom:20px;flex-wrap:wrap">
        <div class="search-input-sm" style="flex:1;min-width:200px">
            <span>🔍</span>
            <input type="text" id="search-kost" placeholder="Cari nama, alamat, fasilitas..." />
        </div>
        <div class="filter-wrap">
            <button class="btn-sm" onclick="toggleFilter('filter-kelas')">Kelas ▾</button>
            <div class="filter-dropdown" id="filter-kelas">
                <div class="filter-opt active" onclick="setFilter('kelas','semua',this)">🏘️ Semua Kelas</div>
                <div class="filter-sep"></div>
                <div class="filter-opt" onclick="setFilter('kelas','Ekonomis',this)">💚 Ekonomis</div>
                <div class="filter-opt" onclick="setFilter('kelas','Standar',this)">🔵 Standar</div>
                <div class="filter-opt" onclick="setFilter('kelas','Premium',this)">⭐ Premium</div>
            </div>
        </div>
        <div class="filter-wrap">
            <button class="btn-sm" onclick="toggleFilter('filter-jenis')">Jenis ▾</button>
            <div class="filter-dropdown" id="filter-jenis">
                <div class="filter-opt active" onclick="setFilter('jenis','semua',this)">🏠 Semua Jenis</div>
                <div class="filter-sep"></div>
                <div class="filter-opt" onclick="setFilter('jenis','Pria',this)">👨 Pria</div>
                <div class="filter-opt" onclick="setFilter('jenis','Wanita',this)">👩 Wanita</div>
                <div class="filter-opt" onclick="setFilter('jenis','Bebas',this)">👥 Bebas</div>
            </div>
        </div>
        <div class="filter-wrap">
            <button class="btn-sm" onclick="toggleFilter('filter-harga')">Harga ▾</button>
            <div class="filter-dropdown" id="filter-harga">
                <div class="filter-opt active" onclick="setFilter('harga','semua',this)">💰 Semua Harga</div>
                <div class="filter-sep"></div>
                <div class="filter-opt" onclick="setFilter('harga','0-500000',this)">&lt; Rp 500rb</div>
                <div class="filter-opt" onclick="setFilter('harga','500000-1000000',this)">Rp 500rb – 1jt</div>
                <div class="filter-opt" onclick="setFilter('harga','1000000-9999999',this)">&gt; Rp 1jt</div>
            </div>
        </div>
        <div id="result-count" style="font-size:12px;color:var(--muted)"></div>
    </div>

        {{-- GRID --}}
        <div class="kost-grid-user" id="kost-grid">
            <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted)">⏳ Memuat data kost...</div>
        </div>

                {{-- MODAL DETAIL KOST --}}
        <div class="modal-overlay" id="modal-kost-detail" onclick="closeModalOutside(event,this)">
            <div class="modal-box" style="max-width:560px">
                <div class="modal-header">
                    <h3>🏘️ Detail Kost</h3>
                    <button class="modal-close" onclick="closeModal('modal-kost-detail')">✕</button>
                </div>
                <div class="modal-body">
                    <div id="kd-foto"
                        style="width:100%;height:200px;border-radius:12px;overflow:hidden;margin-bottom:18px;background:var(--bg2);display:flex;align-items:center;justify-content:center;font-size:64px">
                    </div>
                    <div
                        style="display:flex;align-items:flex-start;gap:12px;margin-bottom:16px;padding-bottom:16px;border-bottom:1px solid var(--border)">
                        <div style="flex:1">
                            <div id="kd-nama" style="font-family:'Syne',sans-serif;font-size:18px;font-weight:800"></div>
                            <div id="kd-lokasi" style="font-size:12px;color:var(--muted);margin-top:4px"></div>
                        </div>
                        <div style="display:flex;gap:6px;flex-shrink:0">
                            <span id="kd-jenis" class="pill muted" style="flex-shrink:0"></span>
                            <span id="kd-kelas" class="pill" style="flex-shrink:0"></span>
                        </div>
                    </div>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px">
                        <div style="background:var(--bg);border-radius:10px;padding:12px">
                            <div
                                style="font-size:11px;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.4px">
                                Harga/Bulan</div>
                            <div id="kd-harga"
                                style="font-family:'Syne',sans-serif;font-size:18px;font-weight:800;color:var(--coral);margin-top:4px">
                            </div>
                        </div>
                        <div style="background:var(--bg);border-radius:10px;padding:12px">
                            <div
                                style="font-size:11px;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.4px">
                                Rating</div>
                            <div id="kd-rating" style="font-size:18px;margin-top:4px"></div>
                        </div>
                    </div>
                    <div style="margin-bottom:14px">
                        <div
                            style="font-size:12px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:8px">
                            Fasilitas</div>
                        <div id="kd-fasilitas" style="display:flex;flex-wrap:wrap;gap:6px"></div>
                    </div>
                    <div style="margin-bottom:14px">
                        <div
                            style="font-size:12px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:6px">
                            Telepon</div>
                        <div id="kd-telepon" style="font-size:13px"></div>
                    </div>

                    {{-- SECTION ULASAN PENGGUNA LAIN --}}
                    <div style="border-top:1px solid var(--border);padding-top:16px;margin-top:4px">
                        <div style="font-size:12px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:12px">⭐ Ulasan Pengguna</div>
                        <div id="kd-reviews" style="display:flex;flex-direction:column;gap:10px">
                            <div style="text-align:center;color:var(--muted);font-size:12px;padding:12px">⏳ Memuat ulasan...</div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-sm" onclick="closeModal('modal-kost-detail')">Tutup</button>
                    <button class="btn-sm primary" id="btn-fav-kost" onclick="tambahFavoritDariDetail()">❤️ Simpan
                        Favorit</button>
                </div>
            </div>
        </div>
@endsection

    @push('scripts')
        <script>
            let allKosts = [], filters = { kelas: 'semua', harga: 'semua', jenis: 'semua' }, searchQ = '';
            let selectedKostId = null;

            document.addEventListener('DOMContentLoaded', () => {
                loadKosts();
                document.getElementById('search-kost').addEventListener('input', e => { searchQ = e.target.value; applyFilter(); });
            });

            async function loadKosts() {
                try {
                    const res = await fetch('/api/user/kost');
                    const result = await res.json();
                    if (!result.success) throw new Error('Gagal');
                    allKosts = result.data;
                    applyFilter();
                } catch (err) {
                    document.getElementById('kost-grid').innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:48px;color:#E53E3E">Gagal memuat data kost.</div>';
                }
            }

            function setFilter(type, val, el) {
                filters[type] = val;
                document.querySelectorAll(`#filter-${type} .filter-opt`).forEach(o => o.classList.remove('active'));
                el.classList.add('active');
                document.getElementById(`filter-${type}`).classList.remove('open');
                applyFilter();
            }

            function applyFilter() {
                const q = searchQ.toLowerCase();
                const filtered = allKosts.filter(k => {
                    if (filters.kelas !== 'semua' && k.kelas !== filters.kelas) return false;
                    if (filters.jenis !== 'semua' && (k.jenis_kost || 'Bebas') !== filters.jenis) return false;
                    if (filters.harga !== 'semua') {
                        const [mn, mx] = filters.harga.split('-').map(Number);
                        if (k.harga_kost < mn || k.harga_kost > mx) return false;
                    }
                    if (q) {
                        const haystack = [(k.nama_kost || ''), (k.alamat_kost || ''), (k.fasilitas || ''), (k.kelas || ''), (k.jenis_kost || '')].join(' ').toLowerCase();
                        if (!haystack.includes(q)) return false;
                    }
                    return true;
                });
                document.getElementById('result-count').textContent = `${filtered.length} kost ditemukan`;
                renderKosts(filtered);
            }

            function kelasClass(k) {
                const t = (k || '').toLowerCase();
                return t === 'ekonomis' ? 'green' : t === 'standar' ? 'blue' : t === 'premium' ? 'yellow' : 'muted';
            }

            function renderKosts(kosts) {
                const grid = document.getElementById('kost-grid');
                if (!kosts.length) {
                    grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted)">Tidak ada kost yang cocok.</div>';
                    return;
                }
                grid.innerHTML = kosts.map(k => {
                    const jenisEmoji = { Pria: '👨', Wanita: '👩', Bebas: '👥' }[k.jenis_kost || 'Bebas'] || '🏠';
                    const d = JSON.stringify({ id: k.id, nama: k.nama_kost, lokasi: k.alamat_kost, harga: k.harga_kost, kelas: k.kelas, jenis: k.jenis_kost || 'Bebas', foto: k.foto_kost || '', rating: k.avg_rating || 0, ulasan: k.reviews_count || 0, fasilitas: k.fasilitas || '', telepon: k.nomor_telepon || '' }).replace(/'/g, "&#39;");
                    return `
            <div class="kost-card-user" onclick='openDetailKost(${d})'>
                <div class="kcu-img">
                    ${k.foto_kost ? `<img src="${k.foto_kost}" style="width:100%;height:100%;object-fit:cover;">` : '<span style="font-size:48px">🏘️</span>'}
                    <span class="pill ${kelasClass(k.kelas)}" style="position:absolute;top:8px;left:8px">${k.kelas}</span>
                    <span style="position:absolute;top:8px;right:8px;background:rgba(255,255,255,.9);padding:2px 8px;border-radius:100px;font-size:11px;font-weight:600">${jenisEmoji} ${k.jenis_kost || 'Bebas'}</span>
                </div>
                <div class="kcu-body">
                    <div class="kcu-name">${k.nama_kost}</div>
                    <div class="kcu-loc">📍 ${k.alamat_kost}</div>
                    <div class="kcu-price">${formatRupiah(k.harga_kost)}<span>/bulan</span></div>
                </div>
                <div class="kcu-footer">
                    <span class="kcu-stars">${renderStars(k.avg_rating || 0)}</span>
                    <span style="font-size:11px;color:var(--muted)">${k.reviews_count || 0} ulasan</span>
                </div>
            </div>`;
                }).join('');
            }

            function openDetailKost(d) {
                selectedKostId = d.id;
                document.getElementById('kd-foto').innerHTML = d.foto ? `<img src="${d.foto}" style="width:100%;height:100%;object-fit:cover;">` : '🏘️';
                document.getElementById('kd-nama').textContent = d.nama;
                document.getElementById('kd-lokasi').textContent = '📍 ' + d.lokasi;
                document.getElementById('kd-harga').textContent = formatRupiah(d.harga) + '/bln';
                document.getElementById('kd-rating').innerHTML = `<span style="color:var(--yellow)">${renderStars(d.rating)}</span> ${parseFloat(d.rating).toFixed(1)}`;
                // Kelas pill
                const kelasEl = document.getElementById('kd-kelas');
                kelasEl.textContent = d.kelas;
                kelasEl.className = 'pill ' + kelasClass(d.kelas);
                // Jenis pill
                const jenisEl = document.getElementById('kd-jenis');
                const jenisEmoji = { Pria: '👨', Wanita: '👩', Bebas: '👥' }[d.jenis || 'Bebas'] || '🏠';
                jenisEl.textContent = jenisEmoji + ' ' + (d.jenis || 'Bebas');
                document.getElementById('kd-telepon').textContent = d.telepon || '-';
                const tags = (d.fasilitas || '').split(',').map(f => f.trim()).filter(Boolean);
                document.getElementById('kd-fasilitas').innerHTML = tags.map(f => `<span style="background:var(--bg);border:1px solid var(--border);border-radius:100px;padding:4px 10px;font-size:12px">${f}</span>`).join('') || '<span style="color:var(--muted);font-size:12px">-</span>';
                openModal('modal-kost-detail');
                // Muat ulasan pengguna lain
                loadKostReviews(d.id);
            }

            async function loadKostReviews(kostId) {
                const el = document.getElementById('kd-reviews');
                el.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:12px;padding:12px">⏳ Memuat ulasan...</div>';
                try {
                    const res = await fetch(`/api/user/kost/${kostId}/reviews`);
                    const result = await res.json();
                    if (!result.success || !result.data.length) {
                        el.innerHTML = '<div style="text-align:center;color:var(--muted);font-size:12px;padding:12px">💭 Belum ada ulasan yang disetujui untuk kost ini.</div>';
                        return;
                    }
                    el.innerHTML = result.data.map(r => `
                        <div style="background:var(--bg);border-radius:10px;padding:12px 14px">
                            <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px">
                                <div style="width:30px;height:30px;border-radius:50%;background:${r.user_color};display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:white;flex-shrink:0">${r.user_initials}</div>
                                <div style="flex:1">
                                    <div style="font-size:13px;font-weight:700">${r.user_name}</div>
                                    <div style="color:var(--yellow);font-size:12px">${renderStars(r.rating)}</div>
                                </div>
                                <div style="font-size:11px;color:var(--muted)">${r.created_at}</div>
                            </div>
                            <div style="font-size:13px;color:var(--text2);line-height:1.6">&ldquo;${r.komentar}&rdquo;</div>
                        </div>`);
                } catch (err) {
                    el.innerHTML = '<div style="text-align:center;color:#E53E3E;font-size:12px;padding:12px">Gagal memuat ulasan.</div>';
                }
            }

            async function tambahFavoritDariDetail() {
                if (!selectedKostId) return;
                const btn = document.getElementById('btn-fav-kost');
                btn.disabled = true; btn.textContent = 'Menyimpan...';
                try {
                    const res = await fetch('/api/user/favorite', {
                        method: 'POST',
                        headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                        body: JSON.stringify({ kost_id: selectedKostId }),
                    });
                    const data = await res.json();
                    if (data.success || res.status === 201) { showToast('Berhasil ditambahkan ke favorit!', '❤️'); closeModal('modal-kost-detail'); }
                    else if (res.status === 409) showToast(data.message || 'Sudah ada di favorit.', '⚠️');
                    else showToast(data.message || 'Gagal.', '❌');
                } catch (err) { showToast('Kesalahan server.', '❌'); }
                finally { btn.disabled = false; btn.textContent = '❤️ Simpan Favorit'; }
            }
        </script>
    @endpush
