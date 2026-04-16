@extends('admin.layouts.admin')

@section('title', 'Pengguna')
@section('page_title', 'Pengguna')

@section('content')
<div class="page active" id="page-user">

    {{-- ─── HEADER ─── --}}
    <div class="page-header">
        <h2>Manajemen <em>Pengguna</em></h2>
        <p>Kelola semua pengguna yang terdaftar di KostFinder.</p>
    </div>

    {{-- ─── STATISTIK ─── --}}
    <div class="stats-grid" style="grid-template-columns:repeat(3,1fr)">
        <div class="stat-card teal">
            <div class="stat-icon-wrap teal">👥</div>
            <div class="stat-value" id="stat-total">—</div>
            <div class="stat-label">Total Pengguna</div>
            <div class="stat-change" id="change-total">↔ 0%</div>
        </div>
        <div class="stat-card coral">
            <div class="stat-icon-wrap coral">🟢</div>
            <div class="stat-value" id="stat-active">—</div>
            <div class="stat-label">Aktif Hari Ini</div>
            <div class="stat-change" id="change-active">↔ 0%</div>
        </div>
        <div class="stat-card yellow">
            <div class="stat-icon-wrap yellow">🆕</div>
            <div class="stat-value" id="stat-monthly">—</div>
            <div class="stat-label">Daftar Bulan Ini</div>
            <div class="stat-change" id="change-monthly">↔ 0%</div>
        </div>
    </div>

    {{-- ─── TABEL ─── --}}
    <div class="table-wrap">
        <div class="table-toolbar">
            <h3>Daftar Pengguna</h3>
            <div class="table-toolbar-actions">
                <div class="search-input-sm">
                    <span>🔍</span>
                    <input type="text" id="search-user" placeholder="Cari pengguna..."/>
                </div>
                <div class="filter-wrap">
                    <button class="btn-sm" onclick="toggleFilter('filter-user')">Filter ▾</button>
                    <div class="filter-dropdown" id="filter-user">
                        <div class="filter-opt active" onclick="setUserFilter('semua',this)">👥 Semua</div>
                        <div class="filter-sep"></div>
                        <div class="filter-opt" onclick="setUserFilter('Aktif',this)">🟢 Aktif</div>
                        <div class="filter-opt" onclick="setUserFilter('Tidak Aktif',this)">🟡 Tidak Aktif</div>
                    </div>
                </div>
                <button class="btn-sm primary" onclick="openAddUser()">+ Tambah</button>
            </div>
        </div>
        <table id="user-table">
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
            <tbody id="user-table-body">
                <tr><td colspan="6" class="tbl-loading">⏳ Memuat data...</td></tr>
            </tbody>
        </table>
    </div>
</div>

