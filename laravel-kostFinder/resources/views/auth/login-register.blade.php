@extends('admin.layouts.auth')
@section('title', 'Masuk atau Daftar')

@section('content')
    <nav class="topbar">
        <a href="/" class="logo"><img src="{{ asset('storage/images/logo-kostFinder.png') }}" alt="KostFinder" style="height:30px;border-radius:8px;object-fit:contain;"> Kost<span class="dot">Finder</span></a>
        <a href="/" class="topbar-link">← Kembali ke Beranda</a>
    </nav>

    <div class="auth-card">
        <div class="auth-tabs">
            <button class="tab-btn active" id="tab-login" onclick="switchTab('login')">Masuk</button>
            <button class="tab-btn" id="tab-register" onclick="switchTab('register')">Daftar</button>
        </div>

        {{-- ─── LOGIN ─── --}}
        <div id="form-login" class="auth-form">
            <div class="form-header">
                <div class="eyebrow"><span class="pulse-dot"></span> Selamat Datang Kembali</div>
                <h1>Masuk ke <em>Akunmu</em> 👋</h1>
                <p>Temukan kost impianmu hari ini — cepat, mudah, dan terpercaya.</p>
            </div>

            <div class="form-group">
                <label>Email</label>
                <div class="input-wrap">
                    <span class="input-icon">📧</span>
                    {{-- Enter di field email pindah ke password --}}
                    <input type="email" id="login-email" placeholder="namaemail@gmail.com"
                        onkeydown="if(event.key==='Enter')document.getElementById('login-pw').focus()" />
                </div>
            </div>

            <div class="form-group">
                <label>Password</label>
                <div class="input-wrap">
                    <span class="input-icon">🔑</span>
                    {{-- Enter di field password langsung submit login --}}
                    <input type="password" id="login-pw" placeholder="Masukkan password"
                        onkeydown="if(event.key==='Enter')handleLogin(document.getElementById('btn-login'))" />
                    <button class="pw-toggle" onclick="togglePw('login-pw',this)" type="button">👁️</button>
                </div>
            </div>

            <div class="form-extras">
                <label class="checkbox-label">
                    {{-- Checkbox ingat saya — nilai dikirim ke server --}}
                    <input type="checkbox" id="login-remember" checked /> Ingat saya
                </label>
            </div>

            <div id="login-error"
                style="display:none;background:rgba(229,62,62,.08);border:1px solid rgba(229,62,62,.2);border-radius:10px;padding:11px 14px;font-size:13px;color:#E53E3E;margin-bottom:14px">
            </div>

            <button class="btn-submit" id="btn-login" onclick="handleLogin(this)">Masuk Sekarang →</button>

            <div class="switch-link">
                Belum punya akun? <a onclick="switchTab('register')">Daftar Gratis</a>
            </div>
        </div>

        {{-- ─── REGISTER ─── --}}
        <div id="form-register" class="auth-form" style="display:none">
            <div class="form-header">
                <div class="eyebrow"><span class="pulse-dot"></span> Bergabung Sekarang</div>
                <h1>Buat Akun <em>Gratis</em> ✨</h1>
                <p>Bergabung dengan 18.000+ pencari kost di seluruh Indonesia.</p>
            </div>

            <div class="form-group">
                <label>Nama Lengkap</label>
                <div class="input-wrap">
                    <span class="input-icon">👤</span>
                    {{-- Enter pindah ke field email --}}
                    <input type="text" id="reg-name" placeholder="Nama Lengkap"
                        onkeydown="if(event.key==='Enter')document.getElementById('reg-email').focus()" />
                </div>
            </div>

            <div class="form-group">
                <label>Foto Profil</label>
                <div class="upload-row" id="uploadRow">
                    <input type="file" accept="image/*" id="fileInput" onchange="handleFile(this)" />
                    <div class="avatar-sm" id="avatarSm">
                        <span id="placeholder">📷</span>
                        <img id="previewImg" alt="" />
                    </div>
                    <div style="flex:1;min-width:0">
                        <p class="ut-main" id="utMain">Pilih foto profil</p>
                        <p class="ut-sub" id="utSub">PNG, JPG · maks. <span class="ut-link">2 MB</span></p>
                    </div>
                    <button class="remove-sm" id="removeBtn" onclick="removeFile(event)" type="button">✕</button>
                </div>
            </div>

            <div class="form-group">
                <label>Email</label>
                <div class="input-wrap">
                    <span class="input-icon">📧</span>
                    {{-- Enter pindah ke password --}}
                    <input type="email" id="reg-email" placeholder="namaemail@gmail.com"
                        onkeydown="if(event.key==='Enter')document.getElementById('reg-pw').focus()" />
                </div>
            </div>

            <div class="form-group" style="margin-bottom:20px">
                <label>Password</label>
                <div class="input-wrap">
                    <span class="input-icon">🔑</span>
                    {{-- Enter di password langsung submit register --}}
                    <input type="password" id="reg-pw" placeholder="Min. 8 karakter..." oninput="checkStrength(this)"
                        onkeydown="if(event.key==='Enter')handleRegister(document.getElementById('btn-register'))" />
                    <button class="pw-toggle" onclick="togglePw('reg-pw',this)" type="button">👁️</button>
                </div>
                <div class="pw-strength" id="pw-strength">
                    <div class="strength-bar">
                        <div class="strength-fill" id="pw-fill"></div>
                    </div>
                    <div class="strength-label" id="pw-label"></div>
                </div>
            </div>

            <div id="reg-error"
                style="display:none;background:rgba(229,62,62,.08);border:1px solid rgba(229,62,62,.2);border-radius:10px;padding:11px 14px;font-size:13px;color:#E53E3E;margin-bottom:14px">
            </div>

            <button class="btn-submit" id="btn-register" onclick="handleRegister(this)">Buat Akun Sekarang →</button>

            <p class="terms-text">
                Dengan mendaftar, kamu menyetujui
                <a href="">Syarat & Ketentuan</a> dan <a href="">Kebijakan Privasi</a> KostFinder.
            </p>

            <div class="switch-link">
                Sudah punya akun? <a onclick="switchTab('login')">Masuk di sini</a>
            </div>
        </div>
    </div>

    <div class="trust-row">
        <div class="trust-badge">🔒 SSL Terenkripsi</div>
        <div class="trust-badge">✅ Data Aman</div>
        <div class="trust-badge">🆓 Gratis Selamanya</div>
    </div>

    <div class="toast" id="toast">
        <span id="toast-icon">✅</span>
        <span id="toast-msg">Berhasil!</span>
    </div>
