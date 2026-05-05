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
    // POST /api/user/prediksi
    //
    // Input  : { harga: float }
    // Proses :
    //   1. Bangun feature vector dari harga (rule-based fallback values)
    //   2. Forward feature_vector ke Flask ML (/predict)
    //   3. Flask return prediksi numerik
    //   4. Query kost sesuai kelas & range harga, beri skor
    //   5. Return: { prediksi, rekomendasi_kost }
    // ═══════════════════════════════════════════════════════
    public function prediksi(Request $request)
    {
        $request->validate(['harga' => 'required|numeric|min:1000']);

        $harga    = (float) $request->harga;
        $flaskUrl = env('FLASK_ML_URL', 'http://127.0.0.1:5000');

        // ── 1. Panggil Flask ML ──────────────────────────────
        $prediksi       = null;
        $sumberPrediksi = 'rule_based';

        try {
            $flaskResponse = Http::timeout(8)->post("{$flaskUrl}/predict", [
                'harga' => $harga,
            ]);

            if ($flaskResponse->successful()) {
                $body = $flaskResponse->json();
                if (!empty($body['success']) && !empty($body['data'])) {
                    $prediksi       = $body['data'];
                    $sumberPrediksi = $body['data']['source'] ?? 'flask_ml';
                }
            }
        } catch (\Exception $e) {
            Log::warning('[Prediksi] Flask ML tidak tersedia: ' . $e->getMessage());
        }

        // ── 2. Fallback rule-based jika Flask gagal ──────────
        if (!$prediksi) {
            $prediksi       = $this->ruleBased($harga);
            $sumberPrediksi = 'rule_based';
        }

        // ── 3. Mapping numerik → label display ───────────────
        $tipeKosLabels = Kost::tipeKosLabel();
        $kelasLabels   = Kost::kelasLabel();
        $lokasiLabels  = Kost::kodeLokasiLabel();

        $prediksi['kelas_label']    = $kelasLabels[(int) ($prediksi['kelas'] ?? 1)]         ?? 'Ekonomi';
        $prediksi['tipe_kos_label'] = $tipeKosLabels[(int) ($prediksi['tipe_kos'] ?? 3)]    ?? 'Campur';
        $prediksi['status_label']   = Kost::statusLabel((int) ($prediksi['status']  ?? 1));
        $prediksi['lokasi_label']   = $lokasiLabels[(int) ($prediksi['kode_lokasi'] ?? 1)]  ?? '';

        // ── 4. Query kost cocok (status tersedia, kelas cocok, range harga ±35%) ──
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

        // ── 5. Scoring ────────────────────────────────────────
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

            // Skor fasilitas binary (+8 per item yang sama)
            $skorFas = 0;
            foreach ($fasBinary as $fasKey => $fasVal) {
                if ($fasVal === 1 && (int) ($k->$fasKey ?? 0) === 1) $skorFas += 8;
            }

            // Skor harga (kedekatan ke input, max 50)
            $h         = (float) ($k->harga_kost ?? 0);
            $skorHarga = $harga > 0 ? max(0, (1 - abs($h - $harga) / max($harga, 1)) * 50) : 0;

            // Skor kecocokan tipe_kos (+10 jika sama)
            $skorTipe = ($tipeKosPred > 0 && (int) ($k->tipe_kos ?? 0) === $tipeKosPred) ? 10 : 0;

            // Skor rating
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

    // ── Rule-based fallback (numerik) ────────────────────────────
    private function ruleBased(float $harga): array
    {
        if ($harga <= 700_000) {
            return [
                'kelas'             => 1,   // ekonomi
                'tipe_kos'          => 3,   // campur
                'luas_kamar'        => 9.0, // 3x3
                'status'            => 1,
                'kode_lokasi'       => 3,   // pinggir kota
                'listrik'           => 1,
                'ac'                => 0,
                'kamar_mandi_dalam' => 0,
                'parkir_motor'      => 1,
                'laundry'           => 0,
                'wifi'              => 0,
                'source'            => 'rule_based',
            ];
        } elseif ($harga <= 1_500_000) {
            return [
                'kelas'             => 2,   // standar
                'tipe_kos'          => 3,   // campur
                'luas_kamar'        => 12.0,// 3x4
                'status'            => 1,
                'kode_lokasi'       => 1,   // dekat kampus
                'listrik'           => 1,
                'ac'                => 0,
                'kamar_mandi_dalam' => 1,
                'parkir_motor'      => 1,
                'laundry'           => 0,
                'wifi'              => 1,
                'source'            => 'rule_based',
            ];
        } else {
            return [
                'kelas'             => 3,   // premium
                'tipe_kos'          => 3,   // campur
                'luas_kamar'        => 16.0,// 4x4
                'status'            => 1,
                'kode_lokasi'       => 2,   // pusat kota
                'listrik'           => 1,
                'ac'                => 1,
                'kamar_mandi_dalam' => 1,
                'parkir_motor'      => 1,
                'laundry'           => 1,
                'wifi'              => 1,
                'source'            => 'rule_based',
            ];
        }
    }
}