{{-- ══════════════════════════════════════════
     MODAL: TAMBAH PENGGUNA
══════════════════════════════════════════ --}}
<div class="modal-overlay" id="modal-user-add" onclick="closeModalOutside(event,this)">
    <div class="modal-box">
        <div class="modal-header">
            <h3>➕ Tambah Pengguna</h3>
            <button class="modal-close" onclick="closeModal('modal-user-add')">✕</button>
        </div>
        <div class="modal-body">

            {{-- Foto Profil --}}
            <div class="mform-group">
                <label>Foto Profil</label>
                <div class="upload-row" id="upload-add-area">
                    <input type="file" accept="image/*" id="add-photo-input" onchange="previewPhoto('add')"/>
                    <div class="avatar-sm" id="add-avatar-preview">
                        <span id="add-avatar-placeholder">📷</span>
                        <img id="add-avatar-img" alt=""/>
                    </div>
                    <div style="flex:1;min-width:0">
                        <p class="ut-main" id="add-upload-title">Pilih foto profil</p>
                        <p class="ut-sub">PNG, JPG · maks. <span class="ut-link">2 MB</span></p>
                    </div>
                    <button class="remove-sm" id="add-remove-btn" onclick="removePhoto('add',event)" type="button">✕</button>
                </div>
            </div>

            <div class="mform-row">
                <div class="mform-group">
                    <label>Nama Lengkap</label>
                    <input type="text" id="add-name" placeholder="Nama lengkap..."/>
                </div>
                <div class="mform-group">
                    <label>Role</label>
                    <div class="csel-wrap" id="csel-add-role">
                        <div class="csel-trigger" onclick="toggleCsel('csel-add-role')">
                            <span class="csel-val">User</span>
                        </div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="user" onclick="pickCsel('csel-add-role',this)">👤 User</div>
                            <div class="csel-opt" data-val="admin" onclick="pickCsel('csel-add-role',this)">🛡️ Admin</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mform-group">
                <label>Email</label>
                <input type="email" id="add-email" placeholder="email@domain.com"/>
            </div>

            <div class="mform-row">
                <div class="mform-group">
                    <label>Password</label>
                    <div style="position:relative">
                        <input type="password" id="add-password" placeholder="Min. 8 karakter..." style="padding-right:40px"/>
                        <button type="button" class="pw-toggle" onclick="togglePwVis('add-password',this)">👁️</button>
                    </div>
                </div>
                <div class="mform-group">
                    <label>Konfirmasi Password</label>
                    <div style="position:relative">
                        <input type="password" id="add-password-confirm" placeholder="Ulangi password..." style="padding-right:40px"/>
                        <button type="button" class="pw-toggle" onclick="togglePwVis('add-password-confirm',this)">👁️</button>
                    </div>
                </div>
            </div>

            <div id="add-error" class="form-error-msg" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn-sm" onclick="closeModal('modal-user-add')">Batal</button>
            <button class="btn-sm primary" id="btn-add-save" onclick="submitAddUser()">
                <span id="btn-add-label">Simpan</span>
            </button>
        </div>
    </div>
</div>

{{-- ══════════════════════════════════════════
     MODAL: EDIT PENGGUNA
══════════════════════════════════════════ --}}
<div class="modal-overlay" id="modal-user-edit" onclick="closeModalOutside(event,this)">
    <div class="modal-box">
        <div class="modal-header">
            <h3>✏️ Edit Pengguna</h3>
            <button class="modal-close" onclick="closeModal('modal-user-edit')">✕</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="edit-user-id"/>

            {{-- Foto Profil --}}
            <div class="mform-group">
                <label>Foto Profil</label>
                <div class="upload-row" id="upload-edit-area">
                    <input type="file" accept="image/*" id="edit-photo-input" onchange="previewPhoto('edit')"/>
                    <div class="avatar-sm" id="edit-avatar-preview">
                        <span id="edit-avatar-placeholder">📷</span>
                        <img id="edit-avatar-img" alt=""/>
                    </div>
                    <div style="flex:1;min-width:0">
                        <p class="ut-main" id="edit-upload-title">Pilih foto profil</p>
                        <p class="ut-sub">PNG, JPG · maks. <span class="ut-link">2 MB</span></p>
                    </div>
                    <button class="remove-sm" id="edit-remove-btn" onclick="removePhoto('edit',event)" type="button">✕</button>
                </div>
            </div>

            <div class="mform-row">
                <div class="mform-group">
                    <label>Nama Lengkap</label>
                    <input type="text" id="edit-name"/>
                </div>
                <div class="mform-group">
                    <label>Role</label>
                    <div class="csel-wrap" id="csel-edit-role">
                        <div class="csel-trigger" onclick="toggleCsel('csel-edit-role')">
                            <span class="csel-val">User</span>
                        </div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="user" onclick="pickCsel('csel-edit-role',this)">👤 User</div>
                            <div class="csel-opt" data-val="admin" onclick="pickCsel('csel-edit-role',this)">🛡️ Admin</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mform-group">
                <label>Email</label>
                <input type="email" id="edit-email"/>
            </div>

            <div class="mform-row">
                <div class="mform-group">
                    <label>Password Baru <span style="font-weight:400;color:var(--muted)">(kosongkan jika tidak diubah)</span></label>
                    <div style="position:relative">
                        <input type="password" id="edit-password" placeholder="Password baru..." style="padding-right:40px"/>
                        <button type="button" class="pw-toggle" onclick="togglePwVis('edit-password',this)">👁️</button>
                    </div>
                </div>
                <div class="mform-group">
                    <label>Konfirmasi Password</label>
                    <div style="position:relative">
                        <input type="password" id="edit-password-confirm" placeholder="Ulangi password..." style="padding-right:40px"/>
                        <button type="button" class="pw-toggle" onclick="togglePwVis('edit-password-confirm',this)">👁️</button>
                    </div>
                </div>
            </div>

            <div id="edit-error" class="form-error-msg" style="display:none"></div>
        </div>
        <div class="modal-footer">
            <button class="btn-sm" onclick="closeModal('modal-user-edit')">Batal</button>
            <button class="btn-sm primary" id="btn-edit-save" onclick="submitEditUser()">
                <span id="btn-edit-label">Simpan</span>
            </button>
        </div>
    </div>
