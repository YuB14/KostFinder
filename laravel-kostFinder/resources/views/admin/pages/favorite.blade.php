@extends('admin.layouts.admin')
@section('title', 'Favorit')
@section('page_title', 'Favorit')

@section('content')
    <div class="page active" id="page-favorite">
        <div class="page-header">
            <h2>Kost <em>Favorit</em> ❤️</h2>
            <p>Daftar kost yang disimpan dan difavoritkan pengguna.</p>
        </div>
        <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
            <div class="stat-card coral">
                <div class="stat-icon-wrap coral">❤️</div>
                <div class="stat-value" id="stat-total-fav">—</div>
                <div class="stat-label">Total Favorit</div>
            </div>
            <div class="stat-card teal">
                <div class="stat-icon-wrap teal">🏆</div>
                <div class="stat-value" id="stat-top-kost" style="font-size:16px">—</div>
                <div class="stat-label">Paling Banyak Difavoritkan</div>
            </div>
            <div class="stat-card yellow">
                <div class="stat-icon-wrap yellow">👤</div>
                <div class="stat-value" id="stat-avg-fav">—</div>
                <div class="stat-label">Avg. Favorit per User</div>
            </div>
        </div>
        <div style="display:flex;justify-content:flex-end;margin-bottom:16px">
            <button class="btn-sm primary" onclick="openAddFavorit()">+ Tambah Favorit</button>
        </div>
        <div class="fav-grid" id="fav-grid">
            <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:14px">⏳ Memuat data
                favorit...</div>
        </div>
    </div>

    {{-- MODAL TAMBAH FAVORIT --}}
    <div class="modal-overlay" id="modal-fav-add" onclick="closeModalOutside(event,this)">
        <div class="modal-box">
            <div class="modal-header">
                <h3>❤️ Tambah Favorit</h3><button class="modal-close" onclick="closeModal('modal-fav-add')">✕</button>
            </div>
            <div class="modal-body">
                <div class="mform-group">
                    <label>Pilih Kost</label>
                    <div class="csel-wrap" id="csel-fav-kost">
                        <div class="csel-trigger" onclick="toggleCsel('csel-fav-kost')"><span
                                class="csel-val csel-placeholder">Cari & pilih kost...</span></div>
                        <div class="csel-dropdown">
                            <input class="csel-search" placeholder="Ketik nama kost..."
                                oninput="searchCsel('csel-fav-kost',this.value)" />
                            {{--
                            PENTING: csel-empty ada di DALAM csel-fav-kost-opts
                            sehingga insertBefore(div, emptyEl) bisa berjalan dengan benar.
                            --}}
                            <div id="csel-fav-kost-opts">
                                <div class="csel-empty" id="csel-fav-empty" style="display:none">Tidak ditemukan</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="fav-kost-preview" style="display:none;margin-top:4px">
                    <div style="background:var(--bg2);border:1px solid var(--border);border-radius:12px;overflow:hidden">
                        <div id="fav-preview-foto"
                            style="width:100%;height:130px;background:var(--bg2);display:flex;align-items:center;justify-content:center;font-size:48px;overflow:hidden">
                        </div>
                        <div style="padding:14px 16px">
                            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
                                <div id="fav-preview-nama"
                                    style="font-family:'Syne',sans-serif;font-weight:800;font-size:15px"></div>
                                <span id="fav-preview-kelas"
                                    style="padding:3px 10px;border-radius:100px;font-size:11px;font-weight:700"></span>
                            </div>
                            <div id="fav-preview-alamat" style="font-size:12px;color:var(--muted);margin-bottom:6px"></div>
                            <div id="fav-preview-harga"
                                style="font-size:15px;font-weight:800;color:var(--coral);font-family:'Syne',sans-serif;margin-bottom:8px">
                            </div>
                            <div id="fav-preview-fasilitas" style="display:flex;flex-wrap:wrap;gap:5px"></div>
                            <div style="margin-top:10px;padding-top:10px;border-top:1px solid var(--border)">
                                <p style="font-size:11px;color:var(--muted);display:flex;align-items:center;gap:5px">🔒
                                    <span>Data kost tidak dapat diubah. Klik "Tambahkan" untuk menyimpan ke favorit.</span>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="fav-add-error" class="form-error-msg" style="display:none;margin-top:10px"></div>
            </div>
            <div class="modal-footer">
                <button class="btn-sm" onclick="closeModal('modal-fav-add')">Batal</button>
                <button class="btn-sm primary" id="btn-fav-add" onclick="submitAddFavorit()"><span
                        id="btn-fav-label">Tambahkan ❤️</span></button>
            </div>
        </div>
    </div>

    {{-- MODAL HAPUS FAVORIT --}}
    <div id="modal-fav-hapus" class="modal-overlay" onclick="closeModalOutside(event,this)">
        <div class="modal-box" style="max-width:380px;text-align:center">
            <div class="modal-body" style="padding-top:28px">
                <div
                    style="width:56px;height:56px;border-radius:16px;background:rgba(232,67,13,.1);display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 14px">
                    💔</div>
                <h3 style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800;margin-bottom:8px">Hapus dari
                    Favorit?</h3>
                <p style="font-size:13px;color:var(--muted);line-height:1.6" id="fav-hapus-msg">Kost akan dihapus dari
                    daftar favorit.</p>
            </div>
            <div class="modal-footer" style="justify-content:center;gap:10px">
                <button class="btn-sm" onclick="closeModal('modal-fav-hapus')">Batal</button>
                <button class="btn-sm" id="btn-fav-hapus-confirm"
                    style="background:#E53E3E;color:white;border-color:#E53E3E">Ya, Hapus</button>
            </div>
        </div>
    </div>

    <style>
        .form-error-msg {
            background: rgba(229, 62, 62, .08);
            border: 1px solid rgba(229, 62, 62, .2);
            border-radius: 8px;
            padding: 10px 13px;
            font-size: 12px;
            color: #E53E3E;
            margin-top: 4px;
        }

        .fav-kelas-ekonomis {
            background: var(--coral-bg);
            color: var(--coral);
        }

        .fav-kelas-standar {
            background: var(--teal-bg);
            color: var(--teal);
        }

        .fav-kelas-premium {
            background: var(--yellow-bg);
            color: var(--yellow);
        }
    </style>
