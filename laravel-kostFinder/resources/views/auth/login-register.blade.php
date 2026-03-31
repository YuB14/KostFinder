@extends('layouts.auth')

@section('title', 'Masuk atau Daftar')

@section('content')
    <nav class="topbar">
        <a href="/" class="logo">🏠 Kost<span class="dot">Finder</span></a>
        <a href="/" class="topbar-link">← Kembali ke Beranda</a>
    </nav>

    <div class="auth-card">

        <div class="auth-tabs">
            <button class="tab-btn active" id="tab-login" onclick="switchTab('login')">Masuk</button>
            <button class="tab-btn" id="tab-register" onclick="switchTab('register')">Daftar</button>
        </div>

        <!-- LOGIN -->
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
                    <input type="text" id="login-email" name="email" placeholder="namaemail@gmail.com" />
                </div>
            </div>

            <div class="form-group">
                <label>Password</label>
                <div class="input-wrap">
                    <span class="input-icon">🔑</span>
                    <input type="password" id="login-pw" name="password" placeholder="Masukkan password" />
                    <button class="pw-toggle" onclick="togglePw('login-pw',this)" type="button">👁️</button>
                </div>
            </div>

            <div class="form-extras">
                <label class="checkbox-label">
                    <input type="checkbox" checked /> Ingat saya
                </label>
                <a href="#" class="forgot-link">Lupa password?</a>
            </div>

            <button class="btn-submit" onclick="handleLogin(this)">Masuk Sekarang →</button>

            <div class="switch-link">
                Belum punya akun? <a onclick="switchTab('register')">Daftar Gratis</a>
            </div>
        </div>

        <!-- REGISTER -->
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
                    <input type="text" id="reg-name" name="name" placeholder="Budi" />
                </div>
            </div>

            <div class="form-group">
                <label>Foto Profil</label>
                <div class="upload-row" id="uploadRow">
                    <input type="file" name="profile_picture" accept="image/*" id="fileInput" onchange="handleFile(this)">
                    <div class="avatar-sm" id="avatarSm">
                        <span id="placeholder">📷</span>
                        <img id="previewImg" alt="">
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
                    <input type="email" id="reg-email" name="email" placeholder="namaemail@gmail.com" />
                </div>
            </div>

            <div class="form-group" style="margin-bottom:20px">
                <label>Password</label>
                <div class="input-wrap">
                    <span class="input-icon">🔑</span>
                    <input type="password" id="reg-pw" placeholder="Min. 8 karakter..." oninput="checkStrength(this)" />
                    <button class="pw-toggle" onclick="togglePw('reg-pw',this)" type="button">👁️</button>
                </div>
                <div class="pw-strength" id="pw-strength">
                    <div class="strength-bar">
                        <div class="strength-fill" id="pw-fill"></div>
                    </div>
                    <div class="strength-label" id="pw-label"></div>
                </div>
            </div>

            <button class="btn-submit" onclick="handleRegister(this)">Buat Akun Sekarang →</button>

            <p class="terms-text">
                Dengan mendaftar, kamu menyetujui <a href="">Syarat & Ketentuan</a> dan <a href="">Kebijakan Privasi</a>
                KostFinder.
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
        // 1. Cek URL saat halaman pertama kali dimuat
        document.addEventListener("DOMContentLoaded", () => {
            const currentPath = window.location.pathname;
            if (currentPath === '/register' || currentPath.includes('register')) {
                switchTab('register', false);
            } else {
                switchTab('login', false);
            }
        });

        // 2. Fungsi untuk mengganti tab dan mengubah URL
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

            // 3. Ubah URL di address bar tanpa reload halaman
            if (pushState) {
                const newUrl = isLogin ? '/login' : '/register';
                window.history.pushState({ tab: tab }, '', newUrl);
            }
        }

        // 4. Handle tombol Back dan Forward di browser
        window.addEventListener('popstate', (event) => {
            const currentPath = window.location.pathname;
            if (currentPath === '/register' || currentPath.includes('register')) {
                switchTab('register', false);
            } else {
                switchTab('login', false);
            }
        });

        function togglePw(id, btn) {
            const input = document.getElementById(id);
            const isText = input.type === 'text';
            input.type = isText ? 'password' : 'text';
            btn.textContent = isText ? '👁️' : '❌';
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

        function showToast(msg, icon = '✅') {
            document.getElementById('toast-msg').textContent = msg;
            document.getElementById('toast-icon').textContent = icon;
            const t = document.getElementById('toast');
            t.classList.add('show');
            setTimeout(() => t.classList.remove('show'), 3200);
        }

        async function handleLogin(btn) {
            // Ambil data dari input
            const email = document.getElementById('login-email').value;
            const password = document.getElementById('login-pw').value;

            if (!email || !password) {
                showToast('Email dan password harus diisi!', '⚠️');
                return;
            }

            btn.textContent = '⏳ Memproses...';
            btn.disabled = true;

            try {
                const response = await fetch('/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: JSON.stringify({ email, password })
                });

                const result = await response.json();

                if (response.ok) {
                    showToast('Berhasil masuk! Selamat datang 👋', '✅');

                    // --- BAGIAN PENTING: REDIRECT KE DASHBOARD ---
                    const role = result.user.role; // 🔥 WAJIB

                    setTimeout(() => {
                        if (role === 'admin') {
                            window.location.href = "{{ route('dashboard') }}";
                        } else {
                            window.location.href = "";
                        }
                    }, 1000);

                } else {
                    showToast(result.message || 'Email atau password salah.', '❌');
                }
            } catch (error) {
                showToast('Koneksi ke server terputus.', '❌');
            } finally {
                if (!window.location.href.includes('dashboard')) {
                    btn.textContent = 'Masuk Sekarang →';
                    btn.disabled = false;
                }
            }
        }

        async function handleRegister(btn) {
            const name = document.getElementById('reg-name').value;
            const email = document.getElementById('reg-email').value;
            const password = document.getElementById('reg-pw').value;
            const fileInput = document.getElementById('fileInput');

            if (!name || !email || !password) {
                showToast('Semua field wajib diisi!', '⚠️');
                return;
            }

            if (!fileInput.files[0]) {
                showToast('Foto profil wajib diupload!', '⚠️');
                return;
            }

            if (!email.includes('@')) {
                showToast('Format email tidak valid!', '⚠️');
                return;
            }

            const formData = new FormData();
            formData.append('name', name);
            formData.append('email', email);
            formData.append('password', password);
            formData.append('profile_picture', fileInput.files[0]);

            btn.textContent = '⏳ Membuat akun...';
            btn.disabled = true;

            try {
                const response = await fetch('/register', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: formData
                });

                let result;

                // ✅ INI YANG DIUBAH
                try {
                    result = await response.json();
                } catch (e) {
                    throw new Error('Response bukan JSON');
                }

                if (!response.ok) {

                    if (result.errors) {
                        if (result.errors.email) {
                            showToast('Email sudah digunakan, gunakan email lain! 📧', '❌');
                        } else if (result.errors.profile_picture) {
                            showToast('Foto profil wajib diupload! 📷', '❌');
                        } else {
                            showToast(Object.values(result.errors)[0][0], '❌');
                        }
                    } else {
                        showToast(result.message || 'Register gagal', '❌');
                    }

                    return;
                }

                // ✅ kalau sukses
                showToast('Register berhasil! 🎉', '✅');

            } catch (error) {
                console.error(error); // 🔥 ini penting buat debug
                showToast('Gagal menghubungi server. Periksa koneksi! 🌐', '❌');
            } finally {
                btn.textContent = 'Buat Akun Sekarang →';
                btn.disabled = false;
            }
        }


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
                img.src = e.target.result;
                img.style.display = 'block';
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