</div>

{{-- ══════════════════════════════════════════
     MODAL: VIEW PENGGUNA
══════════════════════════════════════════ --}}
<div class="modal-overlay" id="modal-user-view" onclick="closeModalOutside(event,this)">
    <div class="modal-box">
        <div class="modal-header">
            <h3>👤 Detail Pengguna</h3>
            <button class="modal-close" onclick="closeModal('modal-user-view')">✕</button>
        </div>
        <div class="modal-body">
            {{-- Avatar besar --}}
            <div style="display:flex;align-items:center;gap:16px;margin-bottom:20px;padding-bottom:18px;border-bottom:1px solid var(--border)">
                <div id="vu-avatar-wrap" style="width:64px;height:64px;border-radius:18px;overflow:hidden;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-size:22px;font-weight:800;color:white;">
                    {{-- diisi JS --}}
                </div>
                <div>
                    <div id="vu-name" style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800"></div>
                    <div id="vu-role" style="font-size:12px;color:var(--muted);margin-top:3px"></div>
                </div>
            </div>
            <div class="detail-row"><span class="detail-label">Email</span><span class="detail-val" id="vu-email"></span></div>
            <div class="detail-row"><span class="detail-label">Status</span><span class="detail-val" id="vu-status"></span></div>
            <div class="detail-row"><span class="detail-label">Bergabung</span><span class="detail-val" id="vu-joined"></span></div>
            <div class="detail-row"><span class="detail-label">Total Favorit</span><span class="detail-val" id="vu-fav"></span></div>
        </div>
        <div class="modal-footer">
            <button class="btn-sm primary" onclick="closeModal('modal-user-view')">Tutup</button>
        </div>
    </div>
</div>

{{-- ══════════════════════════════════════════
     MODAL: KONFIRMASI HAPUS
══════════════════════════════════════════ --}}
<div id="delete-modal" style="display:none;position:fixed;inset:0;z-index:9000;align-items:center;justify-content:center;">
    <div onclick="hideDeleteModal()" style="position:absolute;inset:0;background:rgba(0,0,0,.45);backdrop-filter:blur(3px);"></div>
    <div style="position:relative;background:var(--card);border:1px solid var(--border);border-radius:18px;padding:32px 28px;width:320px;box-shadow:var(--shadow-lg);text-align:center;">
        <div style="width:56px;height:56px;border-radius:16px;background:rgba(229,62,62,.1);display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 16px;">🗑️</div>
        <h3 style="font-family:'Syne',sans-serif;font-size:18px;font-weight:800;margin-bottom:8px;">Hapus Pengguna?</h3>
        <p style="font-size:13px;color:var(--muted);line-height:1.6;margin-bottom:24px;">
            Yakin ingin menghapus <b id="delete-user-name"></b>?<br>Data tidak bisa dikembalikan.
        </p>
        <div style="display:flex;gap:10px;">
            <button onclick="hideDeleteModal()" style="flex:1;padding:11px;border-radius:10px;border:1.5px solid var(--border);background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;font-size:14px;font-weight:600;cursor:pointer;">Batal</button>
            <button id="btn-confirm-delete" onclick="confirmDelete()" style="flex:1;padding:11px;border-radius:10px;border:none;background:#E53E3E;color:white;font-family:'DM Sans',sans-serif;font-size:14px;font-weight:600;cursor:pointer;box-shadow:0 2px 10px rgba(229,62,62,.3);">Hapus</button>
        </div>
    </div>
</div>

