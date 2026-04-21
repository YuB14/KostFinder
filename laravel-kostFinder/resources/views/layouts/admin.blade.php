<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') — KostFinder</title>

    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ asset('css/style.css') }}">
</head>
<body class="{{ $bodyClass ?? '' }}">

    {{-- Memanggil Sidebar --}}
    @include('components.sidebar')

    <div class="main">
        {{-- Memanggil Topbar --}}
        @include('components.topbar')

        <div class="content">
            {{-- Konten dinamis akan muncul di sini --}}
            @yield('content')
        </div>
    </div>

    <div id="toast" style="position:fixed; bottom:30px; left:50%; transform:translateX(-50%) translateY(80px); opacity:0; transition:all .4s; z-index:9999; background:var(--card); border:1px solid var(--border); padding:12px 20px; border-radius:12px; display:flex; align-items:center; gap:10px; box-shadow:var(--shadow-lg);">
        <span id="toast-icon"></span>
        <span id="toast-msg" style="font-size:14px; font-weight:600;"></span>
    </div>
    
    <!-- LOGOUT MODAL -->
    <div id="logout-modal" style="display:none; position:fixed; inset:0; z-index:9000; align-items:center; justify-content:center;">
        <div id="logout-backdrop" onclick="hideLogoutModal()" style="position:absolute; inset:0; background:rgba(0,0,0,.45); backdrop-filter:blur(3px);"></div>
        <div style="position:relative; background:var(--card); border:1px solid var(--border); border-radius:18px; padding:32px 28px; width:320px; box-shadow:var(--shadow-lg); text-align:center; animation:fadeUp .25s ease both;">
            <div style="width:56px;height:56px;border-radius:16px;background:rgba(229,62,62,.1);display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 16px;">⏻</div>
            <h3 style="font-family:'Syne',sans-serif;font-size:18px;font-weight:800;margin-bottom:8px;">Keluar dari Akun?</h3>
            <p style="font-size:13px;color:var(--muted);line-height:1.6;margin-bottom:24px;">Anda akan keluar dari dashboard KostFinder. Pastikan semua perubahan sudah tersimpan.</p>
            <div style="display:flex;gap:10px;">
                <button onclick="hideLogoutModal()" style="flex:1;padding:11px;border-radius:10px;border:1.5px solid var(--border);background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;font-size:14px;font-weight:600;cursor:pointer;">Batal</button>
                <button onclick="doLogout()" style="flex:1;padding:11px;border-radius:10px;border:none;background:#E53E3E;color:white;font-family:'DM Sans',sans-serif;font-size:14px;font-weight:600;cursor:pointer;box-shadow:0 2px 10px rgba(229,62,62,.3);">Ya, Keluar</button>
            </div>
        </div>
    </div>

    <script src="{{ asset('js/script.js') }}"></script>
    @stack('scripts') {{-- Untuk script tambahan per halaman --}}
</body>
</html>
