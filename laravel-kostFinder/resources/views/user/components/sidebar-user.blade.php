<aside class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">🏠</div>
        <div class="wordmark">Kost<span>Finder</span>
            <div style="font-size:9px;font-weight:400;color:var(--muted);margin-top:1px;white-space:nowrap">Platform Kost Terpercaya</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Menu Utama</div>

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

        <div class="nav-section-label">Developer</div>

        <a href="{{ route('user.api-tester') }}" class="nav-item {{ request()->routeIs('user.api-tester') ? 'active' : '' }}">
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

{{-- Form POST logout --}}
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
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') hideLogoutModal();
    });
</script>
