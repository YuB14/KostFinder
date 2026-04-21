@extends('layouts.admin')

@section('page_title', 'Ulasan')

@section('title', 'Manajemen Ulasan')

@section('content')
<div class="page active" id="page-review">
    <div class="page-header">
        <h2>Manajemen <em>Ulasan</em></h2>
        <p>Pantau dan moderasi ulasan pengguna pada seluruh kost.</p>
    </div>

    {{-- Statistik Ulasan --}}
    <div class="stats-grid">
        <div class="stat-card yellow">
            <div class="stat-icon-wrap yellow">⭐</div>
            <div class="stat-value">214</div>
            <div class="stat-label">Total Ulasan</div>
        </div>
        <div class="stat-card teal">
            <div class="stat-icon-wrap teal">✅</div>
            <div class="stat-value">198</div>
            <div class="stat-label">Disetujui</div>
        </div>
        <div class="stat-card coral">
            <div class="stat-icon-wrap coral">⏳</div>
            <div class="stat-value">12</div>
            <div class="stat-label">Menunggu</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-icon-wrap blue">🚫</div>
            <div class="stat-value">4</div>
            <div class="stat-label">Ditolak</div>
        </div>
    </div>

    {{-- Grid Ulasan --}}
    <div class="review-grid">
        {{-- Card 1 --}}
        <div class="review-card">
            <div class="rv-header">
                <div class="rv-user">
                    <div class="rv-avatar" style="background:linear-gradient(135deg,#E8430D,#FF6B3D)">AR</div>
                    <div>
                        <div class="rv-name">Aini Rahmawati</div>
                        <div class="rv-kost">Kost Residence 88</div>
                    </div>
                </div>
                <div class="rv-stars">★★★★★</div>
            </div>
            <div class="rv-text">"Kost terbaik! Fasilitas lengkap, pemilik ramah, dan lingkungan sangat bersih. Sangat worth it dengan harganya."</div>
            <div class="rv-footer">
                <div class="rv-date">12 Mar 2025</div>
                <span class="pill green">✅ Disetujui</span>
            </div>
        </div>

        {{-- Card 2 --}}
        <div class="review-card">
            <div class="rv-header">
                <div class="rv-user">
                    <div class="rv-avatar" style="background:linear-gradient(135deg,#008F78,#00C9A7)">BS</div>
                    <div>
                        <div class="rv-name">Budi Santoso</div>
                        <div class="rv-kost">Kost Griya Asri</div>
                    </div>
                </div>
                <div class="rv-stars">★★★★☆</div>
            </div>
            <div class="rv-text">"Lokasi strategis dekat kampus, WiFi kencang, kamar bersih. Hanya AC terkadang sedikit berisik, tapi overall sangat memuaskan!"</div>
            <div class="rv-footer">
                <div class="rv-date">5 Mar 2025</div>
                <span class="pill green">✅ Disetujui</span>
            </div>
        </div>

        {{-- Card 3 --}}
        <div class="review-card">
            <div class="rv-header">
                <div class="rv-user">
                    <div class="rv-avatar" style="background:linear-gradient(135deg,#D48D00,#F6C244)">DS</div>
                    <div>
                        <div class="rv-name">Dewi Sartika</div>
                        <div class="rv-kost">Kost Villa Elok</div>
                    </div>
                </div>
                <div class="rv-stars">★★★★★</div>
            </div>
            <div class="rv-text">"Benar-benar seperti hotel! Kolam renang, gym, cleaning service setiap hari. Harga tinggi tapi sepadan banget!"</div>
            <div class="rv-footer">
                <div class="rv-date">28 Feb 2025</div>
                <span class="pill yellow">⏳ Menunggu</span>
            </div>
        </div>

        {{-- Kamu bisa menambahkan sisa card lainnya di sini --}}
    </div>
</div>
@endsection

@push('scripts')
<script>
    console.log('Halaman Ulasan dimuat');
</script>
@endpush
