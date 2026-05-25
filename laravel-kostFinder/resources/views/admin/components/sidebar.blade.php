<aside class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon"><img src="{{ asset('storage/images/logo-kostFinder.png') }}" alt="KostFinder" style="width:36px;height:36px;border-radius:10px;object-fit:cover;"></div>
        <div class="wordmark">Kost<span>Finder</span><div style="font-size:9px;font-weight:400;color:var(--muted);margin-top:1px;white-space:nowrap">Platform Kost Terpercaya</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Menu Utama</div>

        <a href="{{ route('dashboard') }}" class="nav-item {{ request()->routeIs('dashboard') ? 'active' : '' }}">
            <span class="nav-icon">📊</span>
            <span class="nav-label">Beranda</span>
            <span class="nav-tooltip">Beranda</span>
        </a>

        <a href="{{ route('user') }}" class="nav-item {{ request()->routeIs('user*') ? 'active' : '' }}">
            <span class="nav-icon">👥</span>
            <span class="nav-label">Pengguna</span>
            <span class="nav-tooltip">Pengguna</span>
        </a>

        <a href="{{ route('kost') }}" class="nav-item {{ request()->routeIs('kost*') ? 'active' : '' }}">
            <span class="nav-icon">🏘️</span>
            <span class="nav-label">Data Kost</span>
            <span class="nav-tooltip">Data Kost</span>
        </a>

        <a href="{{ route('review') }}" class="nav-item {{ request()->routeIs('review*') ? 'active' : '' }}">
            <span class="nav-icon">⭐</span>
            <span class="nav-label">Ulasan</span>
            <span class="nav-tooltip">Ulasan</span>
        </a>

        <a href="{{ route('favorite') }}" class="nav-item {{ request()->routeIs('favorite*') ? 'active' : '' }}">
            <span class="nav-icon">❤️</span>
            <span class="nav-label">Favorit</span>
            <span class="nav-tooltip">Favorit</span>
        </a>

        <div class="nav-section-label">Developer</div>

        <a href="{{ route('api-tester') }}" class="nav-item {{ request()->routeIs('api-tester*') ? 'active' : '' }}">
            <span class="nav-icon">📡</span>
            <span class="nav-label">API / JSON</span>
            <span class="nav-tooltip">API / JSON</span>
        </a>
    </nav>

    {{-- ─── FOOTER: info user + tombol logout ─── --}}
    <div class="sidebar-footer">
        <div class="user-chip">

            {{-- Avatar: foto profil jika ada, inisial jika tidak --}}
            <div class="user-avatar">
                @php
                    // Field di DB adalah "profile_picture"
                    $foto = Auth::user()->profile_picture ?? null;
                    $fotoUrl = $foto
                        ? (str_starts_with($foto, 'http') ? $foto : asset('storage/' . $foto))
                        : null;
                    $inisial = strtoupper(substr(Auth::user()->name ?? 'U', 0, 1));
                @endphp

                @if($fotoUrl)
                    <img src="{{ $fotoUrl }}" style="width:100%;height:100%;border-radius:50%;object-fit:cover;"
                        alt="{{ Auth::user()->name }}">
                @else
                    {{ $inisial }}
                @endif
            </div>

            <div class="user-info">
                <strong>{{ Auth::user()->name }}</strong>
                <span>{{ ucfirst(Auth::user()->role ?? 'User') }}</span>
            </div>

            {{-- Tombol logout — buka modal konfirmasi --}}
            <button class="logout-btn" onclick="showLogoutModal()" title="Keluar">⏻</button>
        </div>
    </div>
</aside>

{{-- ─── MODAL: KONFIRMASI LOGOUT ─── --}}
<div id="logout-modal"
    style="display:none;position:fixed;inset:0;z-index:9000;align-items:center;justify-content:center;">

    {{-- Backdrop --}}
    <div onclick="hideLogoutModal()"
        style="position:absolute;inset:0;background:rgba(0,0,0,.45);backdrop-filter:blur(3px);">
    </div>

    {{-- Box --}}
    <div style="position:relative;background:var(--card);border:1px solid var(--border);
        border-radius:18px;padding:32px 28px;width:320px;box-shadow:var(--shadow-lg);text-align:center;">

        <div style="width:56px;height:56px;border-radius:16px;background:rgba(229,62,62,.1);
            display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 16px;">
            ⏻
        </div>

        <h3 style="font-family:'Syne',sans-serif;font-size:18px;font-weight:800;margin-bottom:8px;">
            Keluar dari Akun?
        </h3>
        <p style="font-size:13px;color:var(--muted);line-height:1.6;margin-bottom:24px;">
            Anda akan keluar dari dashboard KostFinder.<br>
            Pastikan semua perubahan sudah tersimpan.
        </p>

        <div style="display:flex;gap:10px;">
            <button onclick="hideLogoutModal()" style="flex:1;padding:11px;border-radius:10px;border:1.5px solid var(--border);
                background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;
                font-size:14px;font-weight:600;cursor:pointer;">
                Batal
            </button>
            <button onclick="doLogout()" id="btn-logout-confirm" style="flex:1;padding:11px;border-radius:10px;border:none;background:#E53E3E;
                color:white;font-family:'DM Sans',sans-serif;font-size:14px;font-weight:600;
                cursor:pointer;box-shadow:0 2px 10px rgba(229,62,62,.3);">
                Ya, Keluar
            </button>
        </div>
    </div>
</div>

{{-- Form POST logout — dikirim oleh doLogout() --}}
<form id="logout-form" action="{{ route('logout') }}" method="POST" style="display:none">
    @csrf
</form>

<script>
    function showLogoutModal() {
        document.getElementById('logout-modal').style.display = 'flex';
    }

    function hideLogoutModal() {
        document.getElementById('logout-modal').style.display = 'none';
    }

    function doLogout() {
        const btn = document.getElementById('btn-logout-confirm');
        btn.disabled = true;
        btn.textContent = 'Keluar...';

        // Submit form POST — Laravel hapus session & redirect ke /login
        document.getElementById('logout-form').submit();
    }

    // Tutup modal jika klik di luar box (sudah ditangani backdrop onclick)
    // Tutup juga jika tekan Escape
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') hideLogoutModal();
    });
</script>
