@extends('admin.layouts.admin')
@section('page_title', 'Ulasan')
@section('title', 'Manajemen Ulasan')

@section('content')
    <div class="page active" id="page-review">
        <div class="page-header">
            <h2>Manajemen <em>Ulasan</em></h2>
            <p>Pantau dan moderasi ulasan pengguna pada seluruh kost.</p>
        </div>
        <div class="stats-grid">
            <div class="stat-card yellow">
                <div class="stat-icon-wrap yellow">⭐</div>
                <div class="stat-value" id="stat-total">—</div>
                <div class="stat-label">Total Ulasan</div>
            </div>
            <div class="stat-card teal">
                <div class="stat-icon-wrap teal">✅</div>
                <div class="stat-value" id="stat-disetujui">—</div>
                <div class="stat-label">Disetujui</div>
            </div>
            <div class="stat-card coral">
                <div class="stat-icon-wrap coral">⏳</div>
                <div class="stat-value" id="stat-menunggu">—</div>
                <div class="stat-label">Menunggu</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-icon-wrap blue">🚫</div>
                <div class="stat-value" id="stat-ditolak">—</div>
                <div class="stat-label">Ditolak</div>
            </div>
        </div>
        <div
            style="display:flex;align-items:center;justify-content:space-between;margin-bottom:18px;gap:10px;flex-wrap:wrap">
            <div class="filter-wrap">
                <button class="btn-sm" onclick="toggleFilter('filter-review')">Filter Status ▾</button>
                <div class="filter-dropdown" id="filter-review">
                    <div class="filter-opt active" onclick="setReviewFilter('semua',this)">📋 Semua</div>
                    <div class="filter-sep"></div>
                    <div class="filter-opt" onclick="setReviewFilter('Disetujui',this)">✅ Disetujui</div>
                    <div class="filter-opt" onclick="setReviewFilter('Menunggu',this)">⏳ Menunggu</div>
                    <div class="filter-opt" onclick="setReviewFilter('Ditolak',this)">🚫 Ditolak</div>
                </div>
            </div>
            <button class="btn-sm primary" onclick="openAddReview()">+ Tambah Ulasan</button>
        </div>
        <div class="review-grid" id="review-grid">
            <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:14px">⏳ Memuat
                ulasan...</div>
        </div>
    </div>

    {{-- MODAL TAMBAH --}}
    <div class="modal-overlay" id="modal-review-add" onclick="closeModalOutside(event,this)">
        <div class="modal-box">
            <div class="modal-header">
                <h3>⭐ Tambah Ulasan</h3><button class="modal-close" onclick="closeModal('modal-review-add')">✕</button>
            </div>
            <div class="modal-body">
                <div class="mform-group">
                    <label>Nama Pengguna</label>
                    <div style="position:relative">
                        <input type="text" id="ar-nama" value="{{ Auth::user()->name }}" readonly
                            style="background:var(--bg2);cursor:not-allowed;color:var(--muted);padding-right:36px" />
                        <span
                            style="position:absolute;right:13px;top:50%;transform:translateY(-50%);font-size:13px;color:var(--muted)"
                            title="Nama diambil dari akun yang login">🔒</span>
                    </div>
                    <p style="font-size:11px;color:var(--muted);margin-top:4px">Nama diambil otomatis dari akun yang sedang
                        login.</p>
                </div>
                <div class="mform-group">
                    <label>Kost</label>
                    <div class="csel-wrap" id="csel-ar-kost">
                        <div class="csel-trigger" onclick="toggleCsel('csel-ar-kost')"><span
                                class="csel-val csel-placeholder">Pilih kost...</span></div>
                        <div class="csel-dropdown">
                            <input class="csel-search" placeholder="Cari kost..."
                                oninput="searchCsel('csel-ar-kost',this.value)" />
                            <div id="csel-ar-kost-opts">
                                <div class="csel-empty" style="display:none">Tidak ada hasil</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>Rating</label>
                    <div class="star-input">
                        <input type="radio" name="nar" id="nar5" value="5" /><label for="nar5">★</label>
                        <input type="radio" name="nar" id="nar4" value="4" /><label for="nar4">★</label>
                        <input type="radio" name="nar" id="nar3" value="3" /><label for="nar3">★</label>
                        <input type="radio" name="nar" id="nar2" value="2" /><label for="nar2">★</label>
                        <input type="radio" name="nar" id="nar1" value="1" /><label for="nar1">★</label>
                    </div>
                </div>
                <div class="mform-group"><label>Ulasan</label>
                    <textarea id="ar-komentar" placeholder="Tulis ulasan di sini..."
                        style="width:100%;background:var(--bg);border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;font-family:'DM Sans',sans-serif;font-size:13px;color:var(--text);outline:none;resize:vertical;min-height:80px;transition:border-color .2s,box-shadow .2s"
                        onfocus="this.style.borderColor='var(--coral)';this.style.boxShadow='0 0 0 3px rgba(232,67,13,.09)'"
                        onblur="this.style.borderColor='';this.style.boxShadow=''"></textarea>
                </div>
                <div class="mform-group"><label>Status</label>
                    <div class="csel-wrap" id="csel-ar-status">
                        <div class="csel-trigger" onclick="toggleCsel('csel-ar-status')"><span
                                class="csel-val">Menunggu</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="Menunggu" onclick="pickCsel('csel-ar-status',this)">⏳
                                Menunggu</div>
                            <div class="csel-opt" data-val="Disetujui" onclick="pickCsel('csel-ar-status',this)">✅ Disetujui
                            </div>
                            <div class="csel-opt" data-val="Ditolak" onclick="pickCsel('csel-ar-status',this)">🚫 Ditolak
                            </div>
                        </div>
                    </div>
                </div>
                <div id="ar-error" class="form-error-msg" style="display:none"></div>
            </div>
            <div class="modal-footer">
                <button class="btn-sm" onclick="closeModal('modal-review-add')">Batal</button>
                <button class="btn-sm primary" id="btn-ar-save" onclick="submitAddReview()"><span
                        id="btn-ar-label">Simpan</span></button>
            </div>
        </div>
    </div>

    {{-- MODAL EDIT --}}
    <div class="modal-overlay" id="modal-review-edit" onclick="closeModalOutside(event,this)">
        <div class="modal-box">
            <div class="modal-header">
                <h3>✏️ Edit Ulasan</h3><button class="modal-close" onclick="closeModal('modal-review-edit')">✕</button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="er-id" />
                <div class="mform-group">
                    <label>Nama Pengguna</label>
                    <input type="text" id="er-nama" readonly style="opacity:.6" />
                </div>
                {{-- Kost bisa diganti via dropdown --}}
                <div class="mform-group">
                    <label>Kost <span style="font-size:11px;color:var(--muted);font-weight:400">(bisa
                            diganti)</span></label>
                    <div class="csel-wrap" id="csel-er-kost">
                        <div class="csel-trigger" onclick="toggleCsel('csel-er-kost')"><span
                                class="csel-val csel-placeholder">Pilih kost...</span></div>
                        <div class="csel-dropdown">
                            <input class="csel-search" placeholder="Cari kost..."
                                oninput="searchCsel('csel-er-kost',this.value)" />
                            <div id="csel-er-kost-opts">
                                <div class="csel-empty" style="display:none">Tidak ada hasil</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>Rating</label>
                    <div class="star-input">
                        <input type="radio" name="er-r" id="er-r5" value="5" /><label for="er-r5">★</label>
                        <input type="radio" name="er-r" id="er-r4" value="4" /><label for="er-r4">★</label>
                        <input type="radio" name="er-r" id="er-r3" value="3" /><label for="er-r3">★</label>
                        <input type="radio" name="er-r" id="er-r2" value="2" /><label for="er-r2">★</label>
                        <input type="radio" name="er-r" id="er-r1" value="1" /><label for="er-r1">★</label>
                    </div>
                </div>
                <div class="mform-group"><label>Ulasan</label>
                    <textarea id="er-teks"
                        style="width:100%;background:var(--bg);border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;font-family:'DM Sans',sans-serif;font-size:13px;color:var(--text);outline:none;resize:vertical;min-height:80px;transition:border-color .2s,box-shadow .2s"
                        onfocus="this.style.borderColor='var(--coral)';this.style.boxShadow='0 0 0 3px rgba(232,67,13,.09)'"
                        onblur="this.style.borderColor='';this.style.boxShadow=''"></textarea>
                </div>
                <div class="mform-group"><label>Status</label>
                    <div class="csel-wrap" id="csel-er-status">
                        <div class="csel-trigger" onclick="toggleCsel('csel-er-status')"><span
                                class="csel-val">Menunggu</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="Menunggu" onclick="pickCsel('csel-er-status',this)">⏳
                                Menunggu</div>
                            <div class="csel-opt" data-val="Disetujui" onclick="pickCsel('csel-er-status',this)">✅ Disetujui
                            </div>
                            <div class="csel-opt" data-val="Ditolak" onclick="pickCsel('csel-er-status',this)">🚫 Ditolak
                            </div>
                        </div>
                    </div>
                </div>
                <div id="er-error" class="form-error-msg" style="display:none"></div>
            </div>
            <div class="modal-footer">
                <button class="btn-sm" onclick="closeModal('modal-review-edit')">Batal</button>
                <button class="btn-sm primary" id="btn-er-save" onclick="submitEditReview()"><span
                        id="btn-er-label">Simpan</span></button>
            </div>
        </div>
    </div>

    {{-- MODAL HAPUS --}}
    <div id="modal-review-hapus" class="modal-overlay" onclick="closeModalOutside(event,this)">
        <div class="modal-box" style="max-width:380px;text-align:center">
            <div class="modal-body" style="padding-top:28px">
                <div
                    style="width:56px;height:56px;border-radius:16px;background:rgba(229,62,62,.1);display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 14px">
                    🗑️</div>
                <h3 style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800;margin-bottom:8px">Hapus Ulasan?
                </h3>
                <p style="font-size:13px;color:var(--muted);line-height:1.6" id="review-hapus-msg">Ulasan akan dihapus
                    permanen.</p>
            </div>
            <div class="modal-footer" style="justify-content:center;gap:10px">
                <button class="btn-sm" onclick="closeModal('modal-review-hapus')">Batal</button>
                <button class="btn-sm" id="btn-review-hapus-confirm"
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

        .rv-actions {
            display: flex;
            gap: 6px;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid var(--border);
            justify-content: flex-end;
        }

        .star-input {
            display: flex;
            gap: 4px;
            flex-direction: row-reverse;
            justify-content: flex-end;
        }

        .star-input input {
            display: none;
        }

        .star-input label {
            font-size: 22px;
            cursor: pointer;
            color: var(--bg2);
            transition: color .15s;
        }

        .star-input input:checked~label,
        .star-input label:hover,
        .star-input label:hover~label {
            color: var(--yellow);
        }
    </style>
