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
                    <div class="filter-opt" onclick="setKostFilter('Ekonomis',this)">💚 Ekonomis</div>
                    <div class="filter-opt" onclick="setKostFilter('Standar',this)">🔵 Standar</div>
                    <div class="filter-opt" onclick="setKostFilter('Premium',this)">⭐ Premium</div>
                </div>
            </div>
            <button class="btn-sm primary" onclick="openAddKost()">+ Tambah Kost</button>
        </div>
    </div>

    <div id="kost-view-grid" class="kost-grid-dash">
        <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:14px">⏳ Memuat data kost...</div>
    </div>
    <div id="kost-view-table" style="display:none" class="table-wrap">
        <table><thead><tr><th>Nama Kost</th><th>Alamat</th><th>Kelas</th><th>Harga</th><th>Rating</th><th>Status</th><th>Aksi</th></tr></thead>
        <tbody id="kost-table-body"><tr><td colspan="7" style="text-align:center;padding:32px;color:var(--muted)">⏳ Memuat data...</td></tr></tbody></table>
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
                <div class="mform-group"><label>Kelas</label>
                    <div class="csel-wrap" id="csel-kadd-tier">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kadd-tier')"><span class="csel-val">Ekonomis</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="Ekonomis" onclick="pickCsel('csel-kadd-tier',this)">💚 Ekonomis</div>
                            <div class="csel-opt" data-val="Standar" onclick="pickCsel('csel-kadd-tier',this)">🔵 Standar</div>
                            <div class="csel-opt" data-val="Premium" onclick="pickCsel('csel-kadd-tier',this)">⭐ Premium</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Jenis Kost</label>
                    <div class="csel-wrap" id="csel-kadd-jenis">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kadd-jenis')"><span class="csel-val">Bebas</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt" data-val="Pria" onclick="pickCsel('csel-kadd-jenis',this)">👨 Pria</div>
                            <div class="csel-opt" data-val="Wanita" onclick="pickCsel('csel-kadd-jenis',this)">👩 Wanita</div>
                            <div class="csel-opt active" data-val="Bebas" onclick="pickCsel('csel-kadd-jenis',this)">👥 Bebas</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>Harga / Bulan</label>
                    <div style="position:relative">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-size:12px;color:var(--muted);font-weight:600;pointer-events:none">Rp</span>
                        <input type="text" id="kadd-harga" placeholder="500.000" inputmode="numeric"
                            style="padding-left:34px"
                            oninput="formatHargaInput(this)" />
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Status</label>
                    <div class="csel-wrap" id="csel-kadd-status">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kadd-status')"><span class="csel-val">Aktif</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="Aktif" onclick="pickCsel('csel-kadd-status',this)">✅ Aktif</div>
                            <div class="csel-opt" data-val="Review" onclick="pickCsel('csel-kadd-status',this)">⏳ Review</div>
                            <div class="csel-opt" data-val="Nonaktif" onclick="pickCsel('csel-kadd-status',this)">🚫 Nonaktif</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>No. Telepon Pemilik</label><input type="tel" id="kadd-telepon" placeholder="08xxxxxxxxxx"/></div>
            </div>
            <div class="mform-group"><label>Fasilitas <span style="font-weight:400;color:var(--muted)">(pisahkan dengan koma)</span></label><input type="text" id="kadd-fasilitas" placeholder="WiFi, AC, Parkir..."/></div>
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
                <div class="mform-group"><label>Kelas</label>
                    <div class="csel-wrap" id="csel-kedit-tier">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kedit-tier')"><span class="csel-val">Ekonomis</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="Ekonomis" onclick="pickCsel('csel-kedit-tier',this)">💚 Ekonomis</div>
                            <div class="csel-opt" data-val="Standar" onclick="pickCsel('csel-kedit-tier',this)">🔵 Standar</div>
                            <div class="csel-opt" data-val="Premium" onclick="pickCsel('csel-kedit-tier',this)">⭐ Premium</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Jenis Kost</label>
                    <div class="csel-wrap" id="csel-kedit-jenis">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kedit-jenis')"><span class="csel-val">Bebas</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt" data-val="Pria" onclick="pickCsel('csel-kedit-jenis',this)">👨 Pria</div>
                            <div class="csel-opt" data-val="Wanita" onclick="pickCsel('csel-kedit-jenis',this)">👩 Wanita</div>
                            <div class="csel-opt active" data-val="Bebas" onclick="pickCsel('csel-kedit-jenis',this)">👥 Bebas</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>Harga / Bulan</label>
                    <div style="position:relative">
                        <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-size:12px;color:var(--muted);font-weight:600;pointer-events:none">Rp</span>
                        <input type="text" id="kedit-harga" placeholder="500.000" inputmode="numeric"
                            style="padding-left:34px"
                            oninput="formatHargaInput(this)" />
                    </div>
                </div>
            </div>
            <div class="mform-row">
                <div class="mform-group"><label>Status</label>
                    <div class="csel-wrap" id="csel-kedit-status">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kedit-status')"><span class="csel-val">Aktif</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="Aktif" onclick="pickCsel('csel-kedit-status',this)">✅ Aktif</div>
                            <div class="csel-opt" data-val="Review" onclick="pickCsel('csel-kedit-status',this)">⏳ Review</div>
                            <div class="csel-opt" data-val="Nonaktif" onclick="pickCsel('csel-kedit-status',this)">🚫 Nonaktif</div>
                        </div>
                    </div>
                </div>
                <div class="mform-group"><label>No. Telepon Pemilik</label><input type="tel" id="kedit-telepon" placeholder="08xxxxxxxxxx"/></div>
            </div>
            <div class="mform-group"><label>Fasilitas <span style="font-weight:400;color:var(--muted)">(pisahkan dengan koma)</span></label><input type="text" id="kedit-fasilitas"/></div>
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
            <div class="detail-row"><span class="detail-label">Harga</span><span class="detail-val" id="vk-harga" style="color:var(--coral);font-size:15px;font-family:'Syne',sans-serif"></span></div>
            <div class="detail-row"><span class="detail-label">Status</span><span class="detail-val" id="vk-status"></span></div>
            <div class="detail-row"><span class="detail-label">Rating</span><span class="detail-val" id="vk-rating"></span></div>
            <div class="detail-row"><span class="detail-label">Ulasan</span><span class="detail-val" id="vk-ulasan"></span></div>
            <div class="detail-row"><span class="detail-label">Fasilitas</span><span class="detail-val" id="vk-fasilitas"></span></div>
            <div class="detail-row"><span class="detail-label">No. Telepon</span><span class="detail-val" id="vk-telepon"></span></div>
        </div>
        <div class="modal-footer"><button class="btn-sm primary" onclick="closeModal('modal-kost-view')">Tutup</button></div>
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
</style>
@endsection

