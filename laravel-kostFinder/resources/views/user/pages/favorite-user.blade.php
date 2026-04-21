@extends('user.layouts.auth-user')
@section('title', 'Favorit Saya')
@section('page_title', 'Favorit Saya')

@section('content')
    <div class="page-header">
        <h2>Kost <em>Favorit</em> ❤️</h2>
        <p>Kost yang sudah kamu simpan sebagai favorit.</p>
    </div>

    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;flex-wrap:wrap;gap:10px">
        <span id="fav-count" style="font-size:13px;color:var(--muted)"></span>
        <a href="{{ route('user.kost') }}" class="btn-sm primary"
            style="text-decoration:none;font-size:13px;padding:9px 18px;display:inline-flex;align-items:center;gap:6px">+ Cari Kost Baru</a>
    </div>

    <div class="fav-grid-user" id="fav-grid">
        <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted)">⏳ Memuat favorit...</div>
    </div>

    {{-- MODAL HAPUS --}}
    <div id="modal-fav-hapus" class="modal-overlay" onclick="closeModalOutside(event,this)">
        <div class="modal-box" style="max-width:360px;text-align:center">
            <div class="modal-body" style="padding-top:28px">
                <div
                    style="width:56px;height:56px;border-radius:16px;background:rgba(232,67,13,.1);display:flex;align-items:center;justify-content:center;font-size:28px;margin:0 auto 14px">
                    💔</div>
                <h3 style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800;margin-bottom:8px">Hapus dari
                    Favorit?</h3>
                <p style="font-size:13px;color:var(--muted);line-height:1.6" id="fav-hapus-msg">Kost ini akan dihapus dari
                    favorit.</p>
            </div>
            <div class="modal-footer" style="justify-content:center;gap:10px">
                <button class="btn-sm" onclick="closeModal('modal-fav-hapus')">Batal</button>
                <button class="btn-sm" id="btn-hapus-confirm"
                    style="background:#E53E3E;color:white;border-color:#E53E3E">Ya, Hapus</button>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        let allFavs = [], hapusId = null;

        document.addEventListener('DOMContentLoaded', () => { loadFavorits(); });

        async function loadFavorits() {
            try {
                const res = await fetch('/api/user/favorite');
                const result = await res.json();
                if (!result.success) throw new Error('Gagal');
                allFavs = result.data;
                document.getElementById('fav-count').textContent = `${allFavs.length} kost difavoritkan`;
                renderFavs(allFavs);
            } catch (err) {
                document.getElementById('fav-grid').innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:48px;color:#E53E3E">Gagal memuat favorit.</div>';
            }
        }

        function renderFavs(favs) {
            const grid = document.getElementById('fav-grid');
            if (!favs.length) {
                grid.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:64px 20px">
                <div style="font-size:48px;margin-bottom:12px">💔</div>
                <div style="font-family:'Syne',sans-serif;font-size:16px;font-weight:800;margin-bottom:8px">Belum ada favorit</div>
                <p style="color:var(--muted);font-size:13px;margin-bottom:16px">Mulai cari kost dan simpan yang kamu suka!</p>
                <a href="{{ route('user.kost') }}" class="btn-sm primary">Cari Kost Sekarang</a>
            </div>`;
                return;
            }
            grid.innerHTML = favs.map(f => {
                const namaEsc = (f.kost_nama || '').replace(/'/g, "\\'");
                return `
            <div class="fav-card-user" data-id="${f.id}">
                <div class="fcu-img">
                    ${f.kost_foto ? `<img src="${f.kost_foto}" style="width:100%;height:100%;object-fit:cover;position:absolute;inset:0">` : '<span>🏘️</span>'}
                    <button onclick="openHapus('${f.id}','${namaEsc}')"
                        style="position:absolute;top:8px;right:8px;width:28px;height:28px;border-radius:50%;background:rgba(255,255,255,.9);border:none;cursor:pointer;font-size:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(0,0,0,.15)"
                        title="Hapus dari favorit">💔</button>
                </div>
                <div class="fcu-body">
                    <div class="fcu-name">${f.kost_nama}</div>
                    <div class="fcu-loc">📍 ${f.kost_alamat}</div>
                    <div class="fcu-price">${formatRupiah(f.kost_harga)}<span style="font-size:11px;font-weight:400;color:var(--muted)">/bln</span></div>
                </div>
                <div class="fcu-footer">
                    <span class="pill ${f.pill_class}">${f.kost_status}</span>
                    <span style="font-size:11px;color:var(--muted)">❤️ ${f.fav_count > 0 ? f.fav_count.toLocaleString('id-ID') : 'baru'}</span>
                </div>
            </div>`;
            }).join('');
        }

        function openHapus(id, nama) {
            hapusId = id;
            document.getElementById('fav-hapus-msg').textContent = `"${nama}" akan dihapus dari favorit.`;
            document.getElementById('btn-hapus-confirm').onclick = confirmHapus;
            openModal('modal-fav-hapus');
        }

        async function confirmHapus() {
            if (!hapusId) return;
            const btn = document.getElementById('btn-hapus-confirm');
            btn.disabled = true; btn.textContent = 'Menghapus...';
            try {
                const res = await fetch(`/api/user/favorite/${hapusId}`, {
                    method: 'DELETE',
                    headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                });
                const data = await res.json();
                if (data.success || res.ok) {
                    allFavs = allFavs.filter(f => String(f.id) !== String(hapusId));
                    document.getElementById('fav-count').textContent = `${allFavs.length} kost difavoritkan`;
                    renderFavs(allFavs); closeModal('modal-fav-hapus'); showToast('Dihapus dari favorit.', '💔');
                } else { showToast(data.message || 'Gagal.', '❌'); }
            } catch (err) { showToast('Kesalahan server.', '❌'); }
            finally { btn.disabled = false; btn.textContent = 'Ya, Hapus'; hapusId = null; }
        }
    </script>
@endpush