@endsection

@push('scripts')
    <script>
        let allReviews = [], activeReviewFilter = 'semua', hapusReviewId = null, allKostList = [];

        document.addEventListener('DOMContentLoaded', () => {
            loadReviews();
            loadKostList();
        });

        async function loadReviews() {
            try {
                const res = await fetch('/api/review'); const result = await res.json();
                if (!result.success) throw new Error(result.message ?? 'Gagal');
                allReviews = result.data; renderStats(); applyReviewFilter();
            } catch (err) {
                console.error('loadReviews:', err);
                document.getElementById('review-grid').innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:48px;color:#E53E3E;font-size:13px">Gagal memuat ulasan.</div>';
            }
        }

        async function loadKostList() {
            try {
                const res = await fetch('/api/kost'); const result = await res.json();
                if (!result.success) return;
                allKostList = result.data;
                fillKostDropdown('csel-ar-kost', 'csel-ar-kost-opts', null);
            } catch (err) { console.error('loadKostList:', err); }
        }

        /* Isi dropdown kost — dipakai di modal tambah DAN edit */
        function fillKostDropdown(wrapId, optsId, selectedId) {
            const optsEl = document.getElementById(optsId); if (!optsEl) return;
            optsEl.querySelectorAll('.csel-opt').forEach(el => el.remove());
            const emptyEl = optsEl.querySelector('.csel-empty');
            allKostList.forEach(k => {
                const div = document.createElement('div');
                div.className = 'csel-opt'; div.dataset.val = k.id;
                div.textContent = '🏘️ ' + k.nama_kost;
                if (k.id === selectedId) div.classList.add('active');
                div.onclick = () => {
                    const wrap = document.getElementById(wrapId);
                    wrap.querySelector('.csel-val').textContent = k.nama_kost;
                    wrap.querySelector('.csel-val').classList.remove('csel-placeholder');
                    wrap.dataset.value = k.id; wrap.dataset.kostId = k.id; wrap.dataset.kostNama = k.nama_kost;
                    optsEl.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
                    div.classList.add('active');
                    wrap.querySelector('.csel-dropdown').classList.remove('open');
                    wrap.querySelector('.csel-trigger').classList.remove('open');
                };
                /* emptyEl ADA di dalam optsEl — insertBefore aman */
                if (emptyEl) optsEl.insertBefore(div, emptyEl); else optsEl.appendChild(div);
            });
            /* Set nilai trigger jika ada selectedId */
            if (selectedId) {
                const k = allKostList.find(k => k.id === selectedId);
                if (k) { const wrap = document.getElementById(wrapId); wrap.querySelector('.csel-val').textContent = k.nama_kost; wrap.querySelector('.csel-val').classList.remove('csel-placeholder'); wrap.dataset.value = k.id; wrap.dataset.kostId = k.id; wrap.dataset.kostNama = k.nama_kost; }
            }
        }

        function renderStats() {
            document.getElementById('stat-total').textContent = allReviews.length;
            document.getElementById('stat-disetujui').textContent = allReviews.filter(r => r.status === 'Disetujui').length;
            document.getElementById('stat-menunggu').textContent = allReviews.filter(r => r.status === 'Menunggu').length;
            document.getElementById('stat-ditolak').textContent = allReviews.filter(r => r.status === 'Ditolak').length;
        }

        function setReviewFilter(val, el) {
            activeReviewFilter = val;
            document.querySelectorAll('#filter-review .filter-opt').forEach(o => o.classList.remove('active'));
            el.classList.add('active'); document.getElementById('filter-review').classList.remove('open'); applyReviewFilter();
        }
        function applyReviewFilter() { const f = activeReviewFilter === 'semua' ? allReviews : allReviews.filter(r => r.status === activeReviewFilter); renderReviews(f); }

        function renderStars(r) { let s = ''; for (let i = 1; i <= 5; i++)s += i <= r ? '★' : '☆'; return s; }
        function statusPill(s) { const m = { Disetujui: 'green', Menunggu: 'yellow', Ditolak: 'muted' }, ic = { Disetujui: '✅', Menunggu: '⏳', Ditolak: '🚫' }; return `<span class="pill ${m[s] || 'muted'}">${ic[s] || ''} ${s}</span>`; }

        function renderReviews(reviews) {
            const grid = document.getElementById('review-grid');
            if (!reviews.length) { grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:13px">Tidak ada ulasan ditemukan.</div>'; return; }
            grid.innerHTML = reviews.map(r => {
                const avatarHtml = r.user_photo ? `<img src="${r.user_photo}" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">` : r.user_initials;
                const d = JSON.stringify({ id: r.id, nama: r.user_name, kost_id: r.kost_id, kost: r.kost_name, rating: r.rating, teks: r.komentar, status: r.status }).replace(/'/g, "&#39;");
                return `<div class="review-card" data-id="${r.id}" data-status="${r.status}">
    <div class="rv-header"><div class="rv-user"><div class="rv-avatar" style="background:${r.user_color};overflow:hidden">${avatarHtml}</div><div><div class="rv-name">${r.user_name}</div><div class="rv-kost">${r.kost_name}</div></div></div><div class="rv-stars">${renderStars(r.rating)}</div></div>
    <div class="rv-text">"${r.komentar}"</div>
    <div class="rv-footer"><div class="rv-date">${r.created_at}</div>${statusPill(r.status)}</div>
    <div class="rv-actions"><button class="act-btn" title="Edit" onclick='openEditReview(${d})'>✏️</button><button class="act-btn" title="Hapus" onclick="openHapusReview('${r.id}','${(r.user_name || '').replace(/'/g, "\\'")}')">🗑️</button></div>
    </div>`;
            }).join('');
        }

        /* MODAL TAMBAH */
        function openAddReview() {
            document.querySelectorAll('input[name="nar"]').forEach(r => r.checked = false);
            document.getElementById('ar-komentar').value = '';
            document.getElementById('ar-error').style.display = 'none';
            const wrap = document.getElementById('csel-ar-kost');
            wrap.querySelector('.csel-val').textContent = 'Pilih kost...'; wrap.querySelector('.csel-val').classList.add('csel-placeholder');
            wrap.dataset.value = ''; wrap.dataset.kostId = ''; wrap.dataset.kostNama = '';
            fillKostDropdown('csel-ar-kost', 'csel-ar-kost-opts', null);
            const s = wrap.querySelector('.csel-search'); if (s) s.value = '';
            setCselVal('csel-ar-status', 'Menunggu'); openModal('modal-review-add');
        }

        async function submitAddReview() {
            const kostId = document.getElementById('csel-ar-kost').dataset.kostId || '';
            const komentar = document.getElementById('ar-komentar').value.trim();
            const status = getCselVal('csel-ar-status');
            const ratingEl = document.querySelector('input[name="nar"]:checked');
            const rating = ratingEl ? parseInt(ratingEl.value) : 0;
            const errorEl = document.getElementById('ar-error');
            if (!kostId) { showFormError(errorEl, 'Pilih kost terlebih dahulu.'); return; }
            if (!rating) { showFormError(errorEl, 'Pilih rating bintang.'); return; }
            if (!komentar) { showFormError(errorEl, 'Tulis ulasan terlebih dahulu.'); return; }
            setBtnLoading('btn-ar-save', 'btn-ar-label', true, 'Menyimpan...');
            try {
                const res = await fetch('/api/review', { method: 'POST', headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' }, body: JSON.stringify({ kost_id: kostId, rating, komentar, status }) });
                const data = await res.json();
                if (data.success || res.ok) { allReviews.unshift(data.data); renderStats(); applyReviewFilter(); closeModal('modal-review-add'); showToast('Ulasan berhasil ditambahkan', '✅'); }
                else { showFormError(errorEl, data.message || Object.values(data.errors ?? {}).flat().join(' ') || 'Gagal menyimpan.'); }
            } catch (err) { console.error(err); showFormError(errorEl, 'Terjadi kesalahan server.'); }
            finally { setBtnLoading('btn-ar-save', 'btn-ar-label', false, 'Simpan'); }
        }

        /* MODAL EDIT */
        function openEditReview(d) {
            document.getElementById('er-id').value = d.id;
            document.getElementById('er-nama').value = d.nama;
            document.getElementById('er-teks').value = d.teks;
            document.getElementById('er-error').style.display = 'none';
            setCselVal('csel-er-status', d.status);
            const rb = document.getElementById('er-r' + d.rating); if (rb) rb.checked = true;
            /* Isi dropdown kost dengan kost saat ini sebagai default terpilih */
            fillKostDropdown('csel-er-kost', 'csel-er-kost-opts', d.kost_id || null);
            const s = document.querySelector('#csel-er-kost .csel-search'); if (s) s.value = '';
            openModal('modal-review-edit');
        }

        async function submitEditReview() {
            const id = document.getElementById('er-id').value;
            const kostId = document.getElementById('csel-er-kost').dataset.kostId || '';
            const komentar = document.getElementById('er-teks').value.trim();
            const status = getCselVal('csel-er-status');
            const ratingEl = document.querySelector('input[name="er-r"]:checked');
            const rating = ratingEl ? parseInt(ratingEl.value) : 0;
            const errorEl = document.getElementById('er-error');
            if (!kostId) { showFormError(errorEl, 'Pilih kost terlebih dahulu.'); return; }
            if (!komentar) { showFormError(errorEl, 'Ulasan tidak boleh kosong.'); return; }
            if (!rating) { showFormError(errorEl, 'Pilih rating bintang.'); return; }
            setBtnLoading('btn-er-save', 'btn-er-label', true, 'Menyimpan...');
            try {
                const res = await fetch(`/api/review/${id}`, { method: 'PUT', headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' }, body: JSON.stringify({ kost_id: kostId, rating, komentar, status }) });
                const data = await res.json();
                if (data.success || res.ok) { const idx = allReviews.findIndex(r => String(r.id) === String(id)); if (idx !== -1) allReviews[idx] = data.data; renderStats(); applyReviewFilter(); closeModal('modal-review-edit'); showToast('Ulasan berhasil diperbarui', '✅'); }
                else { showFormError(errorEl, data.message || Object.values(data.errors ?? {}).flat().join(' ') || 'Gagal menyimpan.'); }
            } catch (err) { console.error(err); showFormError(errorEl, 'Terjadi kesalahan server.'); }
            finally { setBtnLoading('btn-er-save', 'btn-er-label', false, 'Simpan'); }
        }

        /* HAPUS */
        function openHapusReview(id, nama) { hapusReviewId = id; document.getElementById('review-hapus-msg').textContent = `Ulasan dari "${nama}" akan dihapus permanen.`; document.getElementById('btn-review-hapus-confirm').onclick = confirmHapusReview; openModal('modal-review-hapus'); }
        async function confirmHapusReview() {
            if (!hapusReviewId) return; const btn = document.getElementById('btn-review-hapus-confirm'); btn.disabled = true; btn.textContent = 'Menghapus...';
            try {
                const res = await fetch(`/api/review/${hapusReviewId}`, { method: 'DELETE', headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' } });
                const data = await res.json();
                if (data.success || res.ok) { allReviews = allReviews.filter(r => String(r.id) !== String(hapusReviewId)); renderStats(); applyReviewFilter(); closeModal('modal-review-hapus'); showToast('Ulasan berhasil dihapus', '🗑️'); }
                else showToast(data.message || 'Gagal menghapus.', '❌');
            } catch (err) { console.error(err); showToast('Terjadi kesalahan server.', '❌'); }
            finally { btn.disabled = false; btn.textContent = 'Ya, Hapus'; hapusReviewId = null; }
        }

        /* UTILITY */
        function showFormError(el, msg) { el.textContent = msg; el.style.display = 'block'; }
        function setBtnLoading(bId, lId, load, text) { document.getElementById(bId).disabled = load; document.getElementById(lId).textContent = text; }
        if (typeof getCselVal === 'undefined') { window.getCselVal = id => { const w = document.getElementById(id); return w ? (w.dataset.value || w.querySelector('.csel-val')?.textContent.trim() || '') : ''; }; }
        if (typeof setCselVal === 'undefined') { window.setCselVal = (id, val) => { const w = document.getElementById(id); if (!w) return; const opt = [...w.querySelectorAll('.csel-opt')].find(o => o.dataset.val === val || o.textContent.trim().includes(val)); if (opt) { w.querySelector('.csel-val').textContent = opt.textContent.trim(); w.querySelector('.csel-val').classList.remove('csel-placeholder'); w.dataset.value = opt.dataset.val; w.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active')); opt.classList.add('active'); } }; }
        if (typeof searchCsel === 'undefined') { window.searchCsel = (id, q) => { const wrap = document.getElementById(id); if (!wrap) return; const query = q.toLowerCase(); let visible = 0; wrap.querySelectorAll('.csel-opt').forEach(o => { const match = o.textContent.toLowerCase().includes(query); o.style.display = match ? '' : 'none'; if (match) visible++; }); const empty = wrap.querySelector('.csel-empty'); if (empty) empty.style.display = visible === 0 ? '' : 'none'; }; }
    </script>
@endpush
