let toastTimer;

const titles = { home:'Beranda', user:'Pengguna', kost:'Data Kost', review:'Ulasan', favorite:'Favorit' };

function goTo(id, navEl) {
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    const page = document.getElementById('page-'+id);
    page.classList.add('active');
    page.style.animation = 'none';
    requestAnimationFrame(() => { page.style.animation = ''; });
    if (navEl) navEl.classList.add('active');
    document.getElementById('topbar-title').textContent = titles[id];
    document.getElementById('sidebar').classList.remove('open');
}

function toggleCollapse() {
    document.body.classList.toggle('collapsed');
}

function toggleTheme() {
    const isDark = document.body.classList.toggle('dark');
    document.getElementById('theme-toggle').textContent = isDark ? '☀️' : '🌙';
    showToast(isDark ? 'Mode Gelap aktif' : 'Mode Terang aktif', isDark ? '🌙' : '☀️');
}

function setKostView(view) {
    document.getElementById('kost-view-grid').style.display  = view === 'grid'  ? 'grid'  : 'none';
    document.getElementById('kost-view-table').style.display = view === 'table' ? 'block' : 'none';
    document.getElementById('view-grid-btn').className  = 'btn-sm' + (view === 'grid'  ? ' primary' : '');
    document.getElementById('view-table-btn').className = 'btn-sm' + (view === 'table' ? ' primary' : '');
}

function showLogoutModal() {
    const m = document.getElementById('logout-modal');
    m.style.display = 'flex';
}

function hideLogoutModal() {
    document.getElementById('logout-modal').style.display = 'none';
}

function doLogout() {
    hideLogoutModal();
    showToast('Berhasil keluar...', '👋');

    // Memberikan waktu agar user bisa melihat Toast sebentar
    setTimeout(() => {
        document.body.style.transition = 'opacity .5s';
        document.body.style.opacity = '0';

        // Setelah animasi fade-out selesai (500ms), kirim form ke Laravel
        setTimeout(() => {
            document.getElementById('logout-form').submit();
        }, 500);

    }, 800);
}

function showToast(msg, icon) {
    const t = document.getElementById('toast');
    // Pastikan elemen 'toast', 'toast-msg', dan 'toast-icon' ada di HTML/Admin layout kamu
    if (!t) return;

    document.getElementById('toast-msg').textContent  = msg;
    document.getElementById('toast-icon').textContent = icon || '✅';
    t.style.opacity   = '1';
    t.style.transform = 'translateX(-50%) translateY(0)';

    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
      t.style.opacity   = '0';
      t.style.transform = 'translateX(-50%) translateY(80px)';
    }, 2800);
}
