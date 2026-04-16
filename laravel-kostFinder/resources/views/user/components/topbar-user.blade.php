<header class="u-topbar">
    {{-- Toggle sidebar (mobile) --}}
    <button class="sidebar-toggle" id="mobile-toggle"
        onclick="document.getElementById('sidebar').classList.toggle('open')"
        style="display:none">☰</button>

    {{-- Collapse sidebar (desktop) --}}
    <button class="collapse-btn" id="collapse-btn" onclick="toggleCollapse()" title="Kecilkan Sidebar">‹</button>

    {{-- Judul halaman --}}
    <div class="topbar-title">@yield('page_title', 'Beranda')</div>

    {{-- Action area --}}
    <div class="topbar-actions">
        {{-- Tanggal --}}
        <div id="topbar-date"
            style="font-size:12px;color:var(--muted);white-space:nowrap;display:none"></div>

        {{-- Dark mode toggle --}}
        <button class="icon-btn" id="theme-toggle" onclick="toggleTheme()" title="Ganti Tema">🌙</button>

        {{-- Divider --}}
        <div style="width:1px;height:28px;background:var(--border)"></div>

        {{-- Avatar + Nama + Role --}}
        @php
            $foto    = Auth::user()->profile_picture ?? null;
            $fotoUrl = $foto ? (str_starts_with($foto, 'http') ? $foto : asset('storage/' . $foto)) : null;
            $inisial = strtoupper(substr(Auth::user()->name ?? 'U', 0, 1));
        @endphp

        <div style="width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,var(--coral),var(--coral2));display:flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-size:14px;font-weight:800;color:white;overflow:hidden;flex-shrink:0;box-shadow:0 2px 8px rgba(232,67,13,.25)">
            @if($fotoUrl)
                <img src="{{ $fotoUrl }}" style="width:100%;height:100%;object-fit:cover;" alt="{{ Auth::user()->name }}">
            @else
                {{ $inisial }}
            @endif
        </div>

        <div style="display:flex;flex-direction:column;line-height:1.25;min-width:0">
            <span style="font-size:13px;font-weight:700;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:120px">{{ Auth::user()->name }}</span>
            <span style="font-size:11px;color:var(--muted)">Pengguna</span>
        </div>
    </div>
</header>

<script>
    // Tampilkan tanggal hari ini
    (function () {
        const el = document.getElementById('topbar-date');
        if (!el) return;
        const now = new Date();
        el.textContent = now.toLocaleDateString('id-ID', {
            weekday: 'short', day: 'numeric', month: 'short', year: 'numeric'
        });
        el.style.display = '';
    })();

    // Restore dark mode & collapse state dari localStorage
    (function () {
        if (localStorage.getItem('kf_theme') === 'dark') {
            document.body.classList.add('dark');
            const btn = document.getElementById('theme-toggle');
            if (btn) btn.textContent = '☀️';
        }
        if (localStorage.getItem('kf_sidebar') === 'collapsed') {
            document.body.classList.add('collapsed');
            const cb = document.getElementById('collapse-btn');
            if (cb) cb.style.transform = 'rotate(180deg)';
        }
    })();
</script>