@push('scripts')
<script>
let allKosts=[],activeKostFilter='semua',kostSearchQuery='',addKostPhoto=null,editKostPhoto=null,hapusKostId=null;

document.addEventListener('DOMContentLoaded',()=>{
    loadKosts();
    document.getElementById('search-kost').addEventListener('input',e=>{kostSearchQuery=e.target.value;applyKostFilter();});
});

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
        console.error('loadKosts:',err);
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
    const filtered=allKosts.filter(k=>{
        const matchKelas=activeKostFilter==='semua'||(k.kelas??'')===activeKostFilter;
        const matchSearch=!q||(k.nama_kost??'').toLowerCase().includes(q)||(k.alamat_kost??'').toLowerCase().includes(q)||(k.kelas??'').toLowerCase().includes(q)||(k.status??'').toLowerCase().includes(q)||(k.fasilitas??'').toLowerCase().includes(q)||formatRupiah(k.harga_kost).toLowerCase().includes(q)||String(k.avg_rating??'').includes(q)||String(k.reviews_count??'').includes(q);
        return matchKelas&&matchSearch;
    });
    renderGrid(filtered);
    renderTable(filtered);
}

function formatRupiah(n){return 'Rp '+Number(n??0).toLocaleString('id-ID');}
function renderStars(r){const v=parseFloat(r)||0,f=Math.floor(v),h=(v-f)>=0.5;let s='';for(let i=0;i<5;i++)s+=i<f?'★':(i===f&&h?'½':'☆');return s;}
function kelasClass(k){const t=(k||'').toLowerCase();return t==='ekonomis'?'coral':t==='standar'?'teal':t==='premium'?'yellow':'blue';}
function statusClass(s){const v=(s||'').toLowerCase();return v==='aktif'?'green':v==='review'?'blue':v==='nonaktif'?'muted':'green';}

