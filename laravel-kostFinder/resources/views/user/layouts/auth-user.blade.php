<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="csrf-token" content="{{ csrf_token() }}" />
    <title>@yield('title', 'KostFinder') — KostFinder</title>

    {{-- Google Fonts --}}
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link
        href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;0,600;1,400&display=swap"
        rel="stylesheet" />

    <style>
        /* ═══════════════════════════════════════════════════
       CSS VARIABLES — konsisten dengan admin dashboard
    ═══════════════════════════════════════════════════ */
        :root {
            --coral: #E8430D;
            --coral2: #FF6B3D;
            --coral-bg: rgba(232, 67, 13, .08);
            --teal: #008F78;
            --teal-bg: rgba(0, 143, 120, .08);
            --yellow: #D48D00;
            --yellow-bg: rgba(212, 141, 0, .08);
            --blue: #2563EB;
            --blue-bg: rgba(37, 99, 235, .08);

            --bg: #F7F6F3;
            --bg2: #EEEDE9;
            --card: #FFFFFF;
            --text: #1A1814;
            --muted: #8A8680;
            --border: #E2E0DB;
            --shadow: 0 1px 3px rgba(0, 0, 0, .06);
            --shadow-md: 0 4px 16px rgba(0, 0, 0, .08);
            --shadow-lg: 0 8px 32px rgba(0, 0, 0, .12);
            --r: 14px;
            --sidebar-w: 240px;
            --sidebar-col: 64px;
            --topbar-h: 64px;
        }

        body.dark {
            --bg: #0f1923;
            --bg2: #172130;
            --card: #1c2b3a;
            --muted: #7a94ab;
            --text: #e8f2ff;
            --text2: #a8bdd0;
            --border: rgba(255, 255, 255, 0.08);
            --shadow: 0 2px 12px rgba(0, 0, 0, 0.3);
            --shadow-md: 0 8px 28px rgba(0, 0, 0, 0.4);
            --coral-bg: rgba(232, 67, 13, 0.15);
            --teal-bg: rgba(0, 143, 120, 0.15);
            --yellow-bg: rgba(212, 141, 0, 0.15);
            --blue-bg: rgba(37, 99, 235, 0.15);
        }

        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            font-size: 14px;
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            transition: background 0.35s, color 0.35s;
        }

        /* ── SIDEBAR (sama persis dengan admin) ────────────────────── */
        .sidebar {
            width: var(--sidebar-w);
            background: var(--card);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            left: 0;
            bottom: 0;
            z-index: 200;
            overflow: hidden;
            transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1), transform 0.3s ease, background 0.35s;
        }
        .sidebar-logo {
            height: var(--topbar-h);
            min-height: var(--topbar-h);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 14px;
            gap: 10px;
            flex-shrink: 0;
        }
        .logo-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--coral), var(--coral2));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            box-shadow: 0 4px 12px rgba(232,67,13,.28);
            flex-shrink: 0;
        }
        .wordmark {
            font-family: 'Syne', sans-serif;
            font-size: 15px;
            font-weight: 800;
            color: var(--text);
            white-space: nowrap;
            overflow: hidden;
            transition: opacity 0.2s, max-width 0.3s;
            max-width: 140px;
        }
        .wordmark span { color: var(--coral); }
        .sidebar-nav {
            flex: 1;
            padding: 16px 12px;
            overflow-y: auto;
            overflow-x: hidden;
        }
        .nav-section-label {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--muted);
            opacity: .6;
            padding: 0 12px;
            margin: 4px 0 8px;
            white-space: nowrap;
            overflow: hidden;
            transition: opacity 0.2s;
        }
        .nav-item {
            display: flex;
            align-items: center;
            text-decoration: none;
            gap: 12px;
            padding: 11px 14px;
            border-radius: 10px;
            cursor: pointer;
            color: var(--muted);
            font-size: 14px;
            font-weight: 500;
            transition: background 0.2s, color 0.2s;
            white-space: nowrap;
            position: relative;
            margin-bottom: 2px;
        }
        .nav-label { flex: 1; overflow: hidden; transition: opacity 0.2s, max-width 0.3s; max-width: 130px; }
        .nav-tooltip {
            position: absolute;
            left: calc(var(--sidebar-col) + 10px);
            top: 50%;
            transform: translateY(-50%);
            background: var(--text);
            color: var(--card);
            font-size: 12px;
            font-weight: 600;
            padding: 5px 11px;
            border-radius: 8px;
            pointer-events: none;
            opacity: 0;
            white-space: nowrap;
            transition: opacity 0.15s;
            z-index: 300;
        }
        .nav-item:hover { background: var(--bg); color: var(--text); }
        .nav-item.active { background: var(--coral-bg); color: var(--coral); font-weight: 700; }
        .nav-icon { font-size: 18px; width: 22px; text-align: center; flex-shrink: 0; }
        .sidebar-footer { padding: 12px; border-top: 1px solid var(--border); }
        .user-chip {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            border-radius: 10px;
            cursor: default;
            transition: background 0.2s;
        }
        .user-chip:hover { background: var(--bg); }
        .user-avatar {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--coral), var(--coral2));
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Syne', sans-serif;
            font-size: 13px;
            font-weight: 700;
            color: white;
            flex-shrink: 0;
        }
        .user-info { flex: 1; min-width: 0; overflow: hidden; transition: opacity 0.2s, max-width 0.3s; max-width: 140px; }
        .user-info strong { display: block; font-size: 13px; font-weight: 700; color: var(--text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .user-info span { font-size: 11px; color: var(--muted); }
        .logout-btn {
            margin-left: auto;
            flex-shrink: 0;
            width: 30px;
            height: 30px;
            border-radius: 8px;
            background: transparent;
            border: 1.5px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 15px;
            color: var(--muted);
            transition: background 0.2s, color 0.2s, border-color 0.2s;
        }
        .logout-btn:hover { background: rgba(229,62,62,.1); color: #e53e3e; border-color: rgba(229,62,62,.3); }
        .collapse-btn {
            flex-shrink: 0;
            width: 34px;
            height: 34px;
            border-radius: 9px;
            background: var(--bg2);
            border: 1.5px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 16px;
            color: var(--muted);
            transition: background .2s, color .2s, transform .3s;
        }
        .collapse-btn:hover { background: var(--coral-bg); color: var(--coral); }
        .sidebar-toggle {
            display: none;
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: var(--card);
            border: 1.5px solid var(--border);
            align-items: center;
            justify-content: center;
            font-size: 18px;
            cursor: pointer;
        }

        /* ── MAIN AREA ──────────────────────────────── */
        .u-main {
            flex: 1;
            margin-left: var(--sidebar-w);
            display: flex;
            flex-direction: column;
            min-width: 0;
            overflow-x: hidden;
            transition: margin-left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .u-topbar {
            height: var(--topbar-h);
            background: var(--card);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 28px 0 20px;
            gap: 12px;
            position: sticky;
            top: 0;
            z-index: 100;
            transition: background 0.35s;
        }
        .topbar-title {
            font-family: 'Syne', sans-serif;
            font-size: 18px;
            font-weight: 800;
            letter-spacing: -.01em;
            flex: 1;
        }
        .topbar-actions { display: flex; align-items: center; gap: 10px; }
        .icon-btn {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: var(--card);
            border: 1.5px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
            cursor: pointer;
            transition: border-color .2s, box-shadow .2s;
        }
        .icon-btn:hover { border-color: rgba(26,42,58,.2); box-shadow: var(--shadow); }

        .u-content {
            flex: 1;
            padding: 28px 32px;
            max-width: 1200px;
            width: 100%;
            margin: 0 auto;
        }

        /* Collapsed sidebar */
        body.collapsed .sidebar { width: var(--sidebar-col); }
        body.collapsed .wordmark { opacity: 0; max-width: 0; pointer-events: none; }
        body.collapsed .nav-label { opacity: 0; max-width: 0; }
        body.collapsed .nav-section-label { opacity: 0; }
        body.collapsed .user-info { opacity: 0; max-width: 0; }
        body.collapsed #collapse-btn { transform: rotate(180deg); }
        body.collapsed .u-main { margin-left: var(--sidebar-col); }
        body.collapsed .nav-item:hover .nav-tooltip { opacity: 1; }

        /* ── KOMPONEN UMUM ──────────────────────────── */
        .page-header {
            margin-bottom: 24px;
        }

        .page-header h2 {
            font-family: 'Syne', sans-serif;
            font-size: 22px;
            font-weight: 800;
        }

        .page-header h2 em {
            color: var(--coral);
            font-style: normal;
        }

        .page-header p {
            color: var(--muted);
            font-size: 13px;
            margin-top: 4px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--r);
            padding: 18px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            box-shadow: var(--shadow);
        }

        .stat-card.coral {
            border-left: 3px solid var(--coral);
        }

        .stat-card.teal {
            border-left: 3px solid var(--teal);
        }

        .stat-card.yellow {
            border-left: 3px solid var(--yellow);
        }

        .stat-card.blue {
            border-left: 3px solid var(--blue);
        }

        .stat-icon-wrap {
            font-size: 20px;
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .stat-icon-wrap.coral {
            background: var(--coral-bg);
        }

        .stat-icon-wrap.teal {
            background: var(--teal-bg);
        }

        .stat-icon-wrap.yellow {
            background: var(--yellow-bg);
        }

        .stat-icon-wrap.blue {
            background: var(--blue-bg);
        }

        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 26px;
            font-weight: 800;
            line-height: 1;
        }

        .stat-label {
            font-size: 12px;
            color: var(--muted);
            font-weight: 500;
        }

        .widget {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--r);
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: var(--shadow);
        }

        .section-hd {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .section-hd h3 {
            font-family: 'Syne', sans-serif;
            font-size: 14px;
            font-weight: 700;
        }

        /* Pill badge */
        .pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 10px;
            border-radius: 100px;
            font-size: 11px;
            font-weight: 600;
        }

        .pill.green {
            background: rgba(0, 143, 120, .1);
            color: var(--teal);
        }

        .pill.coral {
            background: var(--coral-bg);
            color: var(--coral);
        }

        .pill.yellow {
            background: var(--yellow-bg);
            color: var(--yellow);
        }

        .pill.blue {
            background: var(--blue-bg);
            color: var(--blue);
        }

        .pill.muted {
            background: var(--bg2);
            color: var(--muted);
        }

        /* Button */
        .btn-sm {
            padding: 8px 14px;
            border-radius: 9px;
            border: 1.5px solid var(--border);
            background: var(--bg);
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all .15s;
            white-space: nowrap;
        }

        .btn-sm:hover {
            background: var(--bg2);
        }

        a.btn-sm {
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }

        .btn-sm.primary {
            background: var(--coral);
            color: white;
            border-color: var(--coral);
        }

        .btn-sm.primary:hover {
            background: #cf3b0b;
        }

        .btn-sm:disabled {
            opacity: .5;
            cursor: not-allowed;
        }

        /* Search input */
        .search-input-sm {
            display: flex;
            align-items: center;
            gap: 8px;
            background: var(--bg);
            border: 1.5px solid var(--border);
            border-radius: 9px;
            padding: 7px 12px;
            transition: border-color .2s;
        }

        .search-input-sm:focus-within {
            border-color: var(--coral);
        }

        .search-input-sm input {
            border: none;
            background: transparent;
            outline: none;
            font-family: 'DM Sans', sans-serif;
            font-size: 13px;
            color: var(--text);
            width: 200px;
        }

        /* Modal */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, .45);
            backdrop-filter: blur(4px);
            z-index: 1000;
            display: none;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.open {
            display: flex;
        }

        .modal-box {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 18px;
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: var(--shadow-lg);
            animation: modalIn .2s ease;
        }

        @keyframes modalIn {
            from {
                opacity: 0;
                transform: scale(.95) translateY(10px);
            }

            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }

        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 22px 16px;
            border-bottom: 1px solid var(--border);
        }

        .modal-header h3 {
            font-family: 'Syne', sans-serif;
            font-size: 16px;
            font-weight: 800;
        }

        .modal-close {
            background: var(--bg2);
            border: none;
            width: 28px;
            height: 28px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            color: var(--muted);
            transition: all .15s;
        }

        .modal-close:hover {
            background: var(--border);
        }

        .modal-body {
            padding: 20px 22px;
        }

        .modal-footer {
            padding: 14px 22px 20px;
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        /* Form elements */
        .mform-group {
            margin-bottom: 14px;
        }

        .mform-group label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: var(--muted);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: .4px;
        }

        .mform-group input,
        .mform-group textarea,
        .mform-group select {
            width: 100%;
            background: var(--bg);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            padding: 10px 13px;
            font-family: 'DM Sans', sans-serif;
            font-size: 13px;
            color: var(--text);
            outline: none;
            transition: border-color .2s, box-shadow .2s;
        }

        .mform-group input:focus,
        .mform-group textarea:focus {
            border-color: var(--coral);
            box-shadow: 0 0 0 3px rgba(232, 67, 13, .09);
        }

        .mform-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        /* Star input */
        .star-input {
            display: flex;
            gap: 4px;
            flex-direction: row-reverse;
            justify-content: flex-end;
        }

        .star-input input {
            display: none;
        }

        .star-input label {
            font-size: 24px;
            cursor: pointer;
            color: var(--bg2);
            transition: color .15s;
        }

        .star-input input:checked~label,
        .star-input label:hover,
        .star-input label:hover~label {
            color: var(--yellow);
        }

        /* Toast */
        .toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 12px 18px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            font-weight: 500;
            box-shadow: var(--shadow-lg);
            z-index: 9999;
            transform: translateY(80px);
            opacity: 0;
            transition: all .3s cubic-bezier(.34, 1.56, .64, 1);
        }

        .toast.show {
            transform: translateY(0);
            opacity: 1;
        }

        /* Form error */
        .form-error-msg {
            background: rgba(229, 62, 62, .08);
            border: 1px solid rgba(229, 62, 62, .2);
            border-radius: 8px;
            padding: 10px 13px;
            font-size: 12px;
            color: #E53E3E;
            margin-top: 4px;
        }

        /* Kost card grid */
        .kost-grid-user {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 16px;
        }

        .kost-card-user {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--r);
            overflow: hidden;
            box-shadow: var(--shadow);
            transition: box-shadow .2s, transform .2s;
            cursor: pointer;
        }

        .kost-card-user:hover {
            box-shadow: var(--shadow-md);
            transform: translateY(-2px);
        }

        .kcu-img {
            height: 160px;
            background: var(--bg2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            overflow: hidden;
            position: relative;
        }

        .kcu-body {
            padding: 14px 16px;
        }

        .kcu-name {
            font-family: 'Syne', sans-serif;
            font-size: 14px;
            font-weight: 800;
            margin-bottom: 4px;
        }

        .kcu-loc {
            font-size: 12px;
            color: var(--muted);
            margin-bottom: 8px;
        }

        .kcu-price {
            font-size: 15px;
            font-weight: 700;
            color: var(--coral);
            font-family: 'Syne', sans-serif;
        }

        .kcu-price span {
            font-size: 11px;
            font-weight: 400;
            color: var(--muted);
        }

        .kcu-footer {
            padding: 10px 16px 14px;
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .kcu-stars {
            color: var(--yellow);
            font-size: 12px;
            letter-spacing: -1px;
        }

        /* Review card */
        .review-card-user {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--r);
            padding: 18px;
            box-shadow: var(--shadow);
        }

        .rcu-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .rcu-kost {
            font-family: 'Syne', sans-serif;
            font-size: 13px;
            font-weight: 700;
        }

        .rcu-rating {
            color: var(--yellow);
            font-size: 14px;
            letter-spacing: -1px;
        }

        .rcu-text {
            font-size: 13px;
            color: var(--text);
            line-height: 1.6;
            margin-bottom: 12px;
        }

        .rcu-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .rcu-date {
            font-size: 11px;
            color: var(--muted);
        }

        .rcu-actions {
            display: flex;
            gap: 6px;
        }

        .act-btn {
            width: 30px;
            height: 30px;
            border-radius: 8px;
            border: 1px solid var(--border);
            background: var(--bg);
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all .15s;
        }

        .act-btn:hover {
            background: var(--bg2);
        }

        /* Fav card */
        .fav-grid-user {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 16px;
        }

        .fav-card-user {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--r);
            overflow: hidden;
            box-shadow: var(--shadow);
        }

        .fcu-img {
            height: 130px;
            background: var(--bg2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            position: relative;
            overflow: hidden;
        }

        .fcu-body {
            padding: 12px 14px;
        }

        .fcu-name {
            font-family: 'Syne', sans-serif;
            font-size: 13px;
            font-weight: 800;
            margin-bottom: 3px;
        }

        .fcu-loc {
            font-size: 11px;
            color: var(--muted);
            margin-bottom: 6px;
        }

        .fcu-price {
            font-size: 14px;
            font-weight: 700;
            color: var(--coral);
        }

        .fcu-footer {
            padding: 8px 14px 12px;
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* CSEL dropdown */
        .csel-wrap {
            position: relative;
        }

        .csel-trigger {
            background: var(--bg);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            padding: 10px 13px;
            cursor: pointer;
            font-size: 13px;
            transition: border-color .2s;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .csel-trigger:hover,
        .csel-trigger.open {
            border-color: var(--coral);
        }

        .csel-trigger::after {
            content: '▾';
            color: var(--muted);
            font-size: 11px;
        }

        .csel-dropdown {
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            right: 0;
            background: var(--card);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            z-index: 200;
            box-shadow: var(--shadow-md);
            display: none;
            max-height: 220px;
            overflow-y: auto;
        }

        .csel-dropdown.open {
            display: block;
        }

        .csel-opt {
            padding: 9px 13px;
            font-size: 13px;
            cursor: pointer;
            transition: background .1s;
        }

        .csel-opt:hover,
        .csel-opt.active {
            background: var(--coral-bg);
            color: var(--coral);
        }

        .csel-search {
            width: 100%;
            border: none;
            border-bottom: 1px solid var(--border);
            padding: 8px 13px;
            font-size: 13px;
            outline: none;
            background: var(--bg);
        }

        .csel-placeholder {
            color: var(--muted);
        }

        .csel-empty {
            padding: 9px 13px;
            font-size: 12px;
            color: var(--muted);
            text-align: center;
        }

        /* Filter dropdown */
        .filter-wrap {
            position: relative;
        }

        .filter-dropdown {
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            background: var(--card);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            z-index: 200;
            box-shadow: var(--shadow-md);
            min-width: 160px;
            display: none;
        }

        .filter-dropdown.open {
            display: block;
        }

        .filter-opt {
            padding: 9px 14px;
            font-size: 13px;
            cursor: pointer;
            transition: background .1s;
        }

        .filter-opt:hover,
        .filter-opt.active {
            background: var(--coral-bg);
            color: var(--coral);
        }

        .filter-sep {
            height: 1px;
            background: var(--border);
            margin: 4px 0;
        }

        /* Responsive */
        @media (max-width: 860px) {
            .sidebar { transform: translateX(-100%); }
            .sidebar.open { transform: translateX(0); }
            .u-main { margin-left: 0; }
            .sidebar-toggle { display: flex; }
            .collapse-btn { display: none; }
        }

        @media (max-width: 768px) {
            .u-content { padding: 16px; }
            .mform-row { grid-template-columns: 1fr; }
            .kost-grid-user { grid-template-columns: 1fr 1fr; }
        }

        @media (max-width: 480px) {
            .kost-grid-user, .fav-grid-user { grid-template-columns: 1fr; }
        }
    </style>
</head>

<body>

    @include('user.components.sidebar-user')

    <div class="u-main">
        @include('user.components.topbar-user')

        <div class="u-content">
            @yield('content')
        </div>
    </div>

    {{-- Toast notifikasi --}}
    <div class="toast" id="toast">
        <span id="toast-icon">✅</span>
        <span id="toast-msg">Berhasil!</span>
    </div>

    {{-- LOGOUT MODAL --}}
    <div id="logout-modal"
        style="display:none;position:fixed;inset:0;z-index:9000;align-items:center;justify-content:center;">
        <div onclick="hideLogoutModal()"
            style="position:absolute;inset:0;background:rgba(0,0,0,.45);backdrop-filter:blur(3px);"></div>
        <div style="position:relative;background:var(--card);border:1px solid var(--border);
            border-radius:18px;padding:32px 28px;width:320px;box-shadow:var(--shadow-lg);text-align:center;animation:modalIn .25s ease both;">
            <div style="width:56px;height:56px;border-radius:16px;background:rgba(229,62,62,.1);
                display:flex;align-items:center;justify-content:center;font-size:26px;margin:0 auto 16px;">⏻</div>
            <h3 style="font-family:'Syne',sans-serif;font-size:18px;font-weight:800;margin-bottom:8px;">Keluar dari Akun?</h3>
            <p style="font-size:13px;color:var(--muted);line-height:1.6;margin-bottom:24px;">
                Anda akan keluar dari dashboard KostFinder.<br>Pastikan semua perubahan sudah tersimpan.
            </p>
            <div style="display:flex;gap:10px;">
                <button onclick="hideLogoutModal()"
                    style="flex:1;padding:11px;border-radius:10px;border:1.5px solid var(--border);background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;font-size:14px;font-weight:600;cursor:pointer;">Batal</button>
                <button onclick="doLogout()" id="btn-logout-confirm"
                    style="flex:1;padding:11px;border-radius:10px;border:none;background:#E53E3E;color:white;font-family:'DM Sans',sans-serif;font-size:14px;font-weight:600;cursor:pointer;box-shadow:0 2px 10px rgba(229,62,62,.3);">Ya, Keluar</button>
            </div>
        </div>
    </div>

    <script>
        /* Fungsi global yang dipakai semua halaman user */
        function openModal(id) {
            const el = document.getElementById(id);
            if (el) { el.style.display = 'flex'; el.classList.add('open'); }
        }
        function closeModal(id) {
            const el = document.getElementById(id);
            if (el) { el.style.display = 'none'; el.classList.remove('open'); }
        }
        function closeModalOutside(event, el) {
            if (event.target === el) closeModal(el.id);
        }
        function showToast(msg, icon = '✅') {
            document.getElementById('toast-msg').textContent = msg;
            document.getElementById('toast-icon').textContent = icon;
            const t = document.getElementById('toast');
            t.classList.add('show');
            setTimeout(() => t.classList.remove('show'), 3200);
        }
        function toggleFilter(id) {
            document.querySelectorAll('.filter-dropdown').forEach(d => {
                if (d.id !== id) d.classList.remove('open');
            });
            document.getElementById(id)?.classList.toggle('open');
        }
        function toggleCsel(id) {
            const wrap = document.getElementById(id);
            const dd = wrap?.querySelector('.csel-dropdown');
            const trig = wrap?.querySelector('.csel-trigger');
            if (!dd) return;
            const isOpen = dd.classList.contains('open');
            document.querySelectorAll('.csel-dropdown.open').forEach(d => {
                d.classList.remove('open');
                d.closest('.csel-wrap')?.querySelector('.csel-trigger')?.classList.remove('open');
            });
            if (!isOpen) { dd.classList.add('open'); trig?.classList.add('open'); }
        }
        function pickCsel(id, el) {
            const wrap = document.getElementById(id);
            if (!wrap) return;
            wrap.querySelector('.csel-val').textContent = el.textContent.trim();
            wrap.querySelector('.csel-val').classList.remove('csel-placeholder');
            wrap.dataset.value = el.dataset.val;
            wrap.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
            el.classList.add('active');
            wrap.querySelector('.csel-dropdown')?.classList.remove('open');
            wrap.querySelector('.csel-trigger')?.classList.remove('open');
        }
        function getCselVal(id) {
            const w = document.getElementById(id);
            return w ? (w.dataset.value || w.querySelector('.csel-val')?.textContent.trim() || '') : '';
        }
        function setCselVal(id, val) {
            const w = document.getElementById(id);
            if (!w) return;
            const opt = [...w.querySelectorAll('.csel-opt')].find(o => o.dataset.val === val || o.textContent.trim().includes(val));
            if (opt) {
                w.querySelector('.csel-val').textContent = opt.textContent.trim();
                w.querySelector('.csel-val').classList.remove('csel-placeholder');
                w.dataset.value = opt.dataset.val;
                w.querySelectorAll('.csel-opt').forEach(o => o.classList.remove('active'));
                opt.classList.add('active');
            }
        }
        function searchCsel(id, q) {
            const wrap = document.getElementById(id);
            if (!wrap) return;
            const query = q.toLowerCase();
            let visible = 0;
            wrap.querySelectorAll('.csel-opt').forEach(o => {
                const match = o.textContent.toLowerCase().includes(query);
                o.style.display = match ? '' : 'none';
                if (match) visible++;
            });
            const empty = wrap.querySelector('.csel-empty');
            if (empty) empty.style.display = visible === 0 ? '' : 'none';
        }
        function formatRupiah(n) {
            return 'Rp ' + Number(n || 0).toLocaleString('id-ID');
        }
        function renderStars(rating) {
            let s = '';
            for (let i = 1; i <= 5; i++) s += i <= rating ? '★' : '☆';
            return s;
        }

        // ── Dark Mode ──────────────────────────────────────────
        function toggleTheme() {
            const isDark = document.body.classList.toggle('dark');
            localStorage.setItem('kf_theme', isDark ? 'dark' : 'light');
            const btn = document.getElementById('theme-toggle');
            if (btn) btn.textContent = isDark ? '☀️' : '🌙';
            showToast(isDark ? 'Mode Gelap aktif' : 'Mode Terang aktif', isDark ? '🌙' : '☀️');
        }

        // ── Collapse sidebar ─────────────────────────────────
        function toggleCollapse() {
            const isCollapsed = document.body.classList.toggle('collapsed');
            localStorage.setItem('kf_sidebar', isCollapsed ? 'collapsed' : '');
        }

        // Restore dark mode + collapsed state dari localStorage
        (function () {
            if (localStorage.getItem('kf_theme') === 'dark') {
                document.body.classList.add('dark');
                document.addEventListener('DOMContentLoaded', () => {
                    const btn = document.getElementById('theme-toggle');
                    if (btn) btn.textContent = '☀️';
                });
            }
            if (localStorage.getItem('kf_sidebar') === 'collapsed') {
                document.body.classList.add('collapsed');
            }
        })();

        // ── Logout ─────────────────────────────────────────────
        function showLogoutModal() {
            const m = document.getElementById('logout-modal');
            if (m) m.style.display = 'flex';
        }
        function hideLogoutModal() {
            const m = document.getElementById('logout-modal');
            if (m) m.style.display = 'none';
        }
        async function doLogout() {
            hideLogoutModal();
            const csrfToken =
                document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
            try {
                await fetch('/logout', {
                    method: 'POST',
                    headers: { 'X-CSRF-TOKEN': csrfToken, 'Accept': 'application/json' },
                });
            } catch (_) {}
            setTimeout(() => {
                document.body.style.opacity = '0';
                document.body.style.transition = 'opacity .4s';
            }, 600);
            setTimeout(() => { window.location.href = '/login'; }, 1050);
        }

        // Tutup dropdown saat klik di luar
        document.addEventListener('click', e => {
            if (!e.target.closest('.filter-wrap')) {
                document.querySelectorAll('.filter-dropdown.open').forEach(d => d.classList.remove('open'));
            }
            if (!e.target.closest('.csel-wrap')) {
                document.querySelectorAll('.csel-dropdown.open').forEach(d => {
                    d.classList.remove('open');
                    d.closest('.csel-wrap')?.querySelector('.csel-trigger')?.classList.remove('open');
                });
            }
        });
    </script>

    @stack('scripts')
</body>

</html>
