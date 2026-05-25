<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>KostFinder — Temukan Kost Impianmu</title>
  <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --coral:    #E8430D;
      --coral2:   #FF6B3D;
      --teal:     #008F78;
      --teal2:    #00C9A7;
      --navy:     #F5F7FA;
      --navy2:    #EAEFF5;
      --card-bg:  #FFFFFF;
      --muted:    #6B7E94;
      --white:    #1A2A3A;
      --yellow:   #D48D00;
      --r: 16px;
    }

    html { scroll-behavior: smooth; }

    body {
      background: var(--navy);
      color: var(--white);
      font-family: 'DM Sans', sans-serif;
      overflow-x: hidden;
    }

    /* ─── NOISE OVERLAY ─── */
    body::before {
      content: '';
      position: fixed; inset: 0;
      background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.02'/%3E%3C/svg%3E");
      pointer-events: none; z-index: 9999;
    }

    /* ─── NAV ─── */
    nav {
      position: fixed; top: 0; left: 0; right: 0; z-index: 100;
      display: flex; align-items: center; justify-content: space-between;
      padding: 20px 48px;
      background: rgba(245, 247, 250, 0.85);
      backdrop-filter: blur(18px);
      border-bottom: 1px solid rgba(0,0,0,0.08);
    }

    .logo {
      font-family: 'Syne', sans-serif;
      font-size: 22px; font-weight: 800;
      display: flex; align-items: center; gap: 8px;
    }
    .logo span.dot { color: var(--coral); }

    nav ul {
      list-style: none;
      display: flex; gap: 36px;
    }
    nav ul li a {
      color: var(--muted);
      text-decoration: none;
      font-size: 14px; font-weight: 500;
      transition: color .2s;
    }
    nav ul li a:hover { color: var(--white); }

    .nav-cta {
      background: var(--coral);
      color: white !important;
      padding: 10px 22px;
      border-radius: 100px;
      font-weight: 600 !important;
      font-size: 14px !important;
      transition: background .2s, transform .15s !important;
    }
    .nav-cta:hover { background: var(--coral2) !important; transform: translateY(-1px); }

    /* ─── HERO ─── */
    .hero {
      min-height: 100vh;
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      text-align: center;
      padding: 120px 24px 80px;
      position: relative; overflow: hidden;
    }

    /* big blurred blobs */
    .blob {
      position: absolute; border-radius: 50%;
      filter: blur(100px); opacity: .12; pointer-events: none;
    }
    .blob-1 { width: 600px; height: 600px; background: var(--coral); top: -150px; right: -100px; animation: drift 12s ease-in-out infinite alternate; }
    .blob-2 { width: 500px; height: 500px; background: var(--teal);  bottom: -80px; left: -80px;  animation: drift 16s ease-in-out infinite alternate-reverse; }
    .blob-3 { width: 300px; height: 300px; background: var(--yellow); top: 40%; left: 40%; animation: drift 10s ease-in-out infinite alternate; }

    @keyframes drift {
      from { transform: translate(0, 0) scale(1); }
      to   { transform: translate(40px, 30px) scale(1.08); }
    }

    .hero-badge {
      display: inline-flex; align-items: center; gap: 8px;
      background: rgba(232,67,13,.1);
      border: 1px solid rgba(232,67,13,.3);
      border-radius: 100px;
      padding: 6px 16px;
      font-size: 12px; font-weight: 600;
      color: var(--coral2);
      letter-spacing: .06em; text-transform: uppercase;
      margin-bottom: 28px;
      animation: fadeDown .6s ease both;
    }
    .hero-badge .pulse { width: 8px; height: 8px; border-radius: 50%; background: var(--coral); animation: pulse 1.5s infinite; }
    @keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.5;transform:scale(1.4)} }

    .hero h1 {
      font-family: 'Syne', sans-serif;
      font-size: clamp(42px, 7vw, 88px);
      font-weight: 800;
      line-height: 1.05;
      letter-spacing: -.02em;
      max-width: 900px;
      animation: fadeDown .7s .1s ease both;
    }
    .hero h1 .accent { color: var(--coral); }
    .hero h1 .accent2 { color: var(--teal); }

    .hero p {
      margin-top: 24px;
      font-size: 18px; font-weight: 300;
      color: var(--muted);
      max-width: 520px;
      line-height: 1.7;
      animation: fadeDown .7s .2s ease both;
    }

    /* search bar */
    .search-box {
      margin-top: 48px;
      display: flex; align-items: center;
      background: var(--card-bg);
      border: 1px solid rgba(0,0,0,.12);
      border-radius: 100px;
      padding: 8px 8px 8px 24px;
      width: 100%; max-width: 620px;
      gap: 12px;
      box-shadow: 0 8px 32px rgba(0,0,0,.1);
      animation: fadeUp .7s .35s ease both;
      transition: border-color .2s;
    }
    .search-box:focus-within { border-color: var(--coral); }

    .search-box input {
      flex: 1; background: transparent; border: none; outline: none;
      color: var(--white); font-family: 'DM Sans', sans-serif;
      font-size: 15px;
    }
    .search-box input::placeholder { color: var(--muted); }

    .search-btn {
      background: var(--coral);
      color: white; border: none; cursor: pointer;
      font-family: 'Syne', sans-serif;
      font-weight: 700; font-size: 14px;
      padding: 14px 28px; border-radius: 100px;
      white-space: nowrap;
      transition: background .2s, transform .15s;
    }
    .search-btn:hover { background: var(--coral2); transform: scale(1.03); }

    .hero-stats {
      margin-top: 56px;
      display: flex; gap: 48px;
      animation: fadeUp .7s .5s ease both;
    }
    .stat { text-align: center; }
    .stat .num {
      font-family: 'Syne', sans-serif;
      font-size: 32px; font-weight: 800;
      color: var(--white);
    }
    .stat .num span { color: var(--coral); }
    .stat .label { font-size: 13px; color: var(--muted); margin-top: 4px; }

    /* floating cards */
    .float-card {
      position: absolute;
      background: var(--card-bg);
      border: 1px solid rgba(0,0,0,.08);
      border-radius: 14px;
      padding: 14px 18px;
      font-size: 13px;
      display: flex; align-items: center; gap: 10px;
      backdrop-filter: blur(12px);
      box-shadow: 0 8px 32px rgba(0,0,0,.1);
    }
    .float-card .icon { font-size: 22px; }
    .float-card strong { font-weight: 600; display: block; font-size: 14px; }
    .float-card span { color: var(--muted); font-size: 12px; }

    .fc-1 { top: 18%; left: 5%; animation: float 6s ease-in-out infinite; }
    .fc-2 { top: 30%; right: 5%; animation: float 8s ease-in-out infinite reverse; }
    .fc-3 { bottom: 22%; left: 8%; animation: float 7s ease-in-out infinite 1s; }

    @keyframes float { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-12px)} }

    /* ─── SECTION COMMON ─── */
    section { padding: 96px 24px; }
    .section-inner { max-width: 1200px; margin: 0 auto; }

    .section-label {
      font-size: 12px; font-weight: 700;
      letter-spacing: .12em; text-transform: uppercase;
      color: var(--teal);
      margin-bottom: 14px;
      display: flex; align-items: center; gap: 8px;
    }
    .section-label::before { content: ''; display: block; width: 24px; height: 2px; background: var(--teal); }

    .section-title {
      font-family: 'Syne', sans-serif;
      font-size: clamp(28px, 4vw, 44px);
      font-weight: 800;
      line-height: 1.1;
      letter-spacing: -.02em;
    }
    .section-sub { font-size: 16px; color: var(--muted); margin-top: 12px; line-height: 1.7; }

    /* ─── FILTER / HARGA ─── */
    .filters-section { background: var(--navy2); }

    .filter-grid {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr 1fr;
      gap: 16px;
      margin-top: 48px;
    }

    .filter-card {
      background: var(--card-bg);
      border: 1px solid rgba(0,0,0,.08);
      border-radius: var(--r);
      padding: 24px;
      cursor: pointer;
      transition: border-color .25s, transform .2s, box-shadow .25s;
      position: relative; overflow: hidden;
    }
    .filter-card::before {
      content: '';
      position: absolute; inset: 0;
      background: linear-gradient(135deg, rgba(232,67,13,.05), transparent);
      opacity: 0; transition: opacity .3s;
    }
    .filter-card:hover::before { opacity: 1; }
    .filter-card:hover { border-color: var(--coral); transform: translateY(-4px); box-shadow: 0 16px 40px rgba(255,92,71,.15); }
    .filter-card.active { border-color: var(--coral); }

    .filter-icon {
      width: 48px; height: 48px; border-radius: 12px;
      display: flex; align-items: center; justify-content: center;
      font-size: 22px; margin-bottom: 16px;
    }
    .fc-coral { background: rgba(232,67,13,.12); }
    .fc-teal  { background: rgba(0,143,120,.12); }
    .fc-yellow{ background: rgba(212,141,0,.12); }
    .fc-blue  { background: rgba(56,132,220,.12); }

    .filter-card h3 { font-family: 'Syne', sans-serif; font-size: 16px; font-weight: 700; }
    .filter-card .price { color: var(--coral); font-weight: 700; margin-top: 4px; font-size: 14px; }
    .filter-card .desc { color: var(--muted); font-size: 13px; margin-top: 8px; line-height: 1.5; }

    .facilities {
      display: flex; flex-wrap: wrap; gap: 6px; margin-top: 14px;
    }
    .tag {
      background: rgba(0,0,0,.05);
      border: 1px solid rgba(0,0,0,.1);
      border-radius: 100px;
      padding: 3px 10px;
      font-size: 11px; color: var(--muted);
    }
    .tag.teal { background: rgba(0,143,120,.08); border-color: rgba(0,143,120,.25); color: var(--teal); }

    /* ─── KOST CARDS ─── */
    .kost-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 24px;
      margin-top: 48px;
    }

    .kost-card {
      background: var(--card-bg);
      border: 1px solid rgba(0,0,0,.08);
      border-radius: var(--r);
      overflow: hidden;
      transition: transform .25s, box-shadow .25s, border-color .25s;
      position: relative;
    }
    .kost-card:hover { transform: translateY(-6px); box-shadow: 0 24px 60px rgba(0,0,0,.15); border-color: rgba(0,0,0,.2); }

    .kost-img {
      width: 100%; aspect-ratio: 16/10;
      object-fit: cover;
      background: linear-gradient(135deg, #dce8f5, #c5d8ee);
      display: flex; align-items: center; justify-content: center;
      font-size: 60px; position: relative;
    }

    .kost-badge {
      position: absolute; top: 12px; left: 12px;
      background: var(--coral);
      color: white; font-size: 11px; font-weight: 700;
      padding: 4px 10px; border-radius: 100px;
      letter-spacing: .04em;
    }
    .kost-badge.teal { background: var(--teal); color: var(--navy); }

    .fav-btn {
      position: absolute; top: 12px; right: 12px;
      width: 34px; height: 34px; border-radius: 50%;
      background: rgba(255,255,255,.85);
      border: 1px solid rgba(0,0,0,.12);
      display: flex; align-items: center; justify-content: center;
      font-size: 16px; cursor: pointer;
      transition: background .2s, transform .15s;
      backdrop-filter: blur(8px);
    }
    .fav-btn:hover { background: rgba(232,67,13,.15); transform: scale(1.15); }
    .fav-btn.active { background: rgba(232,67,13,.2); }

    .kost-body { padding: 20px 20px 16px; }
    .kost-name {
      font-family: 'Syne', sans-serif;
      font-size: 17px; font-weight: 700;
    }
    .kost-loc { color: var(--muted); font-size: 13px; margin-top: 4px; display: flex; align-items: center; gap: 4px; }
    .kost-price {
      margin-top: 14px;
      font-family: 'Syne', sans-serif;
      font-size: 20px; font-weight: 800;
      color: var(--coral);
    }
    .kost-price span { font-size: 13px; font-family: 'DM Sans'; font-weight: 400; color: var(--muted); }

    .kost-facs { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 12px; }

    .kost-footer {
      display: flex; align-items: center; justify-content: space-between;
      border-top: 1px solid rgba(0,0,0,.07);
      padding: 14px 20px;
    }
    .rating { display: flex; align-items: center; gap: 5px; font-size: 13px; }
    .stars { color: #D48D00; letter-spacing: -1px; }
    .rating .count { color: var(--muted); font-size: 12px; }

    .detail-btn {
      background: rgba(232,67,13,.08);
      border: 1px solid rgba(232,67,13,.25);
      color: var(--coral);
      border-radius: 100px;
      padding: 7px 18px;
      font-size: 13px; font-weight: 600;
      cursor: pointer;
      transition: background .2s, transform .15s;
    }
    .detail-btn:hover { background: var(--coral); color: white; transform: scale(1.03); }

    /* ─── FAVORIT ─── */
    .fav-section { background: var(--navy2); }

    .fav-header {
      display: flex; align-items: flex-end; justify-content: space-between;
      flex-wrap: wrap; gap: 16px;
    }

    .fav-empty {
      text-align: center; padding: 80px 24px;
      color: var(--muted);
      border: 2px dashed rgba(0,0,0,.12);
      border-radius: 20px; margin-top: 48px;
    }
    .fav-empty .icon { font-size: 56px; margin-bottom: 16px; }
    .fav-empty p { font-size: 15px; }

    #fav-grid { margin-top: 48px; }

    /* ─── FITUR ─── */
    .features-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
      margin-top: 64px;
    }

    .feat-card {
      padding: 32px 28px;
      background: var(--card-bg);
      border: 1px solid rgba(0,0,0,.08);
      border-radius: var(--r);
      position: relative; overflow: hidden;
      transition: transform .25s;
    }
    .feat-card:hover { transform: translateY(-4px); }
    .feat-card::after {
      content: ''; position: absolute;
      bottom: 0; left: 0; right: 0; height: 3px;
      background: linear-gradient(90deg, var(--coral), var(--teal));
      transform: scaleX(0); transform-origin: left;
      transition: transform .4s ease;
    }
    .feat-card:hover::after { transform: scaleX(1); }

    .feat-num {
      font-family: 'Syne', sans-serif;
      font-size: 56px; font-weight: 800;
      color: rgba(0,0,0,.06);
      line-height: 1; margin-bottom: 16px;
    }
    .feat-icon { font-size: 32px; margin-bottom: 14px; }
    .feat-card h3 { font-family: 'Syne', sans-serif; font-size: 18px; font-weight: 700; margin-bottom: 10px; }
    .feat-card p { color: var(--muted); font-size: 14px; line-height: 1.7; }

    /* ─── CTA ─── */
    .cta-section {
      background: linear-gradient(135deg, #fde8e4, #eaf5f3, #f5f7fa);
      text-align: center;
    }
    .cta-inner { max-width: 680px; margin: 0 auto; }
    .cta-inner h2 {
      font-family: 'Syne', sans-serif;
      font-size: clamp(32px, 5vw, 56px);
      font-weight: 800; line-height: 1.1;
      letter-spacing: -.02em;
    }
    .cta-inner p { color: var(--muted); font-size: 17px; margin-top: 16px; line-height: 1.7; }

    .cta-btns { display: flex; gap: 16px; justify-content: center; margin-top: 40px; flex-wrap: wrap; }
    .btn-primary {
      background: var(--coral);
      color: white; border: none; cursor: pointer;
      font-family: 'Syne', sans-serif;
      font-size: 16px; font-weight: 700;
      padding: 16px 36px; border-radius: 100px;
      transition: background .2s, transform .15s;
    }
    .btn-primary:hover { background: var(--coral2); transform: scale(1.04); }
    .btn-outline {
      background: transparent;
      color: var(--white); border: 2px solid rgba(0,0,0,.2); cursor: pointer;
      font-family: 'Syne', sans-serif;
      font-size: 16px; font-weight: 700;
      padding: 16px 36px; border-radius: 100px;
      transition: border-color .2s, transform .15s;
    }
    .btn-outline:hover { border-color: rgba(0,0,0,.5); transform: scale(1.04); }

    /* ─── FOOTER ─── */
    footer {
      padding: 48px 24px;
      border-top: 1px solid rgba(0,0,0,.08);
      display: flex; align-items: center; justify-content: space-between;
      flex-wrap: wrap; gap: 16px;
      max-width: 1200px; margin: 0 auto;
    }
    footer .logo { font-size: 18px; }
    footer p { color: var(--muted); font-size: 13px; }
    footer .socials { display: flex; gap: 12px; }
    footer .socials a {
      width: 36px; height: 36px; border-radius: 50%;
      background: rgba(0,0,0,.05); border: 1px solid rgba(0,0,0,.1);
      display: flex; align-items: center; justify-content: center;
      color: var(--muted); text-decoration: none; font-size: 14px;
      transition: background .2s, color .2s;
    }
    footer .socials a:hover { background: var(--coral); color: white; }

    /* ─── ANIMATIONS ─── */
    @keyframes fadeDown {
      from { opacity: 0; transform: translateY(-20px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(20px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .reveal {
      opacity: 0; transform: translateY(30px);
      transition: opacity .6s ease, transform .6s ease;
    }
    .reveal.visible { opacity: 1; transform: translateY(0); }

    /* ─── RESPONSIVE ─── */
    @media (max-width: 900px) {
      nav { padding: 16px 24px; }
      nav ul { display: none; }
      .filter-grid { grid-template-columns: 1fr 1fr; }
      .features-grid { grid-template-columns: 1fr 1fr; }
      .fc-1, .fc-2, .fc-3 { display: none; }
      .hero-stats { gap: 28px; }
    }
    @media (max-width: 600px) {
      .filter-grid { grid-template-columns: 1fr; }
      .features-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>

<!-- NAV -->
<nav>
  <div class="logo"><img src="{{ asset('storage/images/logo-kostFinder.png') }}" alt="KostFinder" style="height:32px;border-radius:8px;object-fit:contain;"> Kost<span class="dot">Finder</span></div>
  <ul>
    <li><a href="#filter">Filter Pintar</a></li>
    <li><a href="#kost">Cari Kost</a></li>
    <li><a href="#favorit">Favorit</a></li>
    <li><a href="#fitur">Fitur</a></li>
    <li><a href="/login" class="nav-cta">Login</a></li>
  </ul>
</nav>

<!-- HERO -->
<section class="hero">
  <div class="blob blob-1"></div>
  <div class="blob blob-2"></div>
  <div class="blob blob-3"></div>

  <!-- floating cards -->
  <div class="float-card fc-1">
    <span class="icon">⚡</span>
    <div>
      <strong>Verified Kost</strong>
      <span>Sudah diverifikasi</span>
    </div>
  </div>
  <div class="float-card fc-2">
    <span class="icon">💰</span>
    <div>
      <strong>Harga Transparan</strong>
      <span>No hidden fee</span>
    </div>
  </div>
  <div class="float-card fc-3">
    <span class="icon">📍</span>
    <div>
      <strong>2.400+ Kost</strong>
      <span>Di seluruh Indonesia</span>
    </div>
  </div>

  <div class="hero-badge">
    <span class="pulse"></span>
    Platform No. 1 Pencari Kost Indonesia
  </div>

  <h1>
    Temukan Kost<br>
    <span class="accent">Sesuai Budget</span> &<br>
    <span class="accent2">Fasilitas</span> Impianmu
  </h1>

  <p>Bandingkan harga, cek fasilitas, dan booking kost favoritmu — semua dalam satu platform yang cepat dan mudah.</p>

  <div class="search-box">
    <span>📍</span>
    <input type="text" placeholder="Cari kost di Jember, Surabaya, Malang..."/>
    <button class="search-btn" onclick="scrollToKost()">Cari Kost →</button>
  </div>

  <div class="hero-stats">
    <div class="stat">
      <div class="num">2.4<span>K+</span></div>
      <div class="label">Kost Tersedia</div>
    </div>
    <div class="stat">
      <div class="num">18<span>K+</span></div>
      <div class="label">Pengguna Aktif</div>
    </div>
    <div class="stat">
      <div class="num">98<span>%</span></div>
      <div class="label">Kepuasan User</div>
    </div>
  </div>
</section>

<!-- FILTER HARGA -->
<section class="filters-section" id="filter">
  <div class="section-inner">
    <div class="reveal">
      <div class="section-label">Filter Pintar</div>
      <h2 class="section-title">Pilih Sesuai <span style="color:var(--coral)">Budget</span> Kamu</h2>
      <p class="section-sub">Temukan kost terbaik di rentang harga yang kamu punya, lengkap dengan fasilitas yang sesuai.</p>
    </div>

    <div class="filter-grid reveal">
      <div class="filter-card" onclick="filterKost('ekonomis')">
        <div class="filter-icon fc-coral">💼</div>
        <h3>Ekonomis</h3>
        <div class="price">Rp 300K – 600K/bln</div>
        <div class="desc">Cocok untuk mahasiswa dan pekerja dengan budget terbatas.</div>
        <div class="facilities">
          <span class="tag">WiFi</span>
          <span class="tag">Kamar Mandi Bersama</span>
          <span class="tag">Parkir Motor</span>
        </div>
      </div>
      <div class="filter-card" onclick="filterKost('standar')">
        <div class="filter-icon fc-teal">🏡</div>
        <h3>Standar</h3>
        <div class="price">Rp 600K – 1.2Jt/bln</div>
        <div class="desc">Fasilitas lebih lengkap, kenyamanan lebih terjamin.</div>
        <div class="facilities">
          <span class="tag teal">WiFi</span>
          <span class="tag teal">KM Dalam</span>
          <span class="tag">AC</span>
          <span class="tag">Laundry</span>
        </div>
      </div>
      <div class="filter-card" onclick="filterKost('premium')">
        <div class="filter-icon fc-yellow">⭐</div>
        <h3>Premium</h3>
        <div class="price">Rp 1.2Jt – 2.5Jt/bln</div>
        <div class="desc">Fasilitas hotel dengan harga kost. Nyaman & eksklusif.</div>
        <div class="facilities">
          <span class="tag">AC</span>
          <span class="tag">TV</span>
          <span class="tag">Kulkas</span>
          <span class="tag">Security</span>
          <span class="tag">Gym</span>
        </div>
      </div>
      <div class="filter-card" onclick="filterKost('all')">
        <div class="filter-icon fc-blue">🔍</div>
        <h3>Semua Kost</h3>
        <div class="price">Tampilkan Semua</div>
        <div class="desc">Jelajahi semua pilihan kost tersedia tanpa filter harga.</div>
        <div class="facilities">
          <span class="tag teal">All Filter</span>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- KOST LISTING -->
<section id="kost">
  <div class="section-inner">
    <div class="reveal fav-header">
      <div>
        <div class="section-label">Listing Terbaru</div>
        <h2 class="section-title">Kost <span style="color:var(--coral)">Pilihan</span></h2>
      </div>
      <p id="filter-label" style="color:var(--muted);font-size:14px;align-self:flex-end;">Menampilkan semua kost</p>
    </div>

    <div class="kost-grid reveal" id="kost-grid">
      <!-- generated by JS -->
    </div>
  </div>
</section>

<!-- FAVORIT -->
<section class="fav-section" id="favorit">
  <div class="section-inner">
    <div class="reveal fav-header">
      <div>
        <div class="section-label">Koleksi Kamu</div>
        <h2 class="section-title">Kost <span style="color:var(--yellow)">Favorit</span> ❤️</h2>
      </div>
      <button class="btn-outline" id="clear-fav" onclick="clearFav()" style="padding:10px 20px;font-size:13px;display:none;">Hapus Semua</button>
    </div>

    <div id="fav-content">
      <div class="fav-empty reveal">
        <div class="icon">💔</div>
        <p>Belum ada kost favorit.<br>Klik ikon ❤️ pada kost untuk menyimpannya di sini!</p>
      </div>
    </div>
  </div>
</section>

<!-- FITUR -->
<section id="fitur">
  <div class="section-inner">
    <div class="reveal" style="text-align:center;max-width:560px;margin:0 auto 0">
      <div class="section-label" style="justify-content:center">Kenapa KostFinder?</div>
      <h2 class="section-title">Fitur yang <span style="color:var(--teal)">Memudahkan</span> Hidupmu</h2>
    </div>

    <div class="features-grid reveal">
      <div class="feat-card">
        <div class="feat-num">01</div>
        <div class="feat-icon">🔍</div>
        <h3>Pencarian Cerdas</h3>
        <p>Filter berdasarkan harga, fasilitas, lokasi, dan jarak dari kampus atau kantor kamu.</p>
      </div>
      <div class="feat-card">
        <div class="feat-num">02</div>
        <div class="feat-icon">❤️</div>
        <h3>Simpan Favorit</h3>
        <p>Bookmark kost yang kamu suka, bandingkan, dan putuskan mana yang terbaik buatmu.</p>
      </div>
      <div class="feat-card">
        <div class="feat-num">03</div>
        <div class="feat-icon">✅</div>
        <h3>Verifikasi Kost</h3>
        <p>Semua kost sudah diverifikasi. Foto asli, harga jujur, deskripsi akurat.</p>
      </div>
      <div class="feat-card">
        <div class="feat-num">04</div>
        <div class="feat-icon">💬</div>
        <h3>Chat Langsung</h3>
        <p>Hubungi pemilik kost langsung dari platform. No ribet, no muter-muter.</p>
      </div>
      <div class="feat-card">
        <div class="feat-num">05</div>
        <div class="feat-icon">📊</div>
        <h3>Perbandingan Harga</h3>
        <p>Bandingkan hingga 4 kost sekaligus berdasarkan harga dan fasilitas yang ditawarkan.</p>
      </div>
      <div class="feat-card">
        <div class="feat-num">06</div>
        <div class="feat-icon">🔔</div>
        <h3>Notifikasi Kamar</h3>
        <p>Dapatkan notifikasi saat ada kamar baru yang sesuai kriteria pencarianmu.</p>
      </div>
    </div>
  </div>
</section>

<!-- CTA -->
<section class="cta-section">
  <div class="section-inner">
    <div class="cta-inner reveal">
      <h2>Siap Temukan Kost <span style="color:var(--coral)">Impianmu?</span></h2>
      <p>Ribuan kost tersedia, menunggu kamu temukan. Gratis, mudah, dan terpercaya.</p>
      <div class="cta-btns">
        <button class="btn-primary" onclick="scrollToKost()">🔍 Cari Kost Sekarang</button>
        <button class="btn-outline">📋 Daftarkan Kost Kamu</button>
      </div>
    </div>
  </div>
</section>

<!-- FOOTER -->
<footer>
  <div class="logo"><img src="{{ asset('storage/images/logo-kostFinder.png') }}" alt="KostFinder" style="height:26px;border-radius:6px;object-fit:contain;"> Kost<span class="dot">Finder</span></div>
  <p>© 2025 KostFinder. Dibuat dengan ❤️ di Indonesia.</p>
  <div class="socials">
    <a href="#">𝕏</a>
    <a href="#">in</a>
    <a href="#">ig</a>
  </div>
</footer>

<script>
  // ─── DATA ───
  const kostData = [
    { id: 1, name: 'Kost Melati Putih', loc: 'Jember Kota, Jember', price: 450000, tier: 'ekonomis', emoji: '🌸', rating: 4.2, reviews: 24, facs: ['WiFi', 'Air Panas', 'Parkir'], badge: 'Tersedia' },
    { id: 2, name: 'Kost Griya Asri', loc: 'Sumbersari, Jember', price: 750000, tier: 'standar', emoji: '🏡', rating: 4.6, reviews: 38, facs: ['WiFi', 'AC', 'KM Dalam', 'Laundry'], badge: 'Populer', badgeTeal: true },
    { id: 3, name: 'Kost Residence 88', loc: 'Patrang, Jember', price: 1500000, tier: 'premium', emoji: '🏢', rating: 4.9, reviews: 61, facs: ['WiFi', 'AC', 'TV', 'Gym', 'Kulkas'], badge: 'Premium' },
    { id: 4, name: 'Kost Barokah', loc: 'Kaliwates, Jember', price: 380000, tier: 'ekonomis', emoji: '🌿', rating: 4.0, reviews: 15, facs: ['WiFi', 'Parkir', 'Keamanan'], badge: 'Tersedia' },
    { id: 5, name: 'Kost Bintang Mas', loc: 'Tegalboto, Jember', price: 950000, tier: 'standar', emoji: '⭐', rating: 4.5, reviews: 47, facs: ['WiFi', 'AC', 'Dapur', 'KM Dalam'], badge: 'Baru', badgeTeal: true },
    { id: 6, name: 'Kost Villa Elok', loc: 'Mangli, Jember', price: 2200000, tier: 'premium', emoji: '🏰', rating: 5.0, reviews: 29, facs: ['WiFi', 'AC', 'Kolam Renang', 'Parkir Mobil', 'Cleaning'], badge: 'Eksklusif' },
  ];

  let favorites = JSON.parse(localStorage.getItem('kf-favs') || '[]');
  let currentFilter = 'all';

  // ─── RENDER KOST ───
  function renderKost(data) {
    const grid = document.getElementById('kost-grid');
    if (!data.length) {
      grid.innerHTML = '<p style="color:var(--muted);grid-column:1/-1;text-align:center;padding:40px">Tidak ada kost ditemukan untuk filter ini.</p>';
      return;
    }
    grid.innerHTML = data.map(k => `
      <div class="kost-card reveal" id="kost-${k.id}">
        <div class="kost-img">
          ${k.emoji}
          <span class="kost-badge ${k.badgeTeal ? 'teal' : ''}">${k.badge}</span>
          <button class="fav-btn ${favorites.includes(k.id) ? 'active' : ''}" onclick="toggleFav(${k.id})" title="Tambah Favorit">
            ${favorites.includes(k.id) ? '❤️' : '🤍'}
          </button>
        </div>
        <div class="kost-body">
          <div class="kost-name">${k.name}</div>
          <div class="kost-loc">📍 ${k.loc}</div>
          <div class="kost-price">Rp ${k.price.toLocaleString('id-ID')}<span>/bulan</span></div>
          <div class="kost-facs">${k.facs.map(f => `<span class="tag">${f}</span>`).join('')}</div>
        </div>
        <div class="kost-footer">
          <div class="rating">
            <span class="stars">${'★'.repeat(Math.floor(k.rating))}${'☆'.repeat(5 - Math.floor(k.rating))}</span>
            <strong>${k.rating}</strong>
            <span class="count">(${k.reviews})</span>
          </div>
          <button class="detail-btn">Lihat Detail</button>
        </div>
      </div>
    `).join('');
    observeReveal();
  }

  // ─── FILTER ───
  function filterKost(tier) {
    currentFilter = tier;
    const data = tier === 'all' ? kostData : kostData.filter(k => k.tier === tier);
    const labels = { all: 'Menampilkan semua kost', ekonomis: 'Budget Ekonomis (Rp 300K–600K)', standar: 'Budget Standar (Rp 600K–1.2Jt)', premium: 'Budget Premium (Rp 1.2Jt–2.5Jt)' };
    document.getElementById('filter-label').textContent = labels[tier];
    renderKost(data);
    document.getElementById('kost').scrollIntoView({ behavior: 'smooth' });
  }

  // ─── FAV ───
  function toggleFav(id) {
    if (favorites.includes(id)) {
      favorites = favorites.filter(f => f !== id);
    } else {
      favorites.push(id);
    }
    localStorage.setItem('kf-favs', JSON.stringify(favorites));
    // update buttons
    document.querySelectorAll('.fav-btn').forEach(btn => {
      const bid = parseInt(btn.getAttribute('onclick').replace('toggleFav(', '').replace(')', ''));
      btn.classList.toggle('active', favorites.includes(bid));
      btn.textContent = favorites.includes(bid) ? '❤️' : '🤍';
    });
    renderFav();
  }

  function renderFav() {
    const container = document.getElementById('fav-content');
    const clearBtn = document.getElementById('clear-fav');
    if (!favorites.length) {
      clearBtn.style.display = 'none';
      container.innerHTML = `
        <div class="fav-empty reveal">
          <div class="icon">💔</div>
          <p>Belum ada kost favorit.<br>Klik ikon ❤️ pada kost untuk menyimpannya di sini!</p>
        </div>`;
      observeReveal();
      return;
    }
    clearBtn.style.display = '';
    const data = kostData.filter(k => favorites.includes(k.id));
    container.innerHTML = `<div class="kost-grid" id="fav-grid">${data.map(k => `
      <div class="kost-card reveal">
        <div class="kost-img">
          ${k.emoji}
          <span class="kost-badge ${k.badgeTeal ? 'teal' : ''}">${k.badge}</span>
          <button class="fav-btn active" onclick="toggleFav(${k.id})">❤️</button>
        </div>
        <div class="kost-body">
          <div class="kost-name">${k.name}</div>
          <div class="kost-loc">📍 ${k.loc}</div>
          <div class="kost-price">Rp ${k.price.toLocaleString('id-ID')}<span>/bulan</span></div>
          <div class="kost-facs">${k.facs.map(f => `<span class="tag">${f}</span>`).join('')}</div>
        </div>
        <div class="kost-footer">
          <div class="rating">
            <span class="stars">${'★'.repeat(Math.floor(k.rating))}${'☆'.repeat(5 - Math.floor(k.rating))}</span>
            <strong>${k.rating}</strong>
            <span class="count">(${k.reviews})</span>
          </div>
          <button class="detail-btn">Lihat Detail</button>
        </div>
      </div>
    `).join('')}</div>`;
    observeReveal();
  }

  function clearFav() {
    favorites = [];
    localStorage.setItem('kf-favs', JSON.stringify(favorites));
    document.querySelectorAll('.fav-btn').forEach(btn => { btn.classList.remove('active'); btn.textContent = '🤍'; });
    renderFav();
  }

  // ─── SCROLL REVEAL ───
  function observeReveal() {
    const els = document.querySelectorAll('.reveal:not(.visible)');
    const obs = new IntersectionObserver((entries) => {
      entries.forEach((e, i) => {
        if (e.isIntersecting) {
          setTimeout(() => e.target.classList.add('visible'), i * 80);
          obs.unobserve(e.target);
        }
      });
    }, { threshold: 0.1 });
    els.forEach(el => obs.observe(el));
  }

  function scrollToKost() {
    document.getElementById('kost').scrollIntoView({ behavior: 'smooth' });
  }

  // ─── INIT ───
  renderKost(kostData);
  renderFav();
  observeReveal();
</script>
</body>
</html>