@endsection

@push('scripts')
    <script>
        let allFavorits = [], allKostData = [], hapusFavId = null, selectedKostId = null;

        document.addEventListener('DOMContentLoaded', () => {
            loadFavorits();
            loadKostForDropdown();
        });

        async function loadFavorits() {
            try {
                const res = await fetch('/api/favorite'); const result = await res.json();
                if (!result.success) throw new Error(result.message ?? 'Gagal');
                allFavorits = result.data; renderStats(); renderFavorits(allFavorits);
            } catch (err) {
                console.error('loadFavorits:', err);
                document.getElementById('fav-grid').innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:48px;color:#E53E3E;font-size:13px">Gagal memuat data favorit.</div>';
            }
        }

        async function loadKostForDropdown() {
            try {
                const res = await fetch('/api/kost'); const result = await res.json();
                if (!result.success) return;
                allKostData = result.data;
                buildKostDropdown(allKostData);
            } catch (err) { console.error('loadKostForDropdown:', err); }
        }

        function buildKostDropdown(kosts) {
            const optsEl = document.getElementById('csel-fav-kost-opts');
            if (!optsEl) return;

            /* Hapus semua opsi lama, sisakan .csel-empty */
            optsEl.querySelectorAll('.csel-opt').forEach(el => el.remove());

            /* emptyEl ADA di dalam optsEl — insertBefore sekarang aman */
            const emptyEl = document.getElementById('csel-fav-empty');

            kosts.forEach(k => {
                const div = document.createElement('div');
                div.className = 'csel-opt'; div.dataset.val = k.id; div.dataset.nama = k.nama_kost;
                div.textContent = '🏘️ ' + k.nama_kost + ' — ' + formatRupiah(k.harga_kost) + '/bln';
                div.onclick = () => {
                    const wrap = document.getElementById('csel-fav-kost');
                    wrap.querySelector('.csel-val').textContent = k.nama_kost;
                    wrap.querySelector('.csel-val').classList.remove('csel-placeholder');
                    wrap.dataset.value = k.id;
                    optsEl.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
                    div.classList.add('active');
                    wrap.querySelector('.csel-dropdown').classList.remove('open');
                    wrap.querySelector('.csel-trigger').classList.remove('open');
                    selectedKostId = k.id; showKostPreview(k);
                    document.getElementById('fav-add-error').style.display = 'none';
                };
                /* insertBefore emptyEl yang ada di dalam optsEl */
                if (emptyEl && emptyEl.parentNode === optsEl) optsEl.insertBefore(div, emptyEl);
                else optsEl.appendChild(div);
            });
        }

        function showKostPreview(k) {
            document.getElementById('fav-kost-preview').style.display = 'block';
            const fotoWrap = document.getElementById('fav-preview-foto');
            fotoWrap.innerHTML = k.foto_kost ? `<img src="${k.foto_kost}" style="width:100%;height:100%;object-fit:cover;"/>` : '<span style="font-size:48px">🏘️</span>';
            const kelasMap = { Ekonomis: 'fav-kelas-ekonomis', Standar: 'fav-kelas-standar', Premium: 'fav-kelas-premium' };
            const kelasEl = document.getElementById('fav-preview-kelas'); kelasEl.textContent = k.kelas ?? ''; kelasEl.className = kelasMap[k.kelas] || 'fav-kelas-standar';
            document.getElementById('fav-preview-nama').textContent = k.nama_kost ?? '';
            document.getElementById('fav-preview-alamat').textContent = '📍 ' + (k.alamat_kost ?? '');
            document.getElementById('fav-preview-harga').textContent = formatRupiah(k.harga_kost) + '/bulan';
            const tags = (k.fasilitas ?? '').split(',').map(f => f.trim()).filter(Boolean);
            document.getElementById('fav-preview-fasilitas').innerHTML = tags.slice(0, 4).map(f => `<span style="background:var(--bg);border:1px solid var(--border);border-radius:100px;padding:3px 9px;font-size:11px;color:var(--muted)">${f}</span>`).join('');
        }

        function renderStats() {
            document.getElementById('stat-total-fav').textContent = allFavorits.length;
            if (allFavorits.length) { const g = {}; allFavorits.forEach(f => { g[f.kost_nama] = (g[f.kost_nama] || 0) + 1; }); const top = Object.entries(g).sort((a, b) => b[1] - a[1])[0]?.[0] ?? '-'; document.getElementById('stat-top-kost').textContent = top; }
            else document.getElementById('stat-top-kost').textContent = '-';
            const uids = [...new Set(allFavorits.map(f => f.user_id))];
            document.getElementById('stat-avg-fav').textContent = uids.length ? (allFavorits.length / uids.length).toFixed(1) : '0';
        }

        function formatRupiah(n) { return 'Rp ' + Number(n || 0).toLocaleString('id-ID'); }

        function renderFavorits(favs) {
            const grid = document.getElementById('fav-grid');
            if (!favs.length) { grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:13px">Belum ada kost favorit.</div>'; return; }
            grid.innerHTML = favs.map(f => {
                const namaEsc = (f.kost_nama || '').replace(/'/g, "\\'");
                const fotoHtml = f.kost_foto ? `<img src="${f.kost_foto}" style="width:100%;height:100%;object-fit:cover;position:absolute;inset:0"/>` : '<span style="font-size:48px;position:absolute;top:50%;left:50%;transform:translate(-50%,-50%)">🏘️</span>';
                const favCount = f.fav_count > 0 ? f.fav_count.toLocaleString('id-ID') : 'baru';
                return `<div class="fav-card" data-id="${f.id}" data-nama="${f.kost_nama}">
    <div class="fav-img" style="position:relative;overflow:hidden">${fotoHtml}<div class="fav-heart" onclick="openHapusFavorit('${f.id}','${namaEsc}')">❤️</div></div>
    <div class="fav-body"><div class="fav-name">${f.kost_nama}</div><div class="fav-loc">📍 ${f.kost_alamat}</div><div class="fav-price">${formatRupiah(f.kost_harga)}<span>/bulan</span></div></div>
    <div class="fav-footer"><span class="pill ${f.pill_class}">${f.kost_status}</span><span style="font-size:11px;color:var(--muted)">❤️ ${favCount}</span></div>
    </div>`;
            }).join('');
        }

        function openAddFavorit() {
            selectedKostId = null;
            const wrap = document.getElementById('csel-fav-kost');
            wrap.querySelector('.csel-val').textContent = 'Cari & pilih kost...'; wrap.querySelector('.csel-val').classList.add('csel-placeholder');
            wrap.dataset.value = '';
            wrap.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
            const s = wrap.querySelector('.csel-search');
            if (s) { s.value = ''; searchCsel('csel-fav-kost', ''); }
            document.getElementById('fav-kost-preview').style.display = 'none';
            document.getElementById('fav-add-error').style.display = 'none';
            openModal('modal-fav-add');
        }

        async function submitAddFavorit() {
            const kostId = document.getElementById('csel-fav-kost').dataset.value || '';
            const errorEl = document.getElementById('fav-add-error');
            if (!kostId) { showFormError(errorEl, 'Pilih kost terlebih dahulu.'); return; }
            setBtnLoading('btn-fav-add', 'btn-fav-label', true, 'Menyimpan...');
            try {
                const res = await fetch('/api/favorite', { method: 'POST', headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' }, body: JSON.stringify({ kost_id: kostId }) });
                const data = await res.json();
                if (data.success || res.status === 201) { allFavorits.unshift(data.data); renderStats(); renderFavorits(allFavorits); closeModal('modal-fav-add'); showToast((data.data?.kost_nama || 'Kost') + ' ditambahkan ke favorit', '❤️'); }
                else if (res.status === 409) { showFormError(errorEl, data.message || 'Kost sudah ada di daftar favorit.'); }
                else { showFormError(errorEl, data.message || 'Gagal menyimpan.'); }
            } catch (err) { console.error(err); showFormError(errorEl, 'Terjadi kesalahan server.'); }
            finally { setBtnLoading('btn-fav-add', 'btn-fav-label', false, 'Tambahkan ❤️'); }
        }

        function openHapusFavorit(id, nama) { hapusFavId = id; document.getElementById('fav-hapus-msg').textContent = `"${nama}" akan dihapus dari daftar favorit.`; document.getElementById('btn-fav-hapus-confirm').onclick = confirmHapusFavorit; openModal('modal-fav-hapus'); }
        async function confirmHapusFavorit() {
            if (!hapusFavId) return; const btn = document.getElementById('btn-fav-hapus-confirm'); btn.disabled = true; btn.textContent = 'Menghapus...';
            try {
                const res = await fetch(`/api/favorite/${hapusFavId}`, { method: 'DELETE', headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' } });
                const data = await res.json();
                if (data.success || res.ok) { allFavorits = allFavorits.filter(f => String(f.id) !== String(hapusFavId)); renderStats(); renderFavorits(allFavorits); closeModal('modal-fav-hapus'); showToast('Favorit berhasil dihapus', '💔'); }
                else showToast(data.message || 'Gagal menghapus.', '❌');
            } catch (err) { console.error(err); showToast('Terjadi kesalahan server.', '❌'); }
            finally { btn.disabled = false; btn.textContent = 'Ya, Hapus'; hapusFavId = null; }
        }

        function showFormError(el, msg) { el.textContent = msg; el.style.display = 'block'; }
        function setBtnLoading(bId, lId, load, text) { document.getElementById(bId).disabled = load; document.getElementById(lId).textContent = text; }
        if (typeof getCselVal === 'undefined') { window.getCselVal = id => { const w = document.getElementById(id); return w ? (w.dataset.value || w.querySelector('.csel-val')?.textContent.trim() || '') : ''; }; }
        if (typeof setCselVal === 'undefined') { window.setCselVal = (id, val) => { const w = document.getElementById(id); if (!w) return; const opt = [...w.querySelectorAll('.csel-opt')].find(o => o.dataset.val === val || o.textContent.trim().includes(val)); if (opt) { w.querySelector('.csel-val').textContent = opt.textContent.trim(); w.querySelector('.csel-val').classList.remove('csel-placeholder'); w.dataset.value = opt.dataset.val; w.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active')); opt.classList.add('active'); } }; }
        if (typeof searchCsel === 'undefined') { window.searchCsel = (id, q) => { const wrap = document.getElementById(id); if (!wrap) return; const query = q.toLowerCase(); let visible = 0; wrap.querySelectorAll('.csel-opt').forEach(o => { const match = o.textContent.toLowerCase().includes(query); o.style.display = match ? '' : 'none'; if (match) visible++; }); const empty = wrap.querySelector('.csel-empty'); if (empty) empty.style.display = visible === 0 ? '' : 'none'; }; }
        if (typeof toggleCsel === 'undefined') { window.toggleCsel = id => { const wrap = document.getElementById(id); const dd = wrap.querySelector('.csel-dropdown'); const trig = wrap.querySelector('.csel-trigger'); const isOpen = dd.classList.contains('open'); document.querySelectorAll('.csel-dropdown.open').forEach(d => { d.classList.remove('open'); d.closest('.csel-wrap').querySelector('.csel-trigger').classList.remove('open'); }); if (!isOpen) { dd.classList.add('open'); trig.classList.add('open'); } }; }
    </script>
@endpush
