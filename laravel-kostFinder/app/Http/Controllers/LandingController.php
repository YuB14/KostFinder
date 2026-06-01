<?php

namespace App\Http\Controllers;

use App\Models\Kost;
use App\Models\Wilayah;
use App\Models\Favorite;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LandingController extends Controller
{
    /**
     * Landing page — tampilkan data kost dari database.
     */
    public function index()
    {
        // 6 kost terbaru
        $latestKosts = Kost::with(['reviews', 'favorites', 'wilayah'])
            ->latest()
            ->take(6)
            ->get()
            ->map(fn($k) => $this->transformKost($k));

        // 6 kost paling banyak difavoritkan
        // Ambil kost_id dengan favorites terbanyak
        $topFavIds = Favorite::raw(function ($collection) {
            return $collection->aggregate([
                ['$group' => ['_id' => '$kost_id', 'count' => ['$sum' => 1]]],
                ['$sort'  => ['count' => -1]],
                ['$limit' => 6],
            ]);
        });

        $favIdList = collect($topFavIds)->pluck('_id')->filter()->toArray();

        if (!empty($favIdList)) {
            $favoritKosts = Kost::with(['reviews', 'favorites', 'wilayah'])
                ->whereIn('_id', $favIdList)
                ->get()
                ->sortByDesc(fn($k) => $k->favorites->count())
                ->take(6)
                ->values()
                ->map(fn($k) => $this->transformKost($k));
        } else {
            // Fallback: jika belum ada favorit, tampilkan kost dengan rating terbaik
            $favoritKosts = Kost::with(['reviews', 'favorites', 'wilayah'])
                ->get()
                ->sortByDesc(function ($k) {
                    $reviews = $k->reviews ?? collect();
                    return $reviews->count() > 0 ? $reviews->avg('rating') : 0;
                })
                ->take(6)
                ->values()
                ->map(fn($k) => $this->transformKost($k));
        }

        // Daftar wilayah untuk dropdown search
        $wilayahList = Wilayah::orderBy('nama_wilayah')->get();

        // Statistik
        $totalKost  = Kost::count();
        $totalUsers = \App\Models\User::count();

        return view('index', compact(
            'latestKosts',
            'favoritKosts',
            'wilayahList',
            'totalKost',
            'totalUsers'
        ));
    }

    /**
     * Search kost berdasarkan nama + wilayah.
     * Mengembalikan 3 kost terfavorit/rating terbaik.
     */
    public function search(Request $request)
    {
        $nama      = $request->input('nama', '');
        $wilayahId = $request->input('wilayah_id', '');

        $query = Kost::with(['reviews', 'favorites', 'wilayah']);

        // Filter nama (case-insensitive regex)
        if (!empty($nama)) {
            $query->where('nama_kost', 'regex', '/' . preg_quote($nama, '/') . '/i');
        }

        // Filter wilayah
        if (!empty($wilayahId)) {
            $query->where('wilayah_id', $wilayahId);
        }

        $results = $query->get();

        // Sort: favorit terbanyak → rating tertinggi → review terbanyak
        $sorted = $results->sortByDesc(function ($k) {
            $favCount    = $k->favorites ? $k->favorites->count() : 0;
            $reviews     = $k->reviews ?? collect();
            $avgRating   = $reviews->count() > 0 ? $reviews->avg('rating') : 0;
            $reviewCount = $reviews->count();
            // Composite score: favorit * 1000 + rating * 100 + reviewCount
            return ($favCount * 1000) + ($avgRating * 100) + $reviewCount;
        })->take(3)->values();

        $data = $sorted->map(fn($k) => $this->transformKost($k));

        return response()->json([
            'success'       => true,
            'data'          => $data,
            'total_found'   => $results->count(),
            'loginRequired' => true,
            'loginMessage'  => 'Ingin mencari lebih banyak kost dan menggunakan fitur prediksi harga AI? Silakan login atau daftar terlebih dahulu.',
        ]);
    }

    /**
     * Transform model Kost menjadi array untuk view/JSON.
     */
    private function transformKost(Kost $k): array
    {
        $reviews     = $k->reviews ?? collect();
        $avgRating   = $reviews->count() > 0 ? round($reviews->avg('rating'), 1) : 0;
        $reviewCount = $reviews->count();
        $favCount    = $k->favorites ? $k->favorites->count() : 0;

        // Foto
        $foto = $k->foto_kost ?? null;
        if ($foto && !str_starts_with((string) $foto, 'http')) {
            $foto = asset('storage/' . $foto);
        }

        // Fasilitas list
        $fasilitas = [];
        if ($k->wifi)               $fasilitas[] = 'WiFi';
        if ($k->ac)                 $fasilitas[] = 'AC';
        if ($k->kamar_mandi_dalam)  $fasilitas[] = 'KM Dalam';
        if ($k->parkir_motor)       $fasilitas[] = 'Parkir Motor';
        if ($k->laundry)            $fasilitas[] = 'Laundry';
        if ($k->listrik)            $fasilitas[] = 'Listrik';

        // Kelas label
        $kelasLabels = [1 => 'Ekonomi', 2 => 'Standar', 3 => 'Premium'];
        $kelasLabel  = $kelasLabels[$k->kelas ?? 1] ?? 'Ekonomi';

        // Tipe kos label
        $tipeLabels = [1 => 'Pria', 2 => 'Wanita', 3 => 'Campur'];
        $tipeLabel  = $tipeLabels[$k->tipe_kos ?? 3] ?? 'Campur';

        // Status label
        $statusVal = (int) ($k->status ?? 1);
        if ($statusVal === 0) $statusLabel = 'Penuh';
        elseif ($statusVal === 1) $statusLabel = 'Tersedia';
        else $statusLabel = $statusVal . ' kamar tersisa';

        // Badge
        if ($favCount >= 5) $badge = 'Populer';
        elseif ($statusVal === 0) $badge = 'Penuh';
        elseif ($k->kelas == 3) $badge = 'Premium';
        else $badge = $statusLabel;

        // Emoji fallback berdasarkan kelas
        $emojiMap = [1 => '🏠', 2 => '🏡', 3 => '🏢'];
        $emoji = $emojiMap[$k->kelas ?? 1] ?? '🏠';

        return [
            'id'            => (string) ($k->_id ?? $k->id),
            'nama_kost'     => $k->nama_kost ?? '',
            'foto_kost'     => $foto,
            'alamat_kost'   => $k->alamat_kost ?? '',
            'harga_kost'    => (float) ($k->harga_kost ?? 0),
            'kelas'         => (int) ($k->kelas ?? 1),
            'kelas_label'   => $kelasLabel,
            'tipe_label'    => $tipeLabel,
            'status'        => $statusVal,
            'status_label'  => $statusLabel,
            'badge'         => $badge,
            'emoji'         => $emoji,
            'wilayah_nama'  => $k->wilayah->nama_wilayah ?? '-',
            'fasilitas'     => $fasilitas,
            'avg_rating'    => $avgRating,
            'review_count'  => $reviewCount,
            'fav_count'     => $favCount,
        ];
    }
}
