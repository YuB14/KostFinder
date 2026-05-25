<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Models\Kost;
use App\Models\Review;
use App\Models\Favorite;
use App\Http\Resources\KostResource;
use App\Http\Resources\ReviewResource;
use App\Http\Resources\FavoriteResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class UserApiController extends Controller
{
    // ── Helper: ambil user_id dari session ──
    private function userId(): string
    {
        return (string) (Auth::id() ?? '');
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/stats
    // status >= 1 artinya tersedia (1=tersedia, >=2=sisa kamar)
    // ═══════════════════════════════════════════════════════
    public function stats()
    {
        $uid = $this->userId();

        $totalFavorit = $uid ? Favorite::where('user_id', $uid)->count() : 0;
        $totalReview  = $uid ? Review::where('user_id', $uid)->count()   : 0;
        $totalKost    = Kost::count();

        return response()->json([
            'success' => true,
            'data'    => [
                'total_favorit' => $totalFavorit,
                'total_review'  => $totalReview,
                'total_kost'    => $totalKost,
            ],
        ]);
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/kost — daftar kost
    // ═══════════════════════════════════════════════════════
    public function kostIndex()
    {
        $kosts = Kost::with(['reviews', 'wilayah'])->get();

        return response()->json([
            'success' => true,
            'data'    => KostResource::collection($kosts),
        ]);
    }

    // GET /api/user/kost/{id}/reviews
    public function kostReviews($id)
    {
        $reviews = Review::with(['user', 'kost'])
            ->where('kost_id', $id)
            ->where('status', 'Disetujui')
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data'    => ReviewResource::collection($reviews),
        ]);
    }

    // ═══════════════════════════════════════════════════════
    // Review CRUD
    // ═══════════════════════════════════════════════════════
    public function reviewIndex()
    {
        $uid = $this->userId();
        if (!$uid) return response()->json(['success' => true, 'data' => []]);

        $reviews = Review::with(['user', 'kost'])->where('user_id', $uid)->latest()->get();

        return response()->json([
            'success' => true,
            'data'    => ReviewResource::collection($reviews),
        ]);
    }

    public function reviewStore(Request $request)
    {
        $request->validate([
            'kost_id'  => 'required|string',
            'rating'   => 'required|integer|min:1|max:5',
            'komentar' => 'required|string|max:1000',
        ]);

        $review = Review::create([
            'user_id'  => $this->userId(),
            'kost_id'  => $request->kost_id,
            'rating'   => (int) $request->rating,
            'komentar' => $request->komentar,
            'status'   => 'Menunggu',
        ]);

        $review->load(['user', 'kost']);

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil ditambahkan.',
            'data'    => new ReviewResource($review),
        ], 201);
    }

    public function reviewUpdate(Request $request, $id)
    {
        $uid    = $this->userId();
        $review = Review::with(['user', 'kost'])->find($id);

        if (!$review) return response()->json(['success' => false, 'message' => 'Ulasan tidak ditemukan.'], 404);
        if ($uid && (string) ($review->user_id ?? '') !== $uid) {
            return response()->json(['success' => false, 'message' => 'Tidak diizinkan.'], 403);
        }

        $request->validate([
            'rating'   => 'required|integer|min:1|max:5',
            'komentar' => 'required|string|max:1000',
        ]);

        $review->rating   = (int) $request->rating;
        $review->komentar = $request->komentar;
        $review->status   = 'Menunggu';
        $review->save();

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil diperbarui.',
            'data'    => new ReviewResource($review),
        ]);
    }

    // ═══════════════════════════════════════════════════════
    // Favorite CRUD
    // ═══════════════════════════════════════════════════════
    public function favoriteIndex()
    {
        $uid = $this->userId();
        if (!$uid) return response()->json(['success' => true, 'data' => []]);

        $favorites = Favorite::with(['user', 'kost'])->where('user_id', $uid)->latest()->get();

        return response()->json([
            'success' => true,
            'data'    => FavoriteResource::collection($favorites),
        ]);
    }

    public function favoriteStore(Request $request)
    {
        $request->validate(['kost_id' => 'required|string']);
        $uid    = $this->userId();
        $kostId = $request->kost_id;

        if ($uid && Favorite::where('user_id', $uid)->where('kost_id', $kostId)->exists()) {
            return response()->json(['success' => false, 'message' => 'Kost sudah ada di favorit.'], 409);
        }

        $favorite = Favorite::create(['user_id' => $uid, 'kost_id' => $kostId]);
        $favorite->load(['user', 'kost']);

        return response()->json([
            'success' => true,
            'message' => 'Berhasil ditambahkan ke favorit.',
            'data'    => new FavoriteResource($favorite),
        ], 201);
    }

    public function favoriteDestroy($id)
    {
        $uid      = $this->userId();
        $favorite = Favorite::find($id);

        if (!$favorite) return response()->json(['success' => false, 'message' => 'Favorit tidak ditemukan.'], 404);
        if ($uid && (string) ($favorite->user_id ?? '') !== $uid) {
            return response()->json(['success' => false, 'message' => 'Tidak diizinkan.'], 403);
        }

        $favorite->delete();
        return response()->json(['success' => true, 'message' => 'Favorit berhasil dihapus.']);
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/prediksi/stats — statistik dataset
    // ═══════════════════════════════════════════════════════
    public function prediksiStats()
    {
        $kosts = Kost::all();
        $total = $kosts->count();

        if ($total === 0) {
            return response()->json([
                'success' => true,
                'data'    => ['total_kost' => 0, 'harga_min' => 0, 'harga_max' => 0, 'harga_avg' => 0],
            ]);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'total_kost' => $total,
                'harga_min'  => (int) $kosts->min('harga_kost'),
                'harga_max'  => (int) $kosts->max('harga_kost'),
                'harga_avg'  => (int) $kosts->avg('harga_kost'),
            ],
        ]);
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/prediksi/health — cek status Flask ML
    // ═══════════════════════════════════════════════════════
    public function prediksiHealth()
    {
        $flaskUrl = env('FLASK_ML_URL', 'http://127.0.0.1:5000');

        try {
            $response = Http::timeout(5)->get("{$flaskUrl}/health");

            if ($response->successful()) {
                $body = $response->json();
                return response()->json([
                    'success'       => true,
                    'flask_status'  => 'online',
                    'model_trained' => $body['model_trained'] ?? false,
                    'flask_url'     => $flaskUrl,
                ]);
            }

            return response()->json([
                'success'      => false,
                'flask_status' => 'offline',
                'message'      => 'Flask ML tidak merespon dengan benar.',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success'      => false,
                'flask_status' => 'offline',
                'message'      => 'Server ML (Flask) tidak aktif. Jalankan: python app.py',
            ]);
        }
    }

    // ═══════════════════════════════════════════════════════
    // POST /api/user/prediksi
    //
    // Input  : { harga: float }
    // Proses :
    //   1. Forward harga ke Flask ML (/predict) — WAJIB aktif
    //   2. Flask return prediksi numerik
    //   3. Query kost sesuai kelas & range harga, beri skor
    //   4. Return: { prediksi, rekomendasi_kost }
    //
    // CATATAN: Tidak ada fallback rule-based.
    //          Jika Flask mati, return error.
    // ═══════════════════════════════════════════════════════
    public function prediksi(Request $request)
    {
        $request->validate(['harga' => 'required|numeric|min:1000']);

        $harga    = (float) $request->harga;
        $flaskUrl = env('FLASK_ML_URL', 'http://127.0.0.1:5000');

        // ── 1. Panggil Flask ML (WAJIB aktif) ────────────────
        $prediksi       = null;
        $sumberPrediksi = 'flask_ml';

        try {
            $flaskResponse = Http::timeout(8)->post("{$flaskUrl}/predict", [
                'harga' => $harga,
            ]);

            if ($flaskResponse->successful()) {
                $body = $flaskResponse->json();
                if (!empty($body['success']) && !empty($body['data'])) {
                    $prediksi       = $body['data'];
                    $sumberPrediksi = $body['data']['source'] ?? 'flask_ml';
                } else {
                    return response()->json([
                        'success' => false,
                        'message' => 'Flask ML mengembalikan respons tidak valid.',
                    ], 502);
                }
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Flask ML mengembalikan error (HTTP ' . $flaskResponse->status() . ').',
                ], 502);
            }
        } catch (\Exception $e) {
            Log::warning('[Prediksi] Flask ML tidak tersedia: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Server ML (Flask) tidak aktif. Silakan jalankan python app.py terlebih dahulu.',
            ], 503);
        }

        // ── 2. Mapping numerik → label display ───────────────
        $tipeKosLabels = Kost::tipeKosLabel();
        $kelasLabels   = Kost::kelasLabel();
        $lokasiLabels  = Kost::kodeLokasiLabel();

        $prediksi['kelas_label']    = $kelasLabels[(int) ($prediksi['kelas'] ?? 1)]         ?? 'Ekonomi';
        $prediksi['tipe_kos_label'] = $tipeKosLabels[(int) ($prediksi['tipe_kos'] ?? 3)]    ?? 'Campur';
        $prediksi['status_label']   = Kost::statusLabel((int) ($prediksi['status']  ?? 1));
        $prediksi['lokasi_label']   = $lokasiLabels[(int) ($prediksi['kode_lokasi'] ?? 1)]  ?? '';

        // ── 3. Query kost cocok (kelas cocok, range harga ±35%) ──
        $margin   = 0.35;
        $hargaMin = $harga * (1 - $margin);
        $hargaMax = $harga * (1 + $margin);

        $kelasPred = (int) ($prediksi['kelas'] ?? 0);
        $query     = Kost::with('reviews');
        if ($kelasPred > 0) {
            $query->where('kelas', $kelasPred);
        }

        $kosts = $query->get()->filter(function ($k) use ($hargaMin, $hargaMax) {
            $h = (float) ($k->harga_kost ?? 0);
            return $h >= $hargaMin && $h <= $hargaMax;
        });

        // ── 4. Scoring ────────────────────────────────────────
        $tipeKosPred = (int) ($prediksi['tipe_kos']    ?? 0);
        $fasBinary   = [
            'listrik'           => (int) ($prediksi['listrik']           ?? 0),
            'ac'                => (int) ($prediksi['ac']                ?? 0),
            'kamar_mandi_dalam' => (int) ($prediksi['kamar_mandi_dalam'] ?? 0),
            'parkir_motor'      => (int) ($prediksi['parkir_motor']      ?? 0),
            'laundry'           => (int) ($prediksi['laundry']           ?? 0),
            'wifi'              => (int) ($prediksi['wifi']              ?? 0),
        ];

        $scored = $kosts->map(function ($k) use ($harga, $fasBinary, $tipeKosPred, $kelasLabels, $tipeKosLabels, $lokasiLabels) {
            $id = (string) ($k->_id ?? $k->id ?? '');

            $skorFas = 0;
            foreach ($fasBinary as $fasKey => $fasVal) {
                if ($fasVal === 1 && (int) ($k->$fasKey ?? 0) === 1) $skorFas += 8;
            }

            $h         = (float) ($k->harga_kost ?? 0);
            $skorHarga = $harga > 0 ? max(0, (1 - abs($h - $harga) / max($harga, 1)) * 50) : 0;

            $skorTipe = ($tipeKosPred > 0 && (int) ($k->tipe_kos ?? 0) === $tipeKosPred) ? 10 : 0;

            $reviews     = $k->reviews ?? collect();
            $reviewCount = is_countable($reviews) ? count($reviews) : 0;
            $avgRating   = $reviewCount > 0 ? round(collect($reviews)->avg('rating'), 2) : 0;
            $skorRating  = $avgRating * 5;

            $total = round($skorFas + $skorHarga + $skorTipe + $skorRating, 2);

            $foto = $k->foto_kost;
            if ($foto && !str_starts_with((string) $foto, 'http')) {
                $foto = asset('storage/' . $foto);
            }

            $kelasInt   = (int) ($k->kelas    ?? 1);
            $tipeKosInt = (int) ($k->tipe_kos ?? 3);
            $lokasiInt  = (int) ($k->kode_lokasi ?? 1);
            $statusInt  = (int) ($k->status   ?? 1);

            return [
                'id'                => $id,
                'nama_kost'         => (string) ($k->nama_kost     ?? ''),
                'foto_kost'         => $foto,
                'alamat_kost'       => (string) ($k->alamat_kost   ?? ''),
                'kelas'             => $kelasInt,
                'kelas_label'       => $kelasLabels[$kelasInt]      ?? 'Ekonomi',
                'tipe_kos'          => $tipeKosInt,
                'tipe_kos_label'    => $tipeKosLabels[$tipeKosInt]  ?? 'Campur',
                'status'            => $statusInt,
                'status_label'      => Kost::statusLabel($statusInt),
                'kode_lokasi'       => $lokasiInt,
                'lokasi_label'      => $lokasiLabels[$lokasiInt]    ?? '',
                'luas_kamar'        => (float) ($k->luas_kamar      ?? 0),
                'harga_kost'        => (float) ($k->harga_kost      ?? 0),
                'listrik'           => (int) ($k->listrik           ?? 0),
                'ac'                => (int) ($k->ac                ?? 0),
                'kamar_mandi_dalam' => (int) ($k->kamar_mandi_dalam ?? 0),
                'parkir_motor'      => (int) ($k->parkir_motor      ?? 0),
                'laundry'           => (int) ($k->laundry           ?? 0),
                'wifi'              => (int) ($k->wifi              ?? 0),
                'nomor_telepon'     => (string) ($k->nomor_telepon  ?? ''),
                'avg_rating'        => $avgRating,
                'reviews_count'     => $reviewCount,
                'skor_cocok'        => $total,
            ];
        });

        $result  = $scored->sortByDesc('skor_cocok')->take(8)->values();
        $maxSkor = $result->max('skor_cocok') ?: 1;

        return response()->json([
            'success'  => true,
            'prediksi' => $prediksi,
            'sumber'   => $sumberPrediksi,
            'data'     => $result,
            'meta'     => ['max_skor' => $maxSkor, 'total_cocok' => $kosts->count()],
        ]);
    }
}