{{-- ─── CSS tambahan khusus halaman ini ─── --}}
<style>
.tbl-loading { text-align:center; padding:32px; color:var(--muted); font-size:13px; }
.form-error-msg {
    background: rgba(229,62,62,.08); border:1px solid rgba(229,62,62,.2);
    border-radius:8px; padding:10px 13px; font-size:12px; color:#E53E3E;
    margin-top:4px;
}
.pw-toggle {
    position:absolute; right:13px; top:50%; transform:translateY(-50%);
    background:none; border:none; cursor:pointer; font-size:16px;
    opacity:.4; transition:opacity .2s; padding:2px;
}
.pw-toggle:hover { opacity:.75; }

/* upload foto compact */
.upload-row {
    display:flex; align-items:center; gap:12px; padding:10px 12px;
    border:1.5px dashed var(--border); border-radius:10px;
    background:var(--bg); cursor:pointer; position:relative;
    transition:border-color .2s, background .2s;
}
.upload-row:hover, .upload-row.drag-over { border-color:var(--coral); background:var(--coral-bg); }
.upload-row input[type=file] { position:absolute; inset:0; opacity:0; cursor:pointer; width:100%; height:100%; }
.avatar-sm {
    width:38px; height:38px; border-radius:50%;
    background:var(--card); border:1.5px solid var(--border);
    display:flex; align-items:center; justify-content:center;
    overflow:hidden; flex-shrink:0; font-size:16px; transition:border-color .2s;
}
.avatar-sm img { width:100%; height:100%; object-fit:cover; display:none; }
.ut-main { font-size:13px; font-weight:600; color:var(--text); margin:0; }
.ut-sub  { font-size:11px; color:var(--muted); margin:1px 0 0; }
.ut-link { color:var(--coral); }
.remove-sm {
    width:22px; height:22px; border-radius:50%; border:1px solid var(--border);
    background:var(--card); color:var(--muted); font-size:10px; cursor:pointer;
    display:none; align-items:center; justify-content:center;
    flex-shrink:0; position:relative; z-index:2;
}
.remove-sm.show { display:flex; }
.remove-sm:hover { background:rgba(229,62,62,.1); color:#E53E3E; }
</style>

@endsection

@push('scripts')
<script>
/* ══════════════════════════════════════════════════
   STATE
══════════════════════════════════════════════════ */
let allUsers       = [];
let activeFilter   = 'semua';
let deleteUserId   = null;
let editPhotoFile  = null;   // File object untuk edit
let addPhotoFile   = null;   // File object untuk tambah

const AVATAR_COLORS = [
    'linear-gradient(135deg,#E8430D,#FF6B3D)',
    'linear-gradient(135deg,#008F78,#00C9A7)',
    'linear-gradient(135deg,#D48D00,#F6C244)',
    'linear-gradient(135deg,#2563EB,#60A5FA)',
    'linear-gradient(135deg,#805AD5,#B794F4)',
    'linear-gradient(135deg,#38A169,#68D391)',
];

/* ══════════════════════════════════════════════════
   INIT
══════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
    loadStats();
    loadUsers();
    document.getElementById('search-user').addEventListener('input', applyFilter);
});

/* ══════════════════════════════════════════════════
   HELPERS
══════════════════════════════════════════════════ */
function getUserStatus(user) {
    if (user.status) return user.status;
    const isActive = user.last_login_at &&
        new Date(user.last_login_at) >= new Date(Date.now() - 86400000);
    return isActive ? 'Aktif' : 'Tidak Aktif';
}

function getInitials(name) {
    return (name || '').split(' ').slice(0,2).map(w => w[0]).join('').toUpperCase();
}

function avatarColor(id) {
    return AVATAR_COLORS[(id || 0) % AVATAR_COLORS.length];
}

function formatDate(date) {
    if (!date) return '-';
    return new Date(date).toLocaleDateString('id-ID', {
        day:'2-digit', month:'short', year:'numeric'
    });
}

function escAttr(str) {
    return (str || '').replace(/'/g, "\\'").replace(/"/g, '&quot;');
}

/* ══════════════════════════════════════════════════
   STATS
══════════════════════════════════════════════════ */
async function loadStats() {
    try {
        const res    = await fetch('/api/users/stats');
        const result = await res.json();
        if (!result.success) return;

        const d = result.data;
        document.getElementById('stat-total').textContent   = (d.total_users   ?? 0).toLocaleString('id-ID');
        document.getElementById('stat-active').textContent  = (d.active_today  ?? 0).toLocaleString('id-ID');
        document.getElementById('stat-monthly').textContent = (d.new_this_month?? 0).toLocaleString('id-ID');

        setChange(document.getElementById('change-total'),   d.change_total);
        setChange(document.getElementById('change-active'),  d.change_active);
        setChange(document.getElementById('change-monthly'), d.change_monthly);
    } catch (err) {
        console.error('loadStats:', err);
    }
}

function setChange(el, value) {
    if (!el) return;
    const num = parseFloat(value) || 0;
    el.className = 'stat-change ' + (num > 0 ? 'up' : num < 0 ? 'down' : '');
    el.innerHTML = num > 0 ? `↑ ${num}%` : num < 0 ? `↓ ${Math.abs(num)}%` : `↔ 0%`;
}

/* ══════════════════════════════════════════════════
   LOAD & RENDER
══════════════════════════════════════════════════ */
async function loadUsers() {
    try {
        const res    = await fetch('/api/users');
        const result = await res.json();
        if (!result.success) return;
        allUsers = result.data;
        applyFilter();
    } catch (err) {
        console.error('loadUsers:', err);
        document.getElementById('user-table-body').innerHTML =
            `<tr><td colspan="6" class="tbl-loading" style="color:#E53E3E">Gagal memuat data.</td></tr>`;
    }
}

function applyFilter() {
    const keyword = (document.getElementById('search-user')?.value || '').toLowerCase();

    const filtered = allUsers.filter(user => {
        const status = getUserStatus(user);
        const matchFilter = activeFilter === 'semua' || status === activeFilter;
        const matchSearch = !keyword
            || (user.name  || '').toLowerCase().includes(keyword)
            || (user.email || '').toLowerCase().includes(keyword)
            || (user.role  || '').toLowerCase().includes(keyword)
            || status.toLowerCase().includes(keyword)
            || formatDate(user.created_at).toLowerCase().includes(keyword);
        return matchFilter && matchSearch;
    });

    renderUsers(filtered);
}

function setUserFilter(val, el) {
    activeFilter = val;
    document.querySelectorAll('#filter-user .filter-opt').forEach(o => o.classList.remove('active'));
    el.classList.add('active');
    document.getElementById('filter-user').classList.remove('open');
    applyFilter();
}

function renderUsers(users) {
    const tbody = document.getElementById('user-table-body');

    if (!users.length) {
        tbody.innerHTML = `<tr><td colspan="6" class="tbl-loading">Tidak ada pengguna ditemukan.</td></tr>`;
        return;
    }

    tbody.innerHTML = users.map(user => {
        const status   = getUserStatus(user);
        const pillCls  = status === 'Aktif' ? 'green' : 'yellow';
        const initials = getInitials(user.name);
        const color    = avatarColor(user.id);
        const fav      = user.favorites_count ?? 0;

        /* avatar: foto atau inisial */
        const avatarInner = user.photo
            ? `<img src="${user.photo}" style="width:100%;height:100%;border-radius:50%;object-fit:cover;">`
            : initials;

        /* data untuk modal — dikemas JSON agar aman dari karakter khusus */
        const userData = JSON.stringify({
            id:      user.id,
            name:    user.name,
            email:   user.email,
            role:    user.role ?? 'user',
            status,
            initials,
            color,
            photo:   user.photo ?? '',
            joined:  formatDate(user.created_at),
            fav,
        }).replace(/'/g,"&#39;");

        return `
        <tr data-status="${status}" data-id="${user.id}">
            <td>
                <div class="td-user">
                    <div class="td-avatar" style="background:${color}">${avatarInner}</div>
                    <div>
                        <div class="td-name">${user.name}</div>
                        <div class="td-sub">${user.role ?? 'user'}</div>
                    </div>
                </div>
            </td>
            <td>${user.email}</td>
            <td><span class="pill ${pillCls}">● ${status}</span></td>
            <td>${formatDate(user.created_at)}</td>
            <td>${fav}</td>
            <td>
                <div class="action-btns">
                    <button class="act-btn" title="Edit"   onclick='openEditUser(${userData})'>✏️</button>
                    <button class="act-btn" title="Lihat"  onclick='openViewUser(${userData})'>👁️</button>
                    <button class="act-btn" title="Hapus"
                        data-id="${user.id}" data-name="${escAttr(user.name)}"
                        onclick="showDeleteModal(this.dataset.id, this.dataset.name)">🗑️</button>
                </div>
            </td>
        </tr>`;
    }).join('');
}

/* ══════════════════════════════════════════════════
   FOTO UPLOAD
══════════════════════════════════════════════════ */
function previewPhoto(mode) {
    const input = document.getElementById(`${mode}-photo-input`);
    const file  = input.files[0];
    if (!file) return;

    if (mode === 'add') addPhotoFile  = file;
    else               editPhotoFile = file;

    const reader = new FileReader();
    reader.onload = e => {
        const img  = document.getElementById(`${mode}-avatar-img`);
        const ph   = document.getElementById(`${mode}-avatar-placeholder`);
        const prev = document.getElementById(`${mode}-avatar-preview`);
        const btn  = document.getElementById(`${mode}-remove-btn`);
        const title= document.getElementById(`${mode}-upload-title`);

        img.src           = e.target.result;
        img.style.display = 'block';
        ph.style.display  = 'none';
        prev.style.borderColor = 'var(--coral)';
        btn.classList.add('show');
        title.textContent = file.name.length > 24 ? file.name.slice(0,24)+'…' : file.name;
    };
    reader.readAsDataURL(file);
}

function removePhoto(mode, e) {
    e.stopPropagation();
    const img   = document.getElementById(`${mode}-avatar-img`);
    const ph    = document.getElementById(`${mode}-avatar-placeholder`);
    const prev  = document.getElementById(`${mode}-avatar-preview`);
    const btn   = document.getElementById(`${mode}-remove-btn`);
    const title = document.getElementById(`${mode}-upload-title`);
    const input = document.getElementById(`${mode}-photo-input`);

    img.src           = '';
    img.style.display = 'none';
    ph.style.display  = '';
    prev.style.borderColor = '';
    btn.classList.remove('show');
    title.textContent = 'Pilih foto profil';
    input.value       = '';

    if (mode === 'add') addPhotoFile  = null;
    else               editPhotoFile = null;
}

/* ══════════════════════════════════════════════════
   MODAL: VIEW
══════════════════════════════════════════════════ */
function openViewUser(d) {
    /* avatar: foto jika ada, inisial jika tidak */
    const avatarWrap = document.getElementById('vu-avatar-wrap');
    if (d.photo) {
        avatarWrap.innerHTML = `<img src="${d.photo}" style="width:100%;height:100%;object-fit:cover;">`;
        avatarWrap.style.background = 'transparent';
    } else {
        avatarWrap.innerHTML = d.initials;
        avatarWrap.style.background = d.color;
    }

    document.getElementById('vu-name').textContent   = d.name;
    document.getElementById('vu-role').textContent   = d.role;
    document.getElementById('vu-email').textContent  = d.email;
    document.getElementById('vu-status').textContent = d.status;
    document.getElementById('vu-joined').textContent = d.joined;
    document.getElementById('vu-fav').textContent    = d.fav + ' kost';
    openModal('modal-user-view');
}

/* ══════════════════════════════════════════════════
   MODAL: TAMBAH
══════════════════════════════════════════════════ */
function openAddUser() {
    /* reset form */
    document.getElementById('add-name').value            = '';
    document.getElementById('add-email').value           = '';
    document.getElementById('add-password').value        = '';
    document.getElementById('add-password-confirm').value= '';
    document.getElementById('add-error').style.display   = 'none';
    removePhoto('add', { stopPropagation: () => {} });
    setCselVal('csel-add-role', 'user');
    openModal('modal-user-add');
}

async function submitAddUser() {
    const name     = document.getElementById('add-name').value.trim();
    const email    = document.getElementById('add-email').value.trim();
    const role     = getCselVal('csel-add-role');
    const password = document.getElementById('add-password').value;
    const confirm  = document.getElementById('add-password-confirm').value;
    const errorEl  = document.getElementById('add-error');

    /* validasi frontend */
    if (!name || !email || !password) {
        showFormError(errorEl, 'Nama, email, dan password wajib diisi.');
        return;
    }
    if (password.length < 8) {
        showFormError(errorEl, 'Password minimal 8 karakter.');
        return;
    }
    if (password !== confirm) {
        showFormError(errorEl, 'Konfirmasi password tidak cocok.');
        return;
    }

    setBtnLoading('btn-add-save', 'btn-add-label', true, 'Menyimpan...');

    try {
        const body = new FormData();
        body.append('name',                  name);
        body.append('email',                 email);
        body.append('role',                  role);
        body.append('password',              password);
        body.append('password_confirmation', confirm);
        if (addPhotoFile) body.append('photo', addPhotoFile);

        const res  = await fetch('/api/users', {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
            body,
        });
        const data = await res.json();

        if (data.success || res.ok) {
            /* optimistic update: tambah ke array lokal */
            const newUser = data.data ?? { id: Date.now(), name, email, role,
                                           created_at: new Date().toISOString(),
                                           photo: addPhotoFile ? URL.createObjectURL(addPhotoFile) : null,
                                           favorites_count: 0 };
            allUsers.unshift(newUser);
            applyFilter();
            loadStats();

            closeModal('modal-user-add');
            showToast('Pengguna berhasil ditambahkan', '✅');
        } else {
            showFormError(errorEl, data.message || Object.values(data.errors ?? {}).flat().join(' ') || 'Gagal menyimpan.');
        }
    } catch (err) {
        console.error(err);
        showFormError(errorEl, 'Terjadi kesalahan server.');
    } finally {
        setBtnLoading('btn-add-save', 'btn-add-label', false, 'Simpan');
    }
}

/* ══════════════════════════════════════════════════
   MODAL: EDIT
══════════════════════════════════════════════════ */
function openEditUser(d) {
    document.getElementById('edit-user-id').value          = d.id;
    document.getElementById('edit-name').value             = d.name;
    document.getElementById('edit-email').value            = d.email;
    document.getElementById('edit-password').value         = '';
    document.getElementById('edit-password-confirm').value = '';
    document.getElementById('edit-error').style.display    = 'none';
    setCselVal('csel-edit-role', d.role);

    /* tampilkan foto yang sudah ada */
    const img  = document.getElementById('edit-avatar-img');
    const ph   = document.getElementById('edit-avatar-placeholder');
    const prev = document.getElementById('edit-avatar-preview');
    const btn  = document.getElementById('edit-remove-btn');
    const title= document.getElementById('edit-upload-title');

    editPhotoFile = null;
    document.getElementById('edit-photo-input').value = '';

    if (d.photo) {
        img.src           = d.photo;
        img.style.display = 'block';
        ph.style.display  = 'none';
        prev.style.borderColor = 'var(--coral)';
        btn.classList.add('show');
        title.textContent = 'Foto terpasang — klik untuk ganti';
    } else {
        img.src           = '';
        img.style.display = 'none';
        ph.style.display  = '';
        prev.style.borderColor = '';
        btn.classList.remove('show');
        title.textContent = 'Pilih foto profil';
    }

    openModal('modal-user-edit');
}

async function submitEditUser() {
    const id       = document.getElementById('edit-user-id').value;
    const name     = document.getElementById('edit-name').value.trim();
    const email    = document.getElementById('edit-email').value.trim();
    const role     = getCselVal('csel-edit-role');
    const password = document.getElementById('edit-password').value;
    const confirm  = document.getElementById('edit-password-confirm').value;
    const errorEl  = document.getElementById('edit-error');

    if (!name || !email) {
        showFormError(errorEl, 'Nama dan email wajib diisi.');
        return;
    }
    if (password && password.length < 8) {
        showFormError(errorEl, 'Password minimal 8 karakter.');
        return;
    }
    if (password && password !== confirm) {
        showFormError(errorEl, 'Konfirmasi password tidak cocok.');
        return;
    }

    setBtnLoading('btn-edit-save', 'btn-edit-label', true, 'Menyimpan...');

    try {
        const body = new FormData();
        body.append('_method', 'PUT');  // Laravel method spoofing
        body.append('name',    name);
        body.append('email',   email);
        body.append('role',    role);
        if (password) {
            body.append('password',              password);
            body.append('password_confirmation', confirm);
        }
        if (editPhotoFile) body.append('photo', editPhotoFile);

        const res  = await fetch(`/api/users/${id}`, {
            method: 'POST', // FormData tidak bisa PUT langsung, pakai _method
            headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
            body,
        });
        const data = await res.json();

        if (data.success || res.ok) {
            /* update array lokal secara optimistic */
            const idx = allUsers.findIndex(u => String(u.id) === String(id));
            if (idx !== -1) {
                allUsers[idx] = {
                    ...allUsers[idx],
                    name, email, role,
                    photo: data.data?.photo
                        ?? (editPhotoFile ? URL.createObjectURL(editPhotoFile) : allUsers[idx].photo),
                };
            }
            applyFilter();

            closeModal('modal-user-edit');
            showToast('Data pengguna diperbarui', '✅');
        } else {
            showFormError(errorEl, data.message || Object.values(data.errors ?? {}).flat().join(' ') || 'Gagal menyimpan.');
        }
    } catch (err) {
        console.error(err);
        showFormError(errorEl, 'Terjadi kesalahan server.');
    } finally {
        setBtnLoading('btn-edit-save', 'btn-edit-label', false, 'Simpan');
    }
}

/* ══════════════════════════════════════════════════
   DELETE
══════════════════════════════════════════════════ */
function showDeleteModal(id, name) {
    deleteUserId = id;
    document.getElementById('delete-user-name').textContent = name;
    document.getElementById('delete-modal').style.display = 'flex';
}

function hideDeleteModal() {
    document.getElementById('delete-modal').style.display = 'none';
    deleteUserId = null;
}

async function confirmDelete() {
    if (!deleteUserId) return;

    const btn = document.getElementById('btn-confirm-delete');
    btn.disabled    = true;
    btn.textContent = 'Menghapus...';

    try {
        const res  = await fetch(`/api/users/${deleteUserId}`, {
            method:  'DELETE',
            headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
        });
        const data = await res.json();

        if (data.success || res.ok) {
            /* hapus dari array lokal — tidak perlu reload halaman */
            allUsers = allUsers.filter(u => String(u.id) !== String(deleteUserId));
            applyFilter();
            loadStats();
            hideDeleteModal();
            showToast('Pengguna berhasil dihapus', '🗑️');
        } else {
            showToast(data.message || 'Gagal menghapus.', '❌');
        }
    } catch (err) {
        console.error(err);
        showToast('Terjadi kesalahan server.', '❌');
    } finally {
        btn.disabled    = false;
        btn.textContent = 'Hapus';
    }
}

/* ══════════════════════════════════════════════════
   UTILITY
══════════════════════════════════════════════════ */
function showFormError(el, msg) {
    el.textContent    = msg;
    el.style.display  = 'block';
}

function setBtnLoading(btnId, labelId, loading, text) {
    const btn   = document.getElementById(btnId);
    const label = document.getElementById(labelId);
    btn.disabled     = loading;
    label.textContent = text;
}

function togglePwVis(inputId, btn) {
    const inp = document.getElementById(inputId);
    inp.type  = inp.type === 'password' ? 'text' : 'password';
    btn.style.opacity = inp.type === 'text' ? '0.8' : '0.4';
}

/* getCselVal & setCselVal — harus sudah ada di layout global */
/* Fallback jika belum ada: */
if (typeof getCselVal === 'undefined') {
    window.getCselVal = id => {
        const w = document.getElementById(id);
        return w ? (w.dataset.value || w.querySelector('.csel-val')?.textContent.trim() || '') : '';
    };
}
if (typeof setCselVal === 'undefined') {
    window.setCselVal = (id, val) => {
        const w = document.getElementById(id);
        if (!w) return;
        const opt = [...w.querySelectorAll('.csel-opt')].find(o =>
            o.dataset.val === val || o.textContent.trim().includes(val));
        if (opt) {
            w.querySelector('.csel-val').textContent = opt.textContent.trim();
            w.dataset.value = opt.dataset.val;
            w.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
            opt.classList.add('active');
        }
    };
}
</script>
@endpush
