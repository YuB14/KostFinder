@extends('user.layouts.auth-user')
@section('title', 'Ulasan Saya')
@section('page_title', 'Ulasan Saya')

@section('content')
    <div class="page-header">
        <h2>Ulasan <em>Saya</em> ⭐</h2>
        <p>Kelola ulasan kost yang sudah kamu tulis.</p>
    </div>

    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;flex-wrap:wrap;gap:10px">
        <div style="display:flex;align-items:center;gap:8px">
            <span id="rev-count" style="font-size:13px;color:var(--muted)"></span>
        </div>
        <button class="btn-sm primary" style="font-size:13px;padding:9px 18px" onclick="openAddReview()">+ Tulis Ulasan</button>
    </div>

    <div id="review-list" style="display:flex;flex-direction:column;gap:14px">
        <div style="text-align:center;padding:48px;color:var(--muted)">⏳ Memuat ulasan...</div>
    </div>

    {{-- MODAL TAMBAH --}}
    <div class="modal-overlay" id="modal-rev-add" onclick="closeModalOutside(event,this)">
        <div class="modal-box">
            <div class="modal-header">
                <h3>⭐ Tulis Ulasan</h3><button class="modal-close" onclick="closeModal('modal-rev-add')">✕</button>
            </div>
            <div class="modal-body">
                <div class="mform-group">
                    <label>Nama Pengguna</label>
                    <input type="text" value="{{ Auth::user()->name }}" readonly
                        style="width:100%;background:var(--bg2);border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;font-family:'DM Sans',sans-serif;font-size:13px;color:var(--muted);outline:none;cursor:not-allowed;" />
                </div>
                <div class="mform-group">
                    <label>Kost</label>
                    <div class="csel-wrap" id="csel-add-kost">
                        <div class="csel-trigger" onclick="toggleCsel('csel-add-kost')"><span
                                class="csel-val csel-placeholder">Pilih kost...</span></div>
                        <div class="csel-dropdown">
                            <input class="csel-search" placeholder="Cari kost..."
                                oninput="searchCsel('csel-add-kost',this.value)" />
                            <div id="csel-add-kost-opts">
                                <div class="csel-empty" style="display:none">Tidak ada hasil</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="mform-group">
                    <label>Rating</label>
                    <div class="star-input">
                        <input type="radio" name="nar" id="nar5" value="5" /><label for="nar5">★</label>
                        <input type="radio" name="nar" id="nar4" value="4" /><label for="nar4">★</label>
                        <input type="radio" name="nar" id="nar3" value="3" /><label for="nar3">★</label>
                        <input type="radio" name="nar" id="nar2" value="2" /><label for="nar2">★</label>
                        <input type="radio" name="nar" id="nar1" value="1" /><label for="nar1">★</label>
                    </div>
                </div>
                <div class="mform-group">
                    <label>Ulasan</label>
                    <textarea id="add-komentar" rows="4" placeholder="Ceritakan pengalamanmu..."
                        style="width:100%;background:var(--bg);border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;font-family:'DM Sans',sans-serif;font-size:13px;color:var(--text);outline:none;resize:vertical;transition:border-color .2s"
                        onfocus="this.style.borderColor='var(--coral)'" onblur="this.style.borderColor=''"></textarea>
                </div>
                <div id="add-error" class="form-error-msg" style="display:none"></div>
            </div>
            <div class="modal-footer">
                <button class="btn-sm" onclick="closeModal('modal-rev-add')">Batal</button>
                <button class="btn-sm primary" id="btn-add-save" onclick="submitAddReview()"><span
                        id="btn-add-label">Simpan</span></button>
            </div>
        </div>
    </div>

    {{-- MODAL EDIT --}}
    <div class="modal-overlay" id="modal-rev-edit" onclick="closeModalOutside(event,this)">
        <div class="modal-box">
            <div class="modal-header">
                <h3>✏️ Edit Ulasan</h3><button class="modal-close" onclick="closeModal('modal-rev-edit')">✕</button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="edit-id" />
                <div class="mform-group">
                    <label>Kost</label>
                    <input type="text" id="edit-kost-name" readonly style="opacity:.6" />
                </div>
                <div class="mform-group">
                    <label>Rating</label>
                    <div class="star-input">
                        <input type="radio" name="er" id="er5" value="5" /><label for="er5">★</label>
                        <input type="radio" name="er" id="er4" value="4" /><label for="er4">★</label>
                        <input type="radio" name="er" id="er3" value="3" /><label for="er3">★</label>
                        <input type="radio" name="er" id="er2" value="2" /><label for="er2">★</label>
                        <input type="radio" name="er" id="er1" value="1" /><label for="er1">★</label>
                    </div>
                </div>
                <div class="mform-group">
                    <label>Ulasan</label>
                    <textarea id="edit-komentar" rows="4"
                        style="width:100%;background:var(--bg);border:1.5px solid var(--border);border-radius:10px;padding:10px 13px;font-family:'DM Sans',sans-serif;font-size:13px;color:var(--text);outline:none;resize:vertical;transition:border-color .2s"
                        onfocus="this.style.borderColor='var(--coral)'" onblur="this.style.borderColor=''"></textarea>
                </div>
                <div id="edit-error" class="form-error-msg" style="display:none"></div>
            </div>
            <div class="modal-footer">
                <button class="btn-sm" onclick="closeModal('modal-rev-edit')">Batal</button>
                <button class="btn-sm primary" id="btn-edit-save" onclick="submitEditReview()"><span
                        id="btn-edit-label">Simpan</span></button>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        let allReviews = [], allKosts = [];

        document.addEventListener('DOMContentLoaded', () => {
            loadReviews();
            loadKostDropdown();
        });

        async function loadReviews() {
            try {
                const res = await fetch('/api/user/review');
                const result = await res.json();
                if (!result.success) throw new Error('Gagal');
                allReviews = result.data;
                document.getElementById('rev-count').textContent = `${allReviews.length} ulasan ditulis`;
                renderReviews(allReviews);
            } catch (err) {
                document.getElementById('review-list').innerHTML = '<div style="text-align:center;padding:48px;color:#E53E3E">Gagal memuat ulasan.</div>';
            }
        }

        async function loadKostDropdown() {
            try {
                const res = await fetch('/api/user/kost');
                const result = await res.json();
                if (!result.success) return;
                allKosts = result.data;
                const optsEl = document.getElementById('csel-add-kost-opts');
                const emptyEl = optsEl.querySelector('.csel-empty');
                allKosts.forEach(k => {
                    const div = document.createElement('div');
                    div.className = 'csel-opt'; div.dataset.val = k.id;
                    div.textContent = '🏘️ ' + k.nama_kost;
                    div.onclick = () => {
                        const wrap = document.getElementById('csel-add-kost');
                        wrap.querySelector('.csel-val').textContent = k.nama_kost;
                        wrap.querySelector('.csel-val').classList.remove('csel-placeholder');
                        wrap.dataset.value = k.id; wrap.dataset.kostId = k.id;
                        optsEl.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
                        div.classList.add('active');
                        wrap.querySelector('.csel-dropdown').classList.remove('open');
                        wrap.querySelector('.csel-trigger').classList.remove('open');
                    };
                    if (emptyEl) optsEl.insertBefore(div, emptyEl);
                    else optsEl.appendChild(div);
                });
            } catch (err) { console.error(err); }
        }

        function statusPill(s) {
            const m = { Disetujui: 'green', Menunggu: 'yellow', Ditolak: 'muted' };
            const ic = { Disetujui: '✅', Menunggu: '⏳', Ditolak: '🚫' };
            return `<span class="pill ${m[s] || 'muted'}">${ic[s] || ''} ${s}</span>`;
        }

        function renderReviews(reviews) {
            const el = document.getElementById('review-list');
            if (!reviews.length) { el.innerHTML = '<div style="text-align:center;padding:48px;color:var(--muted)">Belum ada ulasan. Tulis ulasan pertamamu!</div>'; return; }
            el.innerHTML = reviews.map(r => {
                const d = JSON.stringify({ id: r.id, kost: r.kost_name, rating: r.rating, komentar: r.komentar, status: r.status }).replace(/'/g, "&#39;");
                return `
            <div class="review-card-user">
                <div class="rcu-header">
                    <div>
                        <div class="rcu-kost">${r.kost_name}</div>
                        <div class="rcu-rating">${renderStars(r.rating)} <span style="font-size:12px;color:var(--muted)">(${r.rating}/5)</span></div>
                    </div>
                    <div>${statusPill(r.status)}</div>
                </div>
                <div class="rcu-text">"${r.komentar}"</div>
                <div class="rcu-footer">
                    <div class="rcu-date">📅 ${r.created_at}</div>
                    <div class="rcu-actions">
                        <button class="act-btn" title="Edit" onclick='openEditReview(${d})'>✏️</button>
                        {{-- User TIDAK bisa hapus --}}
                    </div>
                </div>
            </div>`;
            }).join('');
        }

        function openAddReview() {
            document.querySelectorAll('input[name="nar"]').forEach(r => r.checked = false);
            document.getElementById('add-komentar').value = '';
            document.getElementById('add-error').style.display = 'none';
            const wrap = document.getElementById('csel-add-kost');
            wrap.querySelector('.csel-val').textContent = 'Pilih kost...';
            wrap.querySelector('.csel-val').classList.add('csel-placeholder');
            wrap.dataset.value = ''; wrap.dataset.kostId = '';
            wrap.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
            openModal('modal-rev-add');
        }

        async function submitAddReview() {
            const kostId = document.getElementById('csel-add-kost').dataset.kostId || '';
            const komentar = document.getElementById('add-komentar').value.trim();
            const ratingEl = document.querySelector('input[name="nar"]:checked');
            const rating = ratingEl ? parseInt(ratingEl.value) : 0;
            const errorEl = document.getElementById('add-error');
            if (!kostId) { errorEl.textContent = 'Pilih kost terlebih dahulu.'; errorEl.style.display = 'block'; return; }
            if (!rating) { errorEl.textContent = 'Pilih rating bintang.'; errorEl.style.display = 'block'; return; }
            if (!komentar) { errorEl.textContent = 'Tulis ulasan terlebih dahulu.'; errorEl.style.display = 'block'; return; }
            document.getElementById('btn-add-save').disabled = true;
            document.getElementById('btn-add-label').textContent = 'Menyimpan...';
            try {
                const res = await fetch('/api/user/review', {
                    method: 'POST',
                    headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                    body: JSON.stringify({ kost_id: kostId, rating, komentar }),
                });
                const data = await res.json();
                if (data.success || res.ok) { allReviews.unshift(data.data); document.getElementById('rev-count').textContent = `${allReviews.length} ulasan ditulis`; renderReviews(allReviews); closeModal('modal-rev-add'); showToast('Ulasan berhasil ditambahkan!', '✅'); }
                else { errorEl.textContent = data.message || 'Gagal menyimpan.'; errorEl.style.display = 'block'; }
            } catch (err) { errorEl.textContent = 'Kesalahan server.'; errorEl.style.display = 'block'; }
            finally { document.getElementById('btn-add-save').disabled = false; document.getElementById('btn-add-label').textContent = 'Simpan'; }
        }

        function openEditReview(d) {
            document.getElementById('edit-id').value = d.id;
            document.getElementById('edit-kost-name').value = d.kost;
            document.getElementById('edit-komentar').value = d.komentar;
            document.getElementById('edit-error').style.display = 'none';
            const rb = document.getElementById('er' + d.rating);
            if (rb) rb.checked = true;
            openModal('modal-rev-edit');
        }

        async function submitEditReview() {
            const id = document.getElementById('edit-id').value;
            const komentar = document.getElementById('edit-komentar').value.trim();
            const ratingEl = document.querySelector('input[name="er"]:checked');
            const rating = ratingEl ? parseInt(ratingEl.value) : 0;
            const errorEl = document.getElementById('edit-error');
            if (!komentar) { errorEl.textContent = 'Ulasan tidak boleh kosong.'; errorEl.style.display = 'block'; return; }
            if (!rating) { errorEl.textContent = 'Pilih rating bintang.'; errorEl.style.display = 'block'; return; }
            document.getElementById('btn-edit-save').disabled = true;
            document.getElementById('btn-edit-label').textContent = 'Menyimpan...';
            try {
                const res = await fetch(`/api/user/review/${id}`, {
                    method: 'PUT',
                    headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                    body: JSON.stringify({ rating, komentar }),
                });
                const data = await res.json();
                if (data.success || res.ok) {
                    const idx = allReviews.findIndex(r => String(r.id) === String(id));
                    if (idx !== -1) allReviews[idx] = data.data;
                    renderReviews(allReviews); closeModal('modal-rev-edit'); showToast('Ulasan berhasil diperbarui!', '✅');
                } else { errorEl.textContent = data.message || 'Gagal.'; errorEl.style.display = 'block'; }
            } catch (err) { errorEl.textContent = 'Kesalahan server.'; errorEl.style.display = 'block'; }
            finally { document.getElementById('btn-edit-save').disabled = false; document.getElementById('btn-edit-label').textContent = 'Simpan'; }
        }
    </script>
@endpush
