<header class="topbar">
    <button class="sidebar-toggle" onclick="document.getElementById('sidebar').classList.toggle('open')">☰</button>
    <button class="collapse-btn" id="collapse-btn" onclick="toggleCollapse()">‹</button>

    <div class="topbar-title">@yield('page_title')</div>

    <div class="topbar-actions">
        <span id="topbar-date" style="font-size:12px;color:var(--muted);display:none"></span>
        <button class="icon-btn" id="theme-toggle" onclick="toggleTheme()">🌙</button>

        {{-- Notifikasi --}}
        <div style="position:relative" id="notif-wrap">
            <button class="icon-btn" id="notif-btn" onclick="toggleNotifDropdownUser()" title="Notifikasi" style="position:relative">
                🔔<span class="notif-dot" id="notif-dot" style="display:none"></span>
            </button>
            <div class="topbar-dropdown" id="notif-dropdown">
                <div class="topbar-dropdown-header">
                    <span style="font-weight:700;font-size:14px">🔔 Aktivitas Terbaru</span>
                    <button onclick="toggleNotifDropdownUser()" style="background:none;border:none;cursor:pointer;font-size:16px;color:var(--muted)">✕</button>
                </div>
                <div class="topbar-dropdown-body" id="notif-list">
                    <div style="text-align:center;padding:24px;color:var(--muted);font-size:13px">⏳ Memuat...</div>
                </div>
            </div>
        </div>

        {{-- Profil --}}
        @php
            $foto    = Auth::user()->profile_picture ?? null;
            $fotoUrl = $foto ? (str_starts_with($foto, 'http') ? $foto : asset('storage/' . $foto)) : null;
            $inisial = strtoupper(substr(Auth::user()->name ?? 'U', 0, 1));
        @endphp
        <div style="position:relative" id="profil-wrap">
            <button class="icon-btn" onclick="toggleProfilDropdownUser()" title="Profil"
                style="padding:0;width:36px;height:36px;border-radius:50%;overflow:hidden;background:linear-gradient(135deg,var(--coral),var(--coral2));display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:800;color:white;font-family:'Syne',sans-serif">
                @if($fotoUrl)
                    <img src="{{ $fotoUrl }}" style="width:100%;height:100%;object-fit:cover;" alt="{{ Auth::user()->name }}">
                @else
                    {{ $inisial }}
                @endif
            </button>
            <div class="topbar-dropdown" id="profil-dropdown" style="right:0;width:300px">
                <div class="topbar-dropdown-header">
                    <span style="font-weight:700;font-size:14px">👤 Profil Saya</span>
                    <button onclick="toggleProfilDropdownUser()" style="background:none;border:none;cursor:pointer;font-size:16px;color:var(--muted)">✕</button>
                </div>
                <div class="topbar-dropdown-body" style="padding:18px">
                    <div style="display:flex;align-items:center;gap:14px;margin-bottom:16px">
                        <div style="width:56px;height:56px;border-radius:50%;background:linear-gradient(135deg,var(--coral),var(--coral2));display:flex;align-items:center;justify-content:center;font-size:22px;font-weight:800;color:white;font-family:'Syne',sans-serif;flex-shrink:0;overflow:hidden">
                            @if($fotoUrl)
                                <img src="{{ $fotoUrl }}" style="width:100%;height:100%;object-fit:cover;" alt="">
                            @else
                                {{ $inisial }}
                            @endif
                        </div>
                        <div>
                            <div style="font-weight:700;font-size:15px;font-family:'Syne',sans-serif">{{ Auth::user()->name }}</div>
                            <div style="font-size:12px;color:var(--muted);margin-top:2px">{{ ucfirst(Auth::user()->role ?? 'Pengguna') }}</div>
                        </div>
                    </div>
                    <div style="background:var(--bg);border:1px solid var(--border);border-radius:12px;padding:14px;font-size:13px">
                        <div style="display:flex;justify-content:space-between;padding:6px 0;border-bottom:1px solid var(--border)">
                            <span style="color:var(--muted)">Email</span>
                            <span style="font-weight:600;font-size:12px">{{ Auth::user()->email }}</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;padding:6px 0;border-bottom:1px solid var(--border)">
                            <span style="color:var(--muted)">Role</span>
                            <span style="font-weight:600">{{ ucfirst(Auth::user()->role ?? 'Pengguna') }}</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;padding:6px 0">
                            <span style="color:var(--muted)">Login Terakhir</span>
                            <span style="font-weight:600;font-size:12px">{{ Auth::user()->last_login_at ? Auth::user()->last_login_at->format('d M Y, H:i') : '-' }}</span>
                        </div>
                    </div>
                    <div style="margin-top:14px">
                        <button onclick="showLogoutModal()"
                            style="width:100%;padding:10px;border-radius:10px;border:none;background:#E53E3E;color:white;font-family:'DM Sans',sans-serif;font-size:13px;font-weight:600;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px">
                            ⏻ Keluar dari Akun
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
function toggleNotifDropdownUser(){
    const dd = document.getElementById('notif-dropdown');
    const isOpen = dd.classList.contains('open');
    closeAllUserTopbarDropdowns();
    if(!isOpen){
        dd.classList.add('open');
        loadUserNotifications();
    }
}

function toggleProfilDropdownUser(){
    const dd = document.getElementById('profil-dropdown');
    const isOpen = dd.classList.contains('open');
    closeAllUserTopbarDropdowns();
    if(!isOpen) dd.classList.add('open');
}

function closeAllUserTopbarDropdowns(){
    document.querySelectorAll('.topbar-dropdown').forEach(d=>d.classList.remove('open'));
}

document.addEventListener('click', e => {
    if(!e.target.closest('#notif-wrap') && !e.target.closest('#profil-wrap')){
        closeAllUserTopbarDropdowns();
    }
});

async function loadUserNotifications(){
    const list = document.getElementById('notif-list');
    try {
        const res = await fetch('/api/user/stats');
        const result = await res.json();

        if(!result.success){
            list.innerHTML = '<div style="text-align:center;padding:36px;color:var(--muted);font-size:13px">Tidak ada aktivitas terbaru.</div>';
            return;
        }

        const d = result.data;
        const items = [
            { icon:'❤️', bg:'coral', title:'Kost Favorit Saya', desc:`${d.total_favorit} kost tersimpan di favorit` },
            { icon:'⭐', bg:'teal',  title:'Ulasan Ditulis',    desc:`${d.total_review} ulasan telah ditulis` },
            { icon:'🏘️', bg:'yellow',title:'Kost Tersedia',     desc:`${d.total_kost} kost siap ditempati` },
        ];

        list.innerHTML = items.map(n => `
            <div class="notif-item">
                <div class="notif-icon-wrap ${n.bg}">${n.icon}</div>
                <div class="notif-content">
                    <div class="notif-title">${n.title}</div>
                    <div class="notif-desc">${n.desc}</div>
                </div>
            </div>`).join('');

        document.getElementById('notif-dot').style.display = '';
    } catch(err){
        console.error('loadUserNotifications:', err);
        list.innerHTML = '<div style="text-align:center;padding:24px;color:#E53E3E;font-size:13px">Gagal memuat notifikasi.</div>';
    }
}
</script>
