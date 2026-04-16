const titles = {
    home: "Beranda",
    user: "Pengguna",
    kost: "Data Kost",
    review: "Ulasan",
    favorite: "Favorit",
};
let toastTimer;

/* ─── NAVIGASI ─── */
function goTo(id, navEl) {
    document
        .querySelectorAll(".page")
        .forEach((p) => p.classList.remove("active"));
    document
        .querySelectorAll(".nav-item")
        .forEach((n) => n.classList.remove("active"));
    const page = document.getElementById("page-" + id);
    page.classList.add("active");
    page.style.animation = "none";
    requestAnimationFrame(() => {
        page.style.animation = "";
    });
    if (navEl) navEl.classList.add("active");
    document.getElementById("topbar-title").textContent = titles[id];
    document.getElementById("sidebar").classList.remove("open");
}

/* UI GLOBAL */
function toggleCollapse() {
    document.body.classList.toggle("collapsed");
}

function toggleTheme() {
    const isDark = document.body.classList.toggle("dark");
    // Simpan preferensi ke localStorage agar persisten antar halaman
    localStorage.setItem("kf_theme", isDark ? "dark" : "light");
    const btn = document.getElementById("theme-toggle");
    if (btn) btn.textContent = isDark ? "☀️" : "🌙";
    showToast(
        isDark ? "Mode Gelap aktif" : "Mode Terang aktif",
        isDark ? "🌙" : "☀️",
    );
}

/* ─── TOAST ─── */
function showToast(msg, icon) {
    const t = document.getElementById("toast");
    document.getElementById("toast-msg").textContent = msg;
    document.getElementById("toast-icon").textContent = icon || "✅";
    t.style.opacity = "1";
    t.style.transform = "translateX(-50%) translateY(0)";
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
        t.style.opacity = "0";
        t.style.transform = "translateX(-50%) translateY(80px)";
    }, 2800);
}

/* ─── MODAL ─── */
function openModal(id) {
    document.getElementById(id).classList.add("open");
}
function closeModal(id) {
    document.getElementById(id).classList.remove("open");
}
function closeModalOutside(e, el) {
    if (e.target === el) el.classList.remove("open");
}

/* ─── LOGOUT ─── */
function showLogoutModal() {
    document.getElementById("logout-modal").style.display = "flex";
}
function hideLogoutModal() {
    document.getElementById("logout-modal").style.display = "none";
}
async function doLogout() {
    hideLogoutModal();
    showToast("Berhasil keluar...", "👋");

    // Ambil CSRF token dari meta tag
    const csrfToken =
        document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ||
        document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1]?.replace(/%3D/g, "=") ||
        "";

    try {
        await fetch("/logout", {
            method: "POST",
            headers: {
                "X-CSRF-TOKEN": csrfToken,
                Accept: "application/json",
            },
        });
    } catch (_) {
        // Tetap redirect meski fetch gagal
    }

    // Fade out lalu redirect ke login
    setTimeout(() => {
        document.body.style.opacity = "0";
        document.body.style.transition = "opacity .4s";
    }, 700);
    setTimeout(() => {
        window.location.href = "/login";
    }, 1150);
}

/* FILTER DROPDOWN (GLOBAL) */
function toggleFilter(id) {
    const dd = document.getElementById(id);
    const isOpen = dd.classList.contains("open");
    document
        .querySelectorAll(".filter-dropdown")
        .forEach((d) => d.classList.remove("open"));
    if (!isOpen) dd.classList.add("open");
}
document.addEventListener("click", (e) => {
    if (!e.target.closest(".filter-wrap")) {
        document
            .querySelectorAll(".filter-dropdown")
            .forEach((d) => d.classList.remove("open"));
    }
});

/* CLICK OUTSIDE */
document.addEventListener("click", (e) => {
    if (!e.target.closest(".filter-wrap")) {
        document
            .querySelectorAll(".filter-dropdown")
            .forEach((d) => d.classList.remove("open"));
    }
});

/* CUSTOM SELECT (csel) */
function toggleCsel(id) {
    const wrap = document.getElementById(id);
    const dd = wrap.querySelector(".csel-dropdown");
    const trig = wrap.querySelector(".csel-trigger");
    const isOpen = dd.classList.contains("open");
    // tutup semua csel lain
    document.querySelectorAll(".csel-dropdown.open").forEach((d) => {
        d.classList.remove("open");
        d.closest(".csel-wrap")
            .querySelector(".csel-trigger")
            .classList.remove("open");
    });
    if (!isOpen) {
        dd.classList.add("open");
        trig.classList.add("open");
        const inp = dd.querySelector(".csel-search");
        if (inp) {
            inp.value = "";
            searchCsel(id, "");
            inp.focus();
        }
    }
}
function pickCsel(id, el) {
    const wrap = document.getElementById(id);
    const val = el.dataset.val;
    const label = el.textContent.trim();
    wrap.querySelector(".csel-val").textContent = label;
    wrap.querySelector(".csel-val").classList.remove("csel-placeholder");
    wrap.dataset.value = val;
    wrap.querySelectorAll(".csel-opt").forEach((o) =>
        o.classList.remove("active"),
    );
    el.classList.add("active");
    wrap.querySelector(".csel-dropdown").classList.remove("open");
    wrap.querySelector(".csel-trigger").classList.remove("open");
}
function searchCsel(id, q) {
    const wrap = document.getElementById(id);
    const query = q.toLowerCase();
    let visible = 0;
    wrap.querySelectorAll(".csel-opt").forEach((o) => {
        const match = o.textContent.toLowerCase().includes(query);
        o.classList.toggle("hidden", !match);
        if (match) visible++;
    });
    const empty = wrap.querySelector(".csel-empty");
    if (empty) empty.classList.toggle("show", visible === 0);
}
function getCselVal(id) {
    const wrap = document.getElementById(id);
    return wrap
        ? wrap.dataset.value ||
              wrap.querySelector(".csel-val").textContent.trim()
        : "";
}
function setCselVal(id, val) {
    const wrap = document.getElementById(id);
    if (!wrap) return;
    const opt = Array.from(wrap.querySelectorAll(".csel-opt")).find(
        (o) => o.dataset.val === val || o.textContent.trim().includes(val),
    );
    if (opt) pickCsel(id, opt);
}

document.addEventListener("click", (e) => {
    if (!e.target.closest(".csel-wrap")) {
        document.querySelectorAll(".csel-dropdown.open").forEach((d) => {
            d.classList.remove("open");
        });
    }
});

/* ─── INIT: Restore dark mode dari localStorage ─── */
(function () {
    const saved = localStorage.getItem("kf_theme");
    if (saved === "dark") {
        document.body.classList.add("dark");
        // Tombol theme mungkin belum ada saat script ini dijalankan,
        // jadi set lewat DOMContentLoaded juga
        document.addEventListener("DOMContentLoaded", () => {
            const btn = document.getElementById("theme-toggle");
            if (btn) btn.textContent = "☀️";
        });
    }
})();