@endsection

@push('scripts')
    <script>
        /* ══════════════════════════════════════════════════
           TAB SWITCHER
        ══════════════════════════════════════════════════ */
        document.addEventListener('DOMContentLoaded', () => {
            const path = window.location.pathname;
            switchTab(path.includes('register') ? 'register' : 'login', false);
        });

        function switchTab(tab, pushState = true) {
            const isLogin = tab === 'login';
            document.getElementById('tab-login').classList.toggle('active', isLogin);
            document.getElementById('tab-register').classList.toggle('active', !isLogin);

            const loginEl = document.getElementById('form-login');
            const regEl = document.getElementById('form-register');
            loginEl.style.display = isLogin ? 'block' : 'none';
            regEl.style.display = isLogin ? 'none' : 'block';

            const el = isLogin ? loginEl : regEl;
            el.style.animation = 'none';
            requestAnimationFrame(() => { el.style.animation = ''; });

            if (pushState) {
                window.history.pushState({ tab }, '', isLogin ? '/login' : '/register');
            }
        }

        window.addEventListener('popstate', () => {
            const path = window.location.pathname;
            switchTab(path.includes('register') ? 'register' : 'login', false);
        });

        /* ══════════════════════════════════════════════════
           LOGIN
           - "Ingat Saya" dikirim ke server sebagai field "remember"
           - Auth::login($user, $remember) di controller akan membuat
             cookie persisten jika remember=true
        ══════════════════════════════════════════════════ */
        async function handleLogin(btn) {
            const email = document.getElementById('login-email').value.trim();
            const password = document.getElementById('login-pw').value;
            const remember = document.getElementById('login-remember').checked;
            const errorEl = document.getElementById('login-error');

            // Validasi frontend
            if (!email || !password) {
                showError(errorEl, '⚠️ Email dan password wajib diisi.');
                return;
            }
            if (!email.includes('@')) {
                showError(errorEl, '⚠️ Format email tidak valid.');
                return;
            }

            errorEl.style.display = 'none';
            btn.textContent = '⏳ Memproses...';
            btn.disabled = true;

            try {
                const res = await fetch('/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({ email, password, remember }),
                });
                const result = await res.json();

                if (res.ok && result.success) {
                    showToast('Berhasil masuk! Selamat datang 👋', '✅');
                    // Redirect berdasarkan role
                    setTimeout(() => {
                        const role = result.user?.role ?? 'user';
                        window.location.href = role === 'admin'
                            ? '{{ route("dashboard") }}'
                            : '{{ route("user.dashboard") }}';
                    }, 900);
                } else {
                    showError(errorEl, result.message || 'Email atau password salah.');
                    btn.textContent = 'Masuk Sekarang →';
                    btn.disabled = false;
                }
            } catch (err) {
                console.error(err);
                showError(errorEl, '❌ Koneksi ke server terputus.');
                btn.textContent = 'Masuk Sekarang →';
                btn.disabled = false;
            }
        }

        /* ══════════════════════════════════════════════════
           REGISTER
           Setelah berhasil:
           1. Tampilkan toast sukses
           2. Clear semua field form register
           3. Pindah ke tab login setelah 1.5 detik
        ══════════════════════════════════════════════════ */
        async function handleRegister(btn) {
            const name = document.getElementById('reg-name').value.trim();
            const email = document.getElementById('reg-email').value.trim();
            const password = document.getElementById('reg-pw').value;
            const fileInput = document.getElementById('fileInput');
            const errorEl = document.getElementById('reg-error');

            // Validasi frontend
            if (!name) { showError(errorEl, '⚠️ Nama lengkap wajib diisi.'); return; }
            if (!email) { showError(errorEl, '⚠️ Email wajib diisi.'); return; }
            if (!email.includes('@')) { showError(errorEl, '⚠️ Format email tidak valid.'); return; }
            if (!password) { showError(errorEl, '⚠️ Password wajib diisi.'); return; }
            if (password.length < 8) { showError(errorEl, '⚠️ Password minimal 8 karakter.'); return; }
            if (!fileInput.files[0]) { showError(errorEl, '⚠️ Foto profil wajib diupload.'); return; }

            errorEl.style.display = 'none';
            btn.textContent = '⏳ Membuat akun...';
            btn.disabled = true;

            const formData = new FormData();
            formData.append('name', name);
            formData.append('email', email);
            formData.append('password', password);
            formData.append('profile_picture', fileInput.files[0]);

            try {
                const res = await fetch('/register', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json',
                    },
                    body: formData,
                });
                const result = await res.json();

                if ((res.ok || res.status === 201) && result.success) {
                    showToast('Akun berhasil dibuat! Silakan masuk 🎉', '✅');

                    // ── Clear form register ──────────────────────────────
                    document.getElementById('reg-name').value = '';
                    document.getElementById('reg-email').value = '';
                    document.getElementById('reg-pw').value = '';
                    removeFile({ stopPropagation: () => { } });  // reset foto profil
                    document.getElementById('pw-strength').classList.remove('show');

                    // ── Pindah ke tab login setelah 1.5 detik ───────────
                    setTimeout(() => switchTab('login'), 1500);

                } else {
                    // Tampilkan error validasi dari server
                    if (result.errors) {
                        const firstErr = Object.values(result.errors).flat()[0];
                        showError(errorEl, firstErr || 'Validasi gagal.');
                    } else {
                        showError(errorEl, result.message || 'Gagal mendaftar.');
                    }
                }
            } catch (err) {
                console.error(err);
                showError(errorEl, '❌ Gagal menghubungi server. Periksa koneksi!');
            } finally {
                btn.textContent = 'Buat Akun Sekarang →';
                btn.disabled = false;
            }
        }

        /* ══════════════════════════════════════════════════
           HELPER FUNCTIONS
        ══════════════════════════════════════════════════ */
        function showError(el, msg) {
            el.textContent = msg;
            el.style.display = 'block';
        }

        function showToast(msg, icon = '✅') {
            document.getElementById('toast-msg').textContent = msg;
            document.getElementById('toast-icon').textContent = icon;
            const t = document.getElementById('toast');
            t.classList.add('show');
            setTimeout(() => t.classList.remove('show'), 3200);
        }

        function togglePw(id, btn) {
            const input = document.getElementById(id);
            input.type = input.type === 'password' ? 'text' : 'password';
            btn.textContent = input.type === 'text' ? '❌' : '👁️';
        }

        function checkStrength(input) {
            const val = input.value;
            const wrap = document.getElementById('pw-strength');
            const fill = document.getElementById('pw-fill');
            const label = document.getElementById('pw-label');
            if (!val) { wrap.classList.remove('show'); return; }
            wrap.classList.add('show');
            let score = 0;
            if (val.length >= 8) score++;
            if (/[A-Z]/.test(val)) score++;
            if (/[0-9]/.test(val)) score++;
            if (/[^A-Za-z0-9]/.test(val)) score++;
            const cfg = [
                { w: '25%', bg: '#E53E3E', lbl: '😬 Sangat Lemah' },
                { w: '50%', bg: '#DD6B20', lbl: '⚠️ Lemah' },
                { w: '75%', bg: '#D48D00', lbl: '🙂 Cukup Kuat' },
                { w: '100%', bg: '#38A169', lbl: '💪 Kuat!' },
            ];
            const c = cfg[Math.max(0, score - 1)];
            fill.style.width = c.w;
            fill.style.background = c.bg;
            label.textContent = c.lbl;
            label.style.color = c.bg;
        }

        /* ── Upload Foto ── */
        const row = document.getElementById('uploadRow');
        row.addEventListener('dragover', e => { e.preventDefault(); row.classList.add('drag-over'); });
        row.addEventListener('dragleave', () => row.classList.remove('drag-over'));
        row.addEventListener('drop', e => {
            e.preventDefault(); row.classList.remove('drag-over');
            const f = e.dataTransfer.files[0];
            if (f && f.type.startsWith('image/')) applyFile(f);
        });

        function handleFile(i) { if (i.files[0]) applyFile(i.files[0]); }

        function applyFile(file) {
            const reader = new FileReader();
            reader.onload = e => {
                const img = document.getElementById('previewImg');
                img.src = e.target.result; img.style.display = 'block';
                document.getElementById('placeholder').style.display = 'none';
                document.getElementById('avatarSm').style.borderColor = 'var(--coral)';
            };
            reader.readAsDataURL(file);
            const name = file.name;
            document.getElementById('utMain').textContent = name.length > 22 ? name.slice(0, 22) + '…' : name;
            document.getElementById('utSub').innerHTML = (file.size / 1024).toFixed(0) + ' KB · <span class="ut-link">Ganti foto</span>';
            document.getElementById('removeBtn').classList.add('show');
        }

        function removeFile(e) {
            e.stopPropagation();
            document.getElementById('previewImg').style.display = 'none';
            document.getElementById('placeholder').style.display = '';
            document.getElementById('avatarSm').style.borderColor = '';
            document.getElementById('utMain').textContent = 'Pilih foto profil';
            document.getElementById('utSub').innerHTML = 'PNG, JPG · maks. <span class="ut-link">2 MB</span>';
            document.getElementById('removeBtn').classList.remove('show');
            document.getElementById('fileInput').value = '';
        }
    </script>
@endpush
