<header class="topbar">
    <button class="sidebar-toggle" onclick="document.getElementById('sidebar').classList.toggle('open')">☰</button>
    <button class="collapse-btn" id="collapse-btn" onclick="toggleCollapse()">‹</button>

    <div class="topbar-title">@yield('page_title')</div>

    <div class="topbar-actions">
        <button class="icon-btn" id="theme-toggle" onclick="toggleTheme()">🌙</button>
        <button class="icon-btn">🔔<span class="notif-dot"></span></button>
        <button class="icon-btn">👤</button>
    </div>
</header>
