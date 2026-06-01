@extends('user.layouts.auth-user')
@section('title', 'Prediksi Kost')
@section('page_title', 'Prediksi Kost')

@section('content')
<style>
.pred-hero{background:linear-gradient(135deg,rgba(232,67,13,.06),rgba(0,143,120,.06));border:1px solid var(--border);border-radius:18px;padding:40px 32px;text-align:center;margin-bottom:24px}
.pred-hero h2{font-family:'Syne',sans-serif;font-size:28px;font-weight:800;margin-bottom:8px}
.pred-hero h2 em{color:var(--coral);font-style:normal}
.pred-hero p{color:var(--muted);font-size:14px;max-width:480px;margin:0 auto 28px}
.harga-input-wrap{position:relative;max-width:400px;margin:0 auto 12px}
.harga-prefix{position:absolute;left:16px;top:50%;transform:translateY(-50%);font-size:15px;color:var(--muted);font-weight:700;pointer-events:none}
#pred-harga{width:100%;background:var(--card);border:2px solid var(--border);border-radius:14px;padding:16px 16px 16px 48px;font-family:'Syne',sans-serif;font-size:22px;font-weight:800;color:var(--text);outline:none;transition:border-color .2s,box-shadow .2s;text-align:left}
#pred-harga:focus{border-color:var(--coral);box-shadow:0 0 0 4px rgba(232,67,13,.1)}
#harga-display{font-size:12px;color:var(--coral);font-weight:600;margin-bottom:20px;min-height:18px}
#btn-prediksi{background:var(--coral);color:white;border:none;border-radius:12px;padding:14px 36px;font-family:'Syne',sans-serif;font-size:15px;font-weight:800;cursor:pointer;transition:background .2s,transform .15s,box-shadow .2s;box-shadow:0 4px 16px rgba(232,67,13,.3)}
#btn-prediksi:hover{background:#cf3b0b;transform:translateY(-1px);box-shadow:0 6px 20px rgba(232,67,13,.4)}
#btn-prediksi:disabled{opacity:.6;cursor:not-allowed;transform:none}
.steps-row{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;max-width:600px;margin:28px auto 0}
.step-item{display:flex;flex-direction:column;align-items:center;gap:8px;font-size:12px;color:var(--muted)}
.step-num{width:32px;height:32px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-weight:800;font-size:14px}
/* Prediksi result card */
.pred-result-card{background:var(--card);border:2px solid var(--coral);border-radius:18px;padding:24px;margin-bottom:24px;animation:fadeUp .35s ease;box-shadow:0 4px 24px rgba(232,67,13,.12)}
.pred-result-title{font-family:'Syne',sans-serif;font-size:15px;font-weight:800;margin-bottom:16px;display:flex;align-items:center;gap:8px}
.pred-chars{display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:12px}
.pred-char{background:var(--bg);border-radius:12px;padding:14px;border:1px solid var(--border)}
.pred-char-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px}
.pred-char-val{font-family:'Syne',sans-serif;font-size:14px;font-weight:800;color:var(--text)}
.pred-fas-list{display:flex;flex-wrap:wrap;gap:6px;margin-top:4px}
.pred-fas-tag{background:var(--coral-bg);color:var(--coral);border-radius:100px;padding:3px 10px;font-size:11px;font-weight:600}
.source-badge{font-size:10px;padding:3px 9px;border-radius:100px;font-weight:600;margin-left:auto}
.source-badge.flask{background:var(--teal-bg);color:var(--teal)}
.source-badge.rule{background:var(--yellow-bg);color:var(--yellow)}
/* Kost cards */
.rekomendasi-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
.rekomendasi-header h3{font-family:'Syne',sans-serif;font-size:16px;font-weight:800}
@keyframes fadeUp{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
.empty-state{text-align:center;padding:48px 20px;color:var(--muted)}
.empty-state .empty-icon{font-size:48px;margin-bottom:12px}
</style>

{{-- HERO INPUT --}}
<div class="pred-hero">
    <div id="ml-status-badge" style="display:inline-flex;align-items:center;gap:6px;padding:5px 14px;border-radius:100px;font-size:11px;font-weight:700;margin-bottom:16px;background:rgba(107,126,148,.1);color:var(--muted)">
        <span id="ml-status-dot" style="width:8px;height:8px;border-radius:50%;background:var(--muted)"></span>
        <span id="ml-status-text">Mengecek status ML...</span>
    </div>

    <h2>Prediksi <em>Kost</em> Impianmu 🤖</h2>
    <p>Masukkan harga kost yang sesuai anggaranmu. Model ML akan memprediksi kelas, jenis, status, fasilitas, dan ukuran kamar yang paling sesuai.</p>

    <div class="harga-input-wrap">
        <span class="harga-prefix">Rp</span>
        <input type="text" id="pred-harga" placeholder="1.500.000" inputmode="numeric"
            oninput="fmtHarga(this)" onfocus="this.style.borderColor='var(--coral)'"
            onblur="this.style.borderColor=''" />
    </div>
    <div id="harga-display"></div>

    <button id="btn-prediksi" onclick="jalankanPrediksi()" disabled>
        <span id="btn-label">🤖 Prediksi Sekarang</span>
    </button>

    <div id="pred-error" class="form-error-msg" style="display:none;max-width:400px;margin:12px auto 0"></div>

    <div class="steps-row">
        <div class="step-item">
            <div class="step-num" style="background:var(--coral-bg);color:var(--coral)">1</div>
            <span>Input harga anggaran</span>
        </div>
        <div class="step-item">
            <div class="step-num" style="background:var(--teal-bg);color:var(--teal)">2</div>
            <span>Flask ML menganalisis</span>
        </div>
        <div class="step-item">
            <div class="step-num" style="background:var(--yellow-bg);color:var(--yellow)">3</div>
            <span>Tampilkan rekomendasi</span>
        </div>
    </div>
</div>

{{-- STATISTIK --}}
<div class="widget" style="margin-bottom:24px">
    <div class="section-hd">
        <h3>📈 Statistik Dataset Kost</h3>
    </div>
    <div id="pred-stats" style="font-size:13px;color:var(--muted)">Memuat statistik...</div>
</div>

{{-- HASIL --}}
<div id="pred-hasil-wrap" style="display:none">
    {{-- Card Prediksi Karakteristik --}}
    <div id="pred-result-card" class="pred-result-card">
        <div class="pred-result-title">
            🎯 Prediksi Karakteristik Kost
            <span id="source-badge" class="source-badge"></span>
        </div>
        <div class="pred-chars">
            <div class="pred-char">
                <div class="pred-char-lbl">🏷️ Kelas</div>
                <div class="pred-char-val" id="pc-kelas">—</div>
            </div>
            <div class="pred-char">
                <div class="pred-char-lbl">👥 Jenis</div>
                <div class="pred-char-val" id="pc-jenis">—</div>
            </div>
            <div class="pred-char">
                <div class="pred-char-lbl">✅ Status</div>
                <div class="pred-char-val" id="pc-status">—</div>
            </div>
            <div class="pred-char">
                <div class="pred-char-lbl">📐 Ukuran Kamar</div>
                <div class="pred-char-val" id="pc-ukuran">—</div>
            </div>
            <div class="pred-char" style="grid-column:1/-1">
                <div class="pred-char-lbl">🔌 Fasilitas Umum</div>
                <div class="pred-fas-list" id="pc-fasilitas"></div>
            </div>
        </div>
    </div>

    {{-- Daftar Kost Rekomendasi --}}
    <div class="widget">
        <div class="rekomendasi-header">
            <h3>🏘️ Kost Rekomendasi</h3>
            <span id="rek-count" style="font-size:12px;color:var(--muted)"></span>
        </div>
        <div class="kost-grid-user" id="rek-grid"></div>
    </div>
</div>

{{-- MODAL DETAIL --}}
<div class="modal-overlay" id="modal-pred-detail" onclick="closeModalOutside(event,this)">
    <div class="modal-box" style="max-width:520px">
        <div class="modal-header">
            <h3>🏘️ Detail Kost</h3>
            <button class="modal-close" onclick="closeModal('modal-pred-detail')">✕</button>
        </div>
        <div class="modal-body">
            <div id="pd-foto" style="height:180px;border-radius:12px;overflow:hidden;margin-bottom:16px;background:var(--bg2);display:flex;align-items:center;justify-content:center;font-size:56px"></div>
            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:14px;padding-bottom:14px;border-bottom:1px solid var(--border)">
                <div>
                    <div id="pd-nama" style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800"></div>
                    <div id="pd-lokasi" style="font-size:12px;color:var(--muted);margin-top:3px"></div>
                </div>
                <span id="pd-skor" style="background:var(--coral-bg);color:var(--coral);padding:4px 12px;border-radius:100px;font-size:12px;font-weight:700"></span>
            </div>
            <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:14px">
                <div style="background:var(--bg);border-radius:10px;padding:12px">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase">Harga</div>
                    <div id="pd-harga" style="font-family:'Syne',sans-serif;font-size:15px;font-weight:800;color:var(--coral)"></div>
                </div>
                <div style="background:var(--bg);border-radius:10px;padding:12px">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase">Kelas</div>
                    <div id="pd-kelas" style="font-family:'Syne',sans-serif;font-size:15px;font-weight:800"></div>
                </div>
                <div style="background:var(--bg);border-radius:10px;padding:12px">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase">Luas Kamar</div>
                    <div id="pd-ukuran" style="font-family:'Syne',sans-serif;font-size:15px;font-weight:800"></div>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px">
                <div style="background:var(--bg);border-radius:10px;padding:12px">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase">Jenis</div>
                    <div id="pd-jenis" style="font-size:14px;font-weight:700;margin-top:2px"></div>
                </div>
                <div style="background:var(--bg);border-radius:10px;padding:12px">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase">Rating</div>
                    <div id="pd-rating" style="font-size:14px;margin-top:2px"></div>
                </div>
            </div>
            <div id="pd-fasilitas" style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:14px"></div>

            {{-- Telepon --}}
            <div style="margin-bottom:14px">
                <div style="font-size:11px;color:var(--muted);font-weight:700;text-transform:uppercase;margin-bottom:6px">Telepon / WhatsApp</div>
                <div style="display:flex;align-items:center;gap:12px">
                    <div id="pd-telepon" style="font-family:'Syne',sans-serif;font-size:14px;font-weight:700;color:var(--text)"></div>
                    <a id="pd-whatsapp-btn" href="#" target="_blank" class="btn-sm" style="background:#25D366;color:white;text-decoration:none;display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:8px;font-size:12px;font-weight:700;border:none;box-shadow:0 2px 8px rgba(37,211,102,.3)">
                        💬 Hubungi via WA
                    </a>
                </div>
            </div>
        </div>
        <div class="modal-footer" style="display:flex;gap:8px;justify-content:flex-end;align-items:center">
            <button class="btn-sm" onclick="closeModal('modal-pred-detail')">Tutup</button>
            <button class="btn-sm primary" id="btn-fav-pred" onclick="tambahFavDariPred()">❤️ Simpan Favorit</button>
            <a id="pd-whatsapp-footer-btn" href="#" target="_blank" class="btn-sm" style="background:#25D366;color:white;text-decoration:none;display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:8px;font-weight:700;border:none;box-shadow:0 3px 10px rgba(37,211,102,.3)">
                💬 Hubungi Pemilik (WA)
            </a>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
let predSelectedId = null;
let mlOnline = false;

/* ─── Format Harga ─────────────────────────────────── */
function fmtHarga(el) {
    const raw = el.value.replace(/\D/g, '');
    el.value = raw ? Number(raw).toLocaleString('id-ID') : '';
    const n = parseInt(raw) || 0;
    const disp = document.getElementById('harga-display');
    disp.textContent = n > 0 ? '≈ ' + formatRupiah(n) + ' / bulan' : '';
}
function getRawHarga() {
    return parseInt((document.getElementById('pred-harga').value || '').replace(/\./g, '').replace(/,/g, '')) || 0;
}

/* ─── Cek Status ML (Flask) ────────────────────────── */
async function checkMlHealth() {
    const badge = document.getElementById('ml-status-badge');
    const dot   = document.getElementById('ml-status-dot');
    const text  = document.getElementById('ml-status-text');
    const btn   = document.getElementById('btn-prediksi');

    try {
        const res  = await fetch('/api/user/prediksi/health');
        const data = await res.json();

        if (data.success && data.flask_status === 'online') {
            mlOnline = true;
            dot.style.background  = '#38A169';
            dot.style.animation   = 'pulse 1.5s infinite';
            text.textContent      = '🧠 ML Server Online' + (data.model_trained ? ' — Model Siap' : ' — Model Belum Dilatih');
            badge.style.background = 'rgba(56,161,105,.1)';
            badge.style.color      = '#38A169';
            btn.disabled = false;
        } else {
            mlOnline = false;
            dot.style.background  = '#E53E3E';
            text.textContent      = '⚠️ ML Server Offline — Jalankan python app.py';
            badge.style.background = 'rgba(229,62,62,.1)';
            badge.style.color      = '#E53E3E';
            btn.disabled = true;
        }
    } catch {
        mlOnline = false;
        dot.style.background  = '#E53E3E';
        text.textContent      = '⚠️ ML Server Offline — Jalankan python app.py';
        badge.style.background = 'rgba(229,62,62,.1)';
        badge.style.color      = '#E53E3E';
        btn.disabled = true;
    }
}

/* ─── Statistik ─────────────────────────────────────── */
async function loadStats() {
    try {
        const res  = await fetch('/api/user/prediksi/stats');
        const data = await res.json();
        const el   = document.getElementById('pred-stats');
        if (data.success) {
            const d = data.data;
            el.innerHTML = `<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:12px">
                <div style="background:var(--bg);border-radius:10px;padding:12px;border:1px solid var(--border)">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase;margin-bottom:4px">Total Kost</div>
                    <div style="font-family:'Syne',sans-serif;font-size:22px;font-weight:800;color:var(--coral)">${d.total_kost}</div>
                </div>
                <div style="background:var(--bg);border-radius:10px;padding:12px;border:1px solid var(--border)">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase;margin-bottom:4px">Harga Min</div>
                    <div style="font-family:'Syne',sans-serif;font-size:16px;font-weight:800">${formatRupiah(d.harga_min)}</div>
                </div>
                <div style="background:var(--bg);border-radius:10px;padding:12px;border:1px solid var(--border)">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase;margin-bottom:4px">Harga Maks</div>
                    <div style="font-family:'Syne',sans-serif;font-size:16px;font-weight:800">${formatRupiah(d.harga_max)}</div>
                </div>
                <div style="background:var(--bg);border-radius:10px;padding:12px;border:1px solid var(--border)">
                    <div style="font-size:10px;color:var(--muted);font-weight:700;text-transform:uppercase;margin-bottom:4px">Rata-rata</div>
                    <div style="font-family:'Syne',sans-serif;font-size:16px;font-weight:800">${formatRupiah(d.harga_avg)}</div>
                </div>
            </div>`;
        }
    } catch { document.getElementById('pred-stats').textContent = 'Gagal memuat statistik.'; }
}
document.addEventListener('DOMContentLoaded', () => { loadStats(); checkMlHealth(); });

/* ─── Jalankan Prediksi ─────────────────────────────── */
async function jalankanPrediksi() {
    const harga   = getRawHarga();
    const errEl   = document.getElementById('pred-error');
    if (!harga || harga < 100000) {
        errEl.textContent = 'Masukkan harga minimal Rp 100.000.';
        errEl.style.display = 'block';
        return;
    }
    errEl.style.display = 'none';

    const btn   = document.getElementById('btn-prediksi');
    const label = document.getElementById('btn-label');
    btn.disabled = true;
    label.textContent = '⏳ Menganalisis dengan ML...';

    try {
        const res  = await fetch('/api/user/prediksi', {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
            body: JSON.stringify({ harga }),
        });
        const data = await res.json();

        if (data.success) {
            tampilkanHasil(data.prediksi, data.data, data.meta, data.sumber);
        } else {
            errEl.textContent = data.message || 'Prediksi gagal.';
            errEl.style.display = 'block';
        }
    } catch (e) {
        errEl.textContent = 'Terjadi kesalahan server.';
        errEl.style.display = 'block';
    } finally {
        btn.disabled = false;
        label.textContent = '🤖 Prediksi Sekarang';
    }
}

/* ─── Tampilkan Hasil ───────────────────────────────── */
function tampilkanHasil(prediksi, kosts, meta, sumber) {
    const wrap = document.getElementById('pred-hasil-wrap');
    wrap.style.display = 'block';
    wrap.scrollIntoView({ behavior: 'smooth', block: 'start' });

    const KELAS={1:'Ekonomi',2:'Standar',3:'Premium'};
    const TIPE={1:'Pria',2:'Wanita',3:'Campur'};

    document.getElementById('pc-kelas').textContent  = prediksi.kelas_label  || KELAS[prediksi.kelas]  || '—';
    document.getElementById('pc-jenis').textContent  = prediksi.tipe_kos_label|| TIPE[prediksi.tipe_kos]|| '—';
    document.getElementById('pc-status').textContent = prediksi.status_label  || (prediksi.status>=1?'Tersedia':'Penuh');
    document.getElementById('pc-ukuran').textContent = prediksi.luas_kamar ? prediksi.luas_kamar+' m²' : '—';

    // Fasilitas dari binary fields
    const FAS_MAP={listrik:'⚡ Listrik',ac:'❄️ AC',kamar_mandi_dalam:'🚿 KM Dalam',parkir_motor:'🏍️ Parkir',laundry:'👕 Laundry',wifi:'📶 WiFi'};
    const fasAktif=Object.entries(FAS_MAP).filter(([k])=>prediksi[k]==1).map(([,v])=>v);
    document.getElementById('pc-fasilitas').innerHTML = fasAktif.length
        ? fasAktif.map(f=>`<span class="pred-fas-tag">${f}</span>`).join('')
        : '<span style="color:var(--muted);font-size:12px">—</span>';

    const badge = document.getElementById('source-badge');
    const isFlask = sumber && sumber.includes('flask');
    badge.textContent  = isFlask ? '🧠 Flask ML' : '📐 Rule-based';
    badge.className    = 'source-badge ' + (isFlask ? 'flask' : 'rule');

    const grid  = document.getElementById('rek-grid');
    const count = document.getElementById('rek-count');
    count.textContent = `${kosts.length} kost ditemukan`;

    if (!kosts.length) {
        grid.innerHTML = `<div class="empty-state" style="grid-column:1/-1">
            <div class="empty-icon">🔍</div>
            <strong>Tidak ada kost yang cocok</strong>
            <p style="margin-top:6px;font-size:13px">Coba angka harga yang berbeda atau lebih fleksibel.</p>
        </div>`;
        return;
    }

    grid.innerHTML = kosts.map((k, i) => {
        const kelasLabel=k.kelas_label||KELAS[k.kelas]||'Ekonomi';
        const d = JSON.stringify({
            id:k.id,nama:k.nama_kost,lokasi:k.alamat_kost,harga:k.harga_kost,
            foto:k.foto_kost||'',rating:k.avg_rating||0,
            skor:k.skor_cocok||0,kelas:k.kelas,kelas_label:kelasLabel,
            tipe_kos:k.tipe_kos,tipe_kos_label:k.tipe_kos_label,
            status_label:k.status_label,luas_kamar:k.luas_kamar,
            listrik:k.listrik,ac:k.ac,kamar_mandi_dalam:k.kamar_mandi_dalam,
            parkir_motor:k.parkir_motor,laundry:k.laundry,wifi:k.wifi,
            telepon:k.nomor_telepon||'',
        }).replace(/'/g,"&#39;");
        const persen = Math.min(100, Math.round((k.skor_cocok / (meta.max_skor || 1)) * 100));
        const kelasColor = k.kelas===3?'var(--yellow)':k.kelas===2?'var(--teal)':'var(--muted)';
        return `
        <div class="kost-card-user" onclick='bukaDetail(${d})' style="${i===0?'border:2px solid var(--coral)':''}">
            ${i===0?`<div style="background:var(--coral);color:white;font-size:11px;font-weight:700;padding:4px 14px;text-align:center">🏆 PALING COCOK</div>`:''}
            <div class="kcu-img">
                ${k.foto_kost?`<img src="${k.foto_kost}" style="width:100%;height:100%;object-fit:cover">`:'<span style="font-size:48px">🏘️</span>'}
            </div>
            <div class="kcu-body">
                <div style="display:flex;align-items:center;gap:6px;margin-bottom:4px">
                    <span style="font-size:10px;font-weight:700;color:${kelasColor};background:var(--bg);padding:2px 8px;border-radius:6px;border:1px solid var(--border)">${kelasLabel}</span>
                    <span style="font-size:10px;color:var(--muted)">${k.tipe_kos_label||''}</span>
                </div>
                <div class="kcu-name">${k.nama_kost}</div>
                <div class="kcu-loc">📍 ${k.alamat_kost}</div>
                <div class="kcu-price">${formatRupiah(k.harga_kost)}<span>/bulan</span></div>
                <div style="margin-top:8px">
                    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:3px">
                        <span style="font-size:11px;color:var(--muted)">Kecocokan</span>
                        <span style="font-size:11px;font-weight:700;color:var(--coral)">${persen}%</span>
                    </div>
                    <div style="height:4px;background:var(--bg2);border-radius:100px;overflow:hidden">
                        <div style="height:100%;width:${persen}%;background:var(--coral);border-radius:100px;transition:width .6s ease"></div>
                    </div>
                </div>
            </div>
        </div>`;
    }).join('');
}

/* ─── Buka Detail Modal ─────────────────────────────── */
function bukaDetail(d) {
    predSelectedId = d.id;
    const FAS_MAP={listrik:'⚡ Listrik',ac:'❄️ AC',kamar_mandi_dalam:'🚿 KM Dalam',parkir_motor:'🏍️ Parkir',laundry:'👕 Laundry',wifi:'📶 WiFi'};
    document.getElementById('pd-foto').innerHTML   = d.foto ? `<img src="${d.foto}" style="width:100%;height:100%;object-fit:cover">` : '🏘️';
    document.getElementById('pd-nama').textContent  = d.nama;
    document.getElementById('pd-lokasi').textContent= '📍 ' + d.lokasi;
    document.getElementById('pd-harga').textContent = formatRupiah(d.harga) + '/bln';
    document.getElementById('pd-kelas').textContent = d.kelas_label || d.kelas || '—';
    document.getElementById('pd-ukuran').textContent= d.luas_kamar ? d.luas_kamar+' m²' : '—';
    document.getElementById('pd-jenis').textContent = d.tipe_kos_label || '—';
    document.getElementById('pd-skor').textContent  = `Skor: ${d.skor}`;
    document.getElementById('pd-rating').innerHTML  = `<span style="color:var(--yellow)">${renderStars(d.rating)}</span> ${parseFloat(d.rating||0).toFixed(1)}`;
    const fasAktif=Object.entries(FAS_MAP).filter(([k])=>d[k]==1).map(([,v])=>v);
    document.getElementById('pd-fasilitas').innerHTML = fasAktif.map(f=>`<span style="background:var(--bg);border:1px solid var(--border);border-radius:100px;padding:4px 10px;font-size:12px">${f}</span>`).join('') || '<span style="color:var(--muted);font-size:12px">—</span>';
    
    document.getElementById('pd-telepon').textContent = d.telepon || '-';

    // WhatsApp Link Generator
    const rawPhone = d.telepon || '';
    const cleanPhone = rawPhone.replace(/[^0-9]/g, '');
    let formattedPhone = cleanPhone;
    if (formattedPhone.startsWith('0')) {
        formattedPhone = '62' + formattedPhone.substring(1);
    } else if (formattedPhone.startsWith('8')) {
        formattedPhone = '62' + formattedPhone;
    }

    const waBtn = document.getElementById('pd-whatsapp-btn');
    const waFooterBtn = document.getElementById('pd-whatsapp-footer-btn');

    if (formattedPhone) {
        const message = `Halo, saya tertarik dengan kost ${d.nama}. Apakah masih tersedia?`;
        const url = `https://wa.me/${formattedPhone}?text=${encodeURIComponent(message)}`;
        waBtn.href = url;
        waBtn.style.display = 'inline-flex';
        
        waFooterBtn.href = url;
        waFooterBtn.style.display = 'inline-flex';
    } else {
        waBtn.style.display = 'none';
        waFooterBtn.style.display = 'none';
    }

    openModal('modal-pred-detail');
}

/* ─── Simpan Favorit ────────────────────────────────── */
async function tambahFavDariPred() {
    if (!predSelectedId) return;
    const btn = document.getElementById('btn-fav-pred');
    btn.disabled = true; btn.textContent = 'Menyimpan...';
    try {
        const res  = await fetch('/api/user/favorite', {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
            body: JSON.stringify({ kost_id: predSelectedId }),
        });
        const data = await res.json();
        if (data.success || res.status === 201) { showToast('Berhasil ditambahkan ke favorit!', '❤️'); closeModal('modal-pred-detail'); }
        else if (res.status === 409) showToast(data.message || 'Sudah ada di favorit.', '⚠️');
        else showToast(data.message || 'Gagal.', '❌');
    } catch { showToast('Kesalahan server.', '❌'); }
    finally { btn.disabled = false; btn.textContent = '❤️ Simpan Favorit'; }
}

/* Enter key trigger */
document.getElementById('pred-harga').addEventListener('keydown', e => { if (e.key === 'Enter') jalankanPrediksi(); });
</script>
@endpush
