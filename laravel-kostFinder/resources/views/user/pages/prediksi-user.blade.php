@extends('user.layouts.auth-user')
@section('title', 'Prediksi Kost')
@section('page_title', 'Prediksi Kost')

@section('content')
    <div class="page-header">
        <h2>Prediksi <em>Kost</em> 🤖</h2>
        <p>Temukan kost terbaik berdasarkan anggaran dan fasilitas yang kamu inginkan menggunakan machine learning.</p>
    </div>

    {{-- FORM PREDIKSI --}}
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:24px">

        {{-- Panel Input --}}
        <div class="widget">
            <div class="section-hd">
                <h3>🎯 Input Preferensi</h3>
            </div>

            <div class="mform-group">
                <label>Anggaran Maksimal (Rp/bulan)</label>
                <div style="position:relative">
                    <span style="position:absolute;left:13px;top:50%;transform:translateY(-50%);font-size:13px;color:var(--muted);font-weight:600;pointer-events:none">Rp</span>
                    <input type="text" id="pred-harga-max" placeholder="1.000.000" inputmode="numeric"
                        style="width:100%;background:var(--bg);border:1.5px solid var(--border);border-radius:10px;padding:10px 13px 10px 38px;font-family:'DM Sans',sans-serif;font-size:13px;color:var(--text);outline:none;transition:border-color .2s"
                        onfocus="this.style.borderColor='var(--coral)'" onblur="this.style.borderColor=''"
                        oninput="fmtHarga(this,'harga-display')" />
                </div>
                <div id="harga-display" style="font-size:11px;color:var(--coral);margin-top:4px;font-weight:600"></div>
            </div>

            <div class="mform-group">
                <label>Anggaran Minimal (Rp/bulan) <span
                        style="font-weight:400;color:var(--muted)">(opsional)</span></label>
                <div style="position:relative">
                    <span style="position:absolute;left:13px;top:50%;transform:translateY(-50%);font-size:13px;color:var(--muted);font-weight:600;pointer-events:none">Rp</span>
                    <input type="text" id="pred-harga-min" placeholder="0" inputmode="numeric"
                        style="width:100%;background:var(--bg);border:1.5px solid var(--border);border-radius:10px;padding:10px 13px 10px 38px;font-family:'DM Sans',sans-serif;font-size:13px;color:var(--text);outline:none;transition:border-color .2s"
                        onfocus="this.style.borderColor='var(--coral)'" onblur="this.style.borderColor=''"
                        oninput="fmtHarga(this,'harga-min-display')" />
                </div>
                <div id="harga-min-display" style="font-size:11px;color:var(--teal);margin-top:4px;font-weight:600"></div>
            </div>

            <div class="mform-group">
                <label>Fasilitas yang Diinginkan</label>
                <div id="fasilitas-chips" style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px;min-height:8px"></div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px">
                    @foreach(['WiFi', 'AC', 'Parkir', 'Air Panas', 'Laundry', 'Dapur', 'Kamar Mandi Dalam', 'CCTV', 'Kulkas', 'TV'] as $fas)
                        <label
                            style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13px;font-weight:500;background:var(--bg);border:1.5px solid var(--border);border-radius:10px;padding:9px 12px;transition:all .15s;user-select:none"
                            class="fas-opt">
                            <input type="checkbox" value="{{ $fas }}" onchange="updateFasilitasChips()"
                                style="accent-color:var(--coral);width:15px;height:15px;flex-shrink:0" />
                            {{ $fas }}
                        </label>
                    @endforeach
                </div>
            </div>

            <div class="mform-group">
                <label>Kelas Kost</label>
                <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:8px">
                    @foreach(['Semua', 'Ekonomis', 'Standar', 'Premium'] as $k)
                        <label style="cursor:pointer">
                            <input type="radio" name="pred-kelas" value="{{ $k === 'Semua' ? '' : $k }}" {{ $k === 'Semua' ? 'checked' : '' }} style="display:none" class="kelas-radio" />
                            <span class="btn-sm kelas-btn"
                                style="{{ $k === 'Semua' ? 'background:var(--coral);color:white;border-color:var(--coral)' : '' }}">{{ $k }}</span>
                        </label>
                    @endforeach
                </div>
            </div>

            <button class="btn-sm primary" id="btn-prediksi" onclick="jalankanPrediksi()" style="width:100%;padding:12px">
                <span id="btn-pred-label">🤖 Prediksi Kost Untukku</span>
            </button>
            <div id="pred-error" class="form-error-msg" style="display:none;margin-top:10px"></div>
        </div>

        {{-- Panel Penjelasan --}}
        <div class="widget" style="background:linear-gradient(135deg,rgba(232,67,13,.04),rgba(0,143,120,.04))">
            <div class="section-hd">
                <h3>📊 Cara Kerja Prediksi</h3>
            </div>
            <div style="display:flex;flex-direction:column;gap:14px;font-size:13px">
                <div style="display:flex;gap:10px;align-items:flex-start">
                    <div
                        style="width:28px;height:28px;border-radius:8px;background:var(--coral-bg);color:var(--coral);display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0">
                        1</div>
                    <div><strong>Analisis Harga</strong><br><span style="color:var(--muted)">Model menghitung korelasi
                            antara harga dan fasilitas dari seluruh data kost.</span></div>
                </div>
                <div style="display:flex;gap:10px;align-items:flex-start">
                    <div
                        style="width:28px;height:28px;border-radius:8px;background:var(--teal-bg);color:var(--teal);display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0">
                        2</div>
                    <div><strong>Skor Kesesuaian</strong><br><span style="color:var(--muted)">Setiap kost diberi skor
                            berdasarkan kecocokan fasilitas dan rentang hargamu.</span></div>
                </div>
                <div style="display:flex;gap:10px;align-items:flex-start">
                    <div
                        style="width:28px;height:28px;border-radius:8px;background:var(--yellow-bg);color:var(--yellow);display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0">
                        3</div>
                    <div><strong>Rekomendasi</strong><br><span style="color:var(--muted)">Ditampilkan kost dengan skor
                            tertinggi yang paling cocok dengan preferensimu.</span></div>
                </div>
            </div>

            <div
                style="margin-top:20px;padding:14px;background:var(--bg);border-radius:10px;border:1px solid var(--border)">
                <div
                    style="font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:8px">
                    📈 Statistik Dataset</div>
                <div id="pred-stats" style="font-size:13px;color:var(--muted)">Memuat statistik...</div>
            </div>
        </div>
    </div>

    {{-- HASIL PREDIKSI --}}
    <div id="pred-hasil-wrap" style="display:none">
        <div class="widget">
            <div class="section-hd">
                <h3>🎯 Hasil Prediksi</h3>
                <span id="pred-hasil-count" style="font-size:12px;color:var(--muted)"></span>
            </div>
            <div class="kost-grid-user" id="pred-hasil-grid"></div>
        </div>
    </div>

    {{-- MODAL DETAIL --}}
    <div class="modal-overlay" id="modal-pred-detail" onclick="closeModalOutside(event,this)">
        <div class="modal-box" style="max-width:520px">
            <div class="modal-header">
                <h3>🏘️ Detail Kost</h3><button class="modal-close" onclick="closeModal('modal-pred-detail')">✕</button>
            </div>
            <div class="modal-body">
                <div id="pd-foto"
                    style="height:180px;border-radius:12px;overflow:hidden;margin-bottom:16px;background:var(--bg2);display:flex;align-items:center;justify-content:center;font-size:56px">
                </div>
                <div
                    style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:14px;padding-bottom:14px;border-bottom:1px solid var(--border)">
                    <div>
                        <div id="pd-nama" style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800"></div>
                        <div id="pd-lokasi" style="font-size:12px;color:var(--muted);margin-top:3px"></div>
                    </div>
                    <span id="pd-skor"
                        style="background:var(--coral-bg);color:var(--coral);padding:4px 12px;border-radius:100px;font-size:12px;font-weight:700"></span>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px">
                    <div style="background:var(--bg);border-radius:10px;padding:12px">
                        <div style="font-size:11px;color:var(--muted);font-weight:600;text-transform:uppercase">Harga</div>
                        <div id="pd-harga"
                            style="font-family:'Syne',sans-serif;font-size:17px;font-weight:800;color:var(--coral)"></div>
                    </div>
                    <div style="background:var(--bg);border-radius:10px;padding:12px">
                        <div style="font-size:11px;color:var(--muted);font-weight:600;text-transform:uppercase">Rating</div>
                        <div id="pd-rating" style="font-size:16px;margin-top:2px"></div>
                    </div>
                </div>
                <div id="pd-fasilitas" style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:14px"></div>
            </div>
            <div class="modal-footer">
                <button class="btn-sm" onclick="closeModal('modal-pred-detail')">Tutup</button>
                <button class="btn-sm primary" id="btn-fav-pred" onclick="tambahFavDariPred()">❤️ Simpan Favorit</button>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        let predSelectedId = null;

        /* Kelas radio interaktif */
        document.querySelectorAll('.kelas-radio').forEach(r => {
            r.addEventListener('change', () => {
                document.querySelectorAll('.kelas-btn').forEach(b => {
                    b.style.background = ''; b.style.color = ''; b.style.borderColor = '';
                });
                r.nextElementSibling.style.background = 'var(--coral)';
                r.nextElementSibling.style.color = 'white';
                r.nextElementSibling.style.borderColor = 'var(--coral)';
            });
        });

        /* Update chips fasilitas yang dipilih */
        function updateFasilitasChips() {
            const selected = [...document.querySelectorAll('.fas-opt input:checked')].map(i => i.value);
            document.getElementById('fasilitas-chips').innerHTML = selected.map(f =>
                `<span style="background:var(--coral-bg);color:var(--coral);padding:3px 10px;border-radius:100px;font-size:12px;font-weight:600">${f}</span>`
            ).join('');
        }

        /* Format harga saat input */
        /* Format harga saat input — ganti event listeners lama */
        function fmtHarga(el, displayId) {
            const raw = el.value.replace(/\D/g, '');
            el.value = raw ? Number(raw).toLocaleString('id-ID') : '';
            const n = parseInt(raw) || 0;
            const dispEl = document.getElementById(displayId);
            if (dispEl) dispEl.textContent = n > 0 ? '≈ ' + formatRupiah(n) + '/bulan' : '';
        }
        function getRawHarga(id) {
            return parseInt((document.getElementById(id).value || '').replace(/\./g, '').replace(/,/g, '')) || 0;
        }

        /* Load statistik dataset */
        async function loadStats() {
            try {
                const res = await fetch('/api/user/prediksi/stats');
                const result = await res.json();
                const el = document.getElementById('pred-stats');
                if (result.success) {
                    const d = result.data;
                    el.innerHTML = `
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px">
                    <div><span style="font-weight:700;color:var(--text)">${d.total_kost}</span> kost aktif</div>
                    <div><span style="font-weight:700;color:var(--text)">${formatRupiah(d.harga_min)}</span> min</div>
                    <div><span style="font-weight:700;color:var(--text)">${formatRupiah(d.harga_max)}</span> maks</div>
                    <div><span style="font-weight:700;color:var(--text)">${formatRupiah(d.harga_avg)}</span> rata-rata</div>
                </div>`;
                }
            } catch (err) { document.getElementById('pred-stats').textContent = 'Gagal memuat.'; }
        }

        document.addEventListener('DOMContentLoaded', loadStats);

        /* Jalankan prediksi */
        async function jalankanPrediksi() {
            const hargaMax = getRawHarga('pred-harga-max');
            const hargaMin = getRawHarga('pred-harga-min');
            const fasilitas = [...document.querySelectorAll('.fas-opt input:checked')].map(i => i.value);
            const kelas = document.querySelector('input[name="pred-kelas"]:checked')?.value || '';
            const errorEl = document.getElementById('pred-error');

            if (!hargaMax) { errorEl.textContent = 'Masukkan anggaran maksimal terlebih dahulu.'; errorEl.style.display = 'block'; return; }

            errorEl.style.display = 'none';
            const btn = document.getElementById('btn-prediksi');
            const label = document.getElementById('btn-pred-label');
            btn.disabled = true; label.textContent = '⏳ Menganalisis...';

            try {
                const res = await fetch('/api/user/prediksi', {
                    method: 'POST',
                    headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                    body: JSON.stringify({ harga_max: hargaMax, harga_min: hargaMin, fasilitas, kelas }),
                });
                const data = await res.json();

                if (data.success) {
                    tampilkanHasil(data.data, data.meta ?? {});
                } else {
                    errorEl.textContent = data.message || 'Prediksi gagal.';
                    errorEl.style.display = 'block';
                }
            } catch (err) {
                errorEl.textContent = 'Kesalahan server.'; errorEl.style.display = 'block';
            } finally {
                btn.disabled = false; label.textContent = '🤖 Prediksi Kost Untukku';
            }
        }

        function tampilkanHasil(kosts, meta) {
            const wrap = document.getElementById('pred-hasil-wrap');
            const grid = document.getElementById('pred-hasil-grid');
            const count = document.getElementById('pred-hasil-count');

            wrap.style.display = 'block';
            wrap.scrollIntoView({ behavior: 'smooth', block: 'start' });
            count.textContent = `${kosts.length} kost ditemukan`;

            if (!kosts.length) {
                grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:40px;color:var(--muted)">Tidak ada kost yang cocok. Coba perluas kriteria pencarianmu.</div>';
                return;
            }

            grid.innerHTML = kosts.map((k, i) => {
                const d = JSON.stringify({ id: k.id, nama: k.nama_kost, lokasi: k.alamat_kost, harga: k.harga_kost, foto: k.foto_kost || '', rating: k.avg_rating || 0, fasilitas: k.fasilitas || '', skor: k.skor_cocok || 0 }).replace(/'/g, "&#39;");
                const persen = Math.min(100, Math.round((k.skor_cocok / (meta.max_skor || 1)) * 100));
                return `
            <div class="kost-card-user" onclick='openDetailPred(${d})' style="${i === 0 ? 'border:2px solid var(--coral)' : ''}">
                ${i === 0 ? `<div style="background:var(--coral);color:white;font-size:11px;font-weight:700;padding:4px 14px;text-align:center">🏆 PALING COCOK</div>` : ''}
                <div class="kcu-img">
                    ${k.foto_kost ? `<img src="${k.foto_kost}" style="width:100%;height:100%;object-fit:cover;">` : '<span style="font-size:48px">🏘️</span>'}
                </div>
                <div class="kcu-body">
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

        function openDetailPred(d) {
            predSelectedId = d.id;
            document.getElementById('pd-foto').innerHTML = d.foto ? `<img src="${d.foto}" style="width:100%;height:100%;object-fit:cover;">` : '🏘️';
            document.getElementById('pd-nama').textContent = d.nama;
            document.getElementById('pd-lokasi').textContent = '📍 ' + d.lokasi;
            document.getElementById('pd-harga').textContent = formatRupiah(d.harga) + '/bln';
            document.getElementById('pd-rating').innerHTML = `<span style="color:var(--yellow)">${renderStars(d.rating)}</span> ${parseFloat(d.rating || 0).toFixed(1)}`;
            document.getElementById('pd-skor').textContent = `Skor: ${d.skor}`;
            const tags = (d.fasilitas || '').split(',').map(f => f.trim()).filter(Boolean);
            document.getElementById('pd-fasilitas').innerHTML = tags.map(f => `<span style="background:var(--bg);border:1px solid var(--border);border-radius:100px;padding:4px 10px;font-size:12px">${f}</span>`).join('') || '<span style="color:var(--muted);font-size:12px">-</span>';
            openModal('modal-pred-detail');
        }

        async function tambahFavDariPred() {
            if (!predSelectedId) return;
            const btn = document.getElementById('btn-fav-pred');
            btn.disabled = true; btn.textContent = 'Menyimpan...';
            try {
                const res = await fetch('/api/user/favorite', {
                    method: 'POST',
                    headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                    body: JSON.stringify({ kost_id: predSelectedId }),
                });
                const data = await res.json();
                if (data.success || res.status === 201) { showToast('Berhasil ditambahkan ke favorit!', '❤️'); closeModal('modal-pred-detail'); }
                else if (res.status === 409) showToast(data.message || 'Sudah ada di favorit.', '⚠️');
                else showToast(data.message || 'Gagal.', '❌');
            } catch (err) { showToast('Kesalahan server.', '❌'); }
            finally { btn.disabled = false; btn.textContent = '❤️ Simpan Favorit'; }
        }
    </script>
@endpush
