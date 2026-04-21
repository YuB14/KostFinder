<aside class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">🏠</div>
        <div class="wordmark">Kost<span>Finder</span></div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Menu Utama</div>

        <a href="{{ route('dashboard') }}" class="nav-item {{ request()->is('dashboard') ? 'active' : '' }}">
            <span class="nav-icon">📊</span>
            <span class="nav-label">Beranda</span>
            <span class="nav-tooltip">Beranda</span>
        </a>

        <a href="{{ route('user') }}" class="nav-item {{ request()->is('user*') ? 'active' : '' }}">
            <span class="nav-icon">👥</span>
            <span class="nav-label">Pengguna</span>
            <span class="nav-badge">12</span>
            <span class="nav-tooltip">Pengguna</span>
        </a>

        <a href="{{ route('kost') }}" class="nav-item {{ request()->is('kost*') ? 'active' : '' }}">
            <span class="nav-icon">🏘️</span>
            <span class="nav-label">Data Kost</span>
            <span class="nav-badge teal">6</span>
            <span class="nav-tooltip">Data Kost</span>
        </a>

        <a href="{{ route('review') }}" class="nav-item {{ request()->is('review*') ? 'active' : '' }}">
            <span class="nav-icon">⭐</span>
            <span class="nav-label">Ulasan</span>
            <span class="nav-tooltip">Ulasan</span>
        </a>

        <a href="{{ route('favorite') }}" class="nav-item {{ request()->is('favorite*') ? 'active' : '' }}">
            <span class="nav-icon">❤️</span>
            <span class="nav-label">Favorit</span>
            <span class="nav-tooltip">Favorit</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="user-chip">
            <div class="user-avatar">AR</div>
            <div class="user-info">
                <strong>Aini Rahmawati</strong>
                <span>Admin</span>
            </div>

            <form id="logout-form" action="{{ route('logout') }}" method="POST" style="display: none;">
                @csrf
            </form>

            <button class="logout-btn"
                    onclick="showLogoutModal()"
                    title="Keluar">
                ⏻
            </button>
        </div>
    </div>
</aside>
