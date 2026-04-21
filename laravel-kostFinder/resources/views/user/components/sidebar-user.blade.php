<aside class="sidebar" id="sidebar">

    {{-- Logo — tinggi sama dengan topbar --}}
    <div class="sidebar-logo">
        <div class="logo-icon">🏠</div>
        <div class="wordmark">Kost<span>Finder</span>
            <div style="font-size:9px;font-weight:400;color:var(--muted);margin-top:1px;white-space:nowrap">Platform Kost Terpercaya</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Menu</div>

        <a href="{{ route('user.dashboard') }}" class="nav-item {{ request()->routeIs('user.dashboard') ? 'active' : '' }}">
            <span class="nav-icon">📊</span>
            <span class="nav-label">Beranda</span>
            <span class="nav-tooltip">Beranda</span>
        </a>

        <a href="{{ route('user.kost') }}" class="nav-item {{ request()->routeIs('user.kost') ? 'active' : '' }}">
            <span class="nav-icon">🏘️</span>
            <span class="nav-label">Cari Kost</span>
            <span class="nav-tooltip">Cari Kost</span>
        </a>

        <a href="{{ route('user.favorite') }}" class="nav-item {{ request()->routeIs('user.favorite') ? 'active' : '' }}">
            <span class="nav-icon">❤️</span>
            <span class="nav-label">Favorit Saya</span>
            <span class="nav-tooltip">Favorit Saya</span>
        </a>

        <a href="{{ route('user.review') }}" class="nav-item {{ request()->routeIs('user.review') ? 'active' : '' }}">
            <span class="nav-icon">⭐</span>
            <span class="nav-label">Ulasan Saya</span>
            <span class="nav-tooltip">Ulasan Saya</span>
        </a>

        <a href="{{ route('user.prediksi') }}" class="nav-item {{ request()->routeIs('user.prediksi') ? 'active' : '' }}">
            <span class="nav-icon">🤖</span>
            <span class="nav-label">Prediksi Kost</span>
            <span class="nav-tooltip">Prediksi Kost</span>
        </a>
    </nav>

    {{-- Footer: info user + logout --}}
    <div class="sidebar-footer">
        <div class="user-chip">
            @php
                $foto    = Auth::user()->profile_picture ?? null;
                $fotoUrl = $foto ? (str_starts_with($foto, 'http') ? $foto : asset('storage/' . $foto)) : null;
                $inisial = strtoupper(substr(Auth::user()->name ?? 'U', 0, 1));
            @endphp

            <div class="user-avatar">
                @if($fotoUrl)
                    <img src="{{ $fotoUrl }}" style="width:100%;height:100%;border-radius:50%;object-fit:cover;" alt="{{ Auth::user()->name }}">
                @else
                    {{ $inisial }}
                @endif
            </div>

            <div class="user-info">
                <strong>{{ Auth::user()->name }}</strong>
                <span>Pengguna</span>
            </div>

            <button class="logout-btn" onclick="showLogoutModal()" title="Keluar">⏻</button>
        </div>
    </div>
</aside>

{{-- Form POST logout --}}
<form id="logout-form" action="{{ route('logout') }}" method="POST" style="display:none">
    @csrf
</form>