/* packKost — semua field dari formatKost() controller sudah ada */
function packKost(k){
    return JSON.stringify({
        id:k.id??'',
        nama_kost:k.nama_kost??'',
        foto_kost:k.foto_kost??'',
        alamat_kost:k.alamat_kost??'',
        kelas:k.kelas??'',
        status:k.status??'',
        fasilitas:k.fasilitas??'',
        harga_kost:k.harga_kost??0,
        nomor_telepon:k.nomor_telepon??'',
        rating:parseFloat(k.avg_rating??0).toFixed(1),
        ulasan:parseInt(k.reviews_count??0),
    }).replace(/'/g,"&#39;");
}

function renderGrid(kosts){
    const grid=document.getElementById('kost-view-grid');
    if(!kosts.length){grid.innerHTML='<div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:13px">Tidak ada kost ditemukan.</div>';return;}
    grid.innerHTML=kosts.map(k=>{
        const rating=parseFloat(k.avg_rating??0).toFixed(1),ulasan=parseInt(k.reviews_count??0);
        const stars=renderStars(rating),kelasCls=kelasClass(k.kelas);
        const fotoHtml=k.foto_kost?`<img src="${k.foto_kost}" style="width:100%;height:100%;object-fit:cover;"/>`:'<span style="font-size:48px">🏘️</span>';
        const tags=(k.fasilitas??'').split(',').map(f=>f.trim()).filter(Boolean).slice(0,3).map(f=>`<span class="kc-tag">${f}</span>`).join('');
        const d=packKost(k),namaEsc=(k.nama_kost??'').replace(/'/g,"\\'");
        return `<div class="kost-card-dash" data-kelas="${k.kelas}" data-id="${k.id}">
<div class="kc-img" style="padding:0;overflow:hidden;display:flex;align-items:center;justify-content:center;background:var(--bg2)">${fotoHtml}<span class="kc-badge ${kelasCls}" style="position:absolute;top:10px;left:10px">${k.kelas}</span></div>
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
    if(!kosts.length){tbody.innerHTML='<tr><td colspan="7" style="text-align:center;padding:32px;color:var(--muted)">Tidak ada kost ditemukan.</td></tr>';return;}
    tbody.innerHTML=kosts.map(k=>{
        const rating=parseFloat(k.avg_rating??0).toFixed(1),ulasan=parseInt(k.reviews_count??0);
        const stars=renderStars(rating),kelasCls=kelasClass(k.kelas),stsCls=statusClass(k.status);
        const d=packKost(k),namaEsc=(k.nama_kost??'').replace(/'/g,"\\'");
        return `<tr data-kelas="${k.kelas}" data-id="${k.id}">
<td><b>${k.nama_kost}</b></td><td>${k.alamat_kost}</td>
<td><span class="pill ${kelasCls}">${k.kelas}</span></td>
<td>${formatRupiah(k.harga_kost)}</td>
<td><div class="kc-rating-wrap"><span class="kc-stars-filled" style="font-size:11px">${stars}</span><span class="kc-rating-num">${rating}</span><span class="kc-review-count">(${ulasan})</span></div></td>
<td><span class="pill ${stsCls}">${k.status}</span></td>
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

/* VIEW — id HTML: vk-nama, vk-lokasi, vk-harga, vk-telepon, vk-tier-badge */
function openViewKost(d){
    document.getElementById('vk-foto-wrap').innerHTML=d.foto_kost?`<img src="${d.foto_kost}" style="width:100%;height:100%;object-fit:cover;"/>`:'<span style="font-size:56px">🏘️</span>';
    const kelasMap={Ekonomis:'tier-badge-ekonomis',Standar:'tier-badge-standar',Premium:'tier-badge-premium'};
    const badge=document.getElementById('vk-tier-badge');
    if(badge){badge.textContent=d.kelas;badge.className=kelasMap[d.kelas]||'tier-badge-standar';}
    document.getElementById('vk-nama').textContent=d.nama_kost;
    document.getElementById('vk-lokasi').textContent='📍 '+d.alamat_kost;
    document.getElementById('vk-harga').textContent=formatRupiah(d.harga_kost)+'/bulan';
    document.getElementById('vk-status').textContent=d.status;
    document.getElementById('vk-rating').innerHTML=`<span style="color:var(--yellow)">${renderStars(d.rating)}</span> ${d.rating}`;
    document.getElementById('vk-ulasan').textContent=d.ulasan+' ulasan';
    document.getElementById('vk-fasilitas').textContent=d.fasilitas||'-';
    document.getElementById('vk-telepon').textContent=d.nomor_telepon||'-';
    openModal('modal-kost-view');
}

/* TAMBAH — id HTML: kadd-nama, kadd-lokasi, kadd-harga, kadd-telepon, kadd-fasilitas */
function openAddKost(){
    ['kadd-nama','kadd-lokasi','kadd-harga','kadd-telepon','kadd-fasilitas'].forEach(id=>document.getElementById(id).value='');
    document.getElementById('kadd-error').style.display='none';
    removeKostPhoto('kadd',{stopPropagation:()=>{}});
    setCselVal('csel-kadd-tier','Ekonomis');setCselVal('csel-kadd-status','Aktif');
    openModal('modal-kost-add');
}

async function submitAddKost(){
    const namaKost=document.getElementById('kadd-nama').value.trim();
    const alamatKost=document.getElementById('kadd-lokasi').value.trim();
    const hargaKost=getRawHarga('kadd-harga');
    const nomorTelepon=document.getElementById('kadd-telepon').value.trim();
    const fasilitas=document.getElementById('kadd-fasilitas').value.trim();
    const kelas=getCselVal('csel-kadd-tier'),status=getCselVal('csel-kadd-status');
    const errorEl=document.getElementById('kadd-error');
    if(!namaKost||!alamatKost||!hargaKost){showFormError(errorEl,'Nama kost, alamat, dan harga wajib diisi.');return;}
    setBtnLoading('btn-kadd-save','btn-kadd-label',true,'Menyimpan...');
    try{
        const body=new FormData();
        body.append('nama_kost',namaKost);body.append('alamat_kost',alamatKost);
        body.append('harga_kost',hargaKost);body.append('kelas',kelas);body.append('status',status);
        body.append('nomor_telepon',nomorTelepon);body.append('fasilitas',fasilitas);
        if(addKostPhoto)body.append('foto_kost',addKostPhoto);
        const res=await fetch('/api/kost',{method:'POST',headers:{'Accept':'application/json','X-CSRF-TOKEN':'{{ csrf_token() }}'},body});
        const data=await res.json();
        if(data.success||res.ok){
            /* data.data sudah diformat formatKost() — konsisten dengan loadKosts() */
            allKosts.unshift(data.data??{id:String(Date.now()),nama_kost:namaKost,foto_kost:addKostPhoto?URL.createObjectURL(addKostPhoto):null,alamat_kost:alamatKost,kelas,status,fasilitas,harga_kost:parseFloat(hargaKost),nomor_telepon:nomorTelepon,avg_rating:0,reviews_count:0});
            applyKostFilter();renderStats();closeModal('modal-kost-add');showToast('Kost berhasil ditambahkan','✅');
        }else{showFormError(errorEl,data.message||Object.values(data.errors??{}).flat().join(' ')||'Gagal menyimpan.');}
    }catch(err){console.error(err);showFormError(errorEl,'Terjadi kesalahan server.');}
    finally{setBtnLoading('btn-kadd-save','btn-kadd-label',false,'Simpan');}
}

/* EDIT — id HTML: kedit-nama, kedit-lokasi, kedit-harga, kedit-telepon, kedit-fasilitas */
function openEditKost(d){
    document.getElementById('kedit-id').value=d.id;
    document.getElementById('kedit-nama').value=d.nama_kost;
    document.getElementById('kedit-lokasi').value=d.alamat_kost;
    // tampilkan harga sebagai teks berformat
    document.getElementById('kedit-harga').value=d.harga_kost?Number(d.harga_kost).toLocaleString('id-ID'):'';
    document.getElementById('kedit-telepon').value=d.nomor_telepon||'';
    document.getElementById('kedit-fasilitas').value=d.fasilitas||'';
    document.getElementById('kedit-error').style.display='none';
    setCselVal('csel-kedit-tier',d.kelas);setCselVal('csel-kedit-status',d.status);
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
    const fasilitas=document.getElementById('kedit-fasilitas').value.trim();
    const kelas=getCselVal('csel-kedit-tier'),status=getCselVal('csel-kedit-status');
    const errorEl=document.getElementById('kedit-error');
    if(!namaKost||!alamatKost||!hargaKost){showFormError(errorEl,'Nama kost, alamat, dan harga wajib diisi.');return;}
    setBtnLoading('btn-kedit-save','btn-kedit-label',true,'Menyimpan...');
    try{
        const body=new FormData();
        body.append('_method','PUT');body.append('nama_kost',namaKost);body.append('alamat_kost',alamatKost);
        body.append('harga_kost',hargaKost);body.append('kelas',kelas);body.append('status',status);
        body.append('nomor_telepon',nomorTelepon);body.append('fasilitas',fasilitas);
        if(editKostPhoto)body.append('foto_kost',editKostPhoto);
        const res=await fetch(`/api/kost/${id}`,{method:'POST',headers:{'Accept':'application/json','X-CSRF-TOKEN':'{{ csrf_token() }}'},body});
        const data=await res.json();
        if(data.success||res.ok){
            const idx=allKosts.findIndex(k=>String(k.id)===String(id));
            /* data.data dari formatKost() — field sama persis dengan loadKosts() */
            if(idx!==-1)allKosts[idx]=data.data??{...allKosts[idx],nama_kost:namaKost,alamat_kost:alamatKost,harga_kost:parseFloat(hargaKost),kelas,status,nomor_telepon:nomorTelepon,fasilitas,foto_kost:editKostPhoto?URL.createObjectURL(editKostPhoto):allKosts[idx].foto_kost};
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

if(typeof getCselVal==='undefined'){window.getCselVal=id=>{const w=document.getElementById(id);return w?(w.dataset.value||w.querySelector('.csel-val')?.textContent.trim()||''):'';};}
if(typeof setCselVal==='undefined'){window.setCselVal=(id,val)=>{const w=document.getElementById(id);if(!w)return;const opt=[...w.querySelectorAll('.csel-opt')].find(o=>o.dataset.val===val||o.textContent.trim().includes(val));if(opt){w.querySelector('.csel-val').textContent=opt.textContent.trim();w.dataset.value=opt.dataset.val;w.querySelectorAll('.csel-opt').forEach(o=>o.classList.remove('active'));opt.classList.add('active');}};}
</script>
@endpush
