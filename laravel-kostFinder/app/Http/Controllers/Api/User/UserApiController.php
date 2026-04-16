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

class UserApiController extends Controller
{
    // ── Helper: ambil user_id dari session, fallback '' jika belum login ──
    private function userId(): string
    {
        return (string) (Auth::id() ?? '');
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/stats
    // ═══════════════════════════════════════════════════════
    public function stats()
    {
        $uid = $this->userId();

        $totalFavorit = $uid ? Favorite::where('user_id', $uid)->count() : 0;
        $totalReview  = $uid ? Review::where('user_id', $uid)->count()   : 0;
        $totalKost    = Kost::where('status', 'Aktif')->count();

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
    // GET /api/user/kost — daftar kost aktif (read only)
    // ═══════════════════════════════════════════════════════
    public function kostIndex()
    {
        $kosts = Kost::with('reviews')->where('status', 'Aktif')->get();

        return response()->json([
            'success' => true,
            'data'    => KostResource::collection($kosts),
        ]);
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/kost/{id}/reviews — ulasan sebuah kost (tampil ke semua user)
    // ═══════════════════════════════════════════════════════
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
    // GET /api/user/review — ulasan milik user yang login
    // ═══════════════════════════════════════════════════════
    public function reviewIndex()
    {
        $uid = $this->userId();

        if (!$uid) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $reviews = Review::with(['user', 'kost'])
            ->where('user_id', $uid)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data'    => ReviewResource::collection($reviews),
        ]);
    }

    // POST /api/user/review — tambah ulasan
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

    // PUT /api/user/review/{id} — edit ulasan milik sendiri
    public function reviewUpdate(Request $request, $id)
    {
        $uid    = $this->userId();
        $review = Review::with(['user', 'kost'])->find($id);

        if (!$review) {
            return response()->json(['success' => false, 'message' => 'Ulasan tidak ditemukan.'], 404);
        }

        // Pastikan ulasan milik user ini
        if ($uid && (string)($review->user_id ?? '') !== $uid) {
            return response()->json(['success' => false, 'message' => 'Tidak diizinkan.'], 403);
        }

        $request->validate([
            'rating'   => 'required|integer|min:1|max:5',
            'komentar' => 'required|string|max:1000',
        ]);

        $review->rating   = (int) $request->rating;
        $review->komentar = $request->komentar;
        $review->status   = 'Menunggu'; // reset setelah edit
        $review->save();

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil diperbarui.',
            'data'    => new ReviewResource($review),
        ]);
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/favorite — favorit milik user yang login
    // ═══════════════════════════════════════════════════════
    public function favoriteIndex()
    {
        $uid = $this->userId();

        if (!$uid) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $favorites = Favorite::with(['user', 'kost'])
            ->where('user_id', $uid)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data'    => FavoriteResource::collection($favorites),
        ]);
    }

    // POST /api/user/favorite — tambah favorit
    public function favoriteStore(Request $request)
    {
        $request->validate(['kost_id' => 'required|string']);

        $uid    = $this->userId();
        $kostId = $request->kost_id;

        // Cegah duplikat
        if ($uid && Favorite::where('user_id', $uid)->where('kost_id', $kostId)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Kost sudah ada di favorit.',
            ], 409);
        }

        $favorite = Favorite::create(['user_id' => $uid, 'kost_id' => $kostId]);
        $favorite->load(['user', 'kost']);

        return response()->json([
            'success' => true,
            'message' => 'Berhasil ditambahkan ke favorit.',
            'data'    => new FavoriteResource($favorite),
        ], 201);
    }

    // DELETE /api/user/favorite/{id} — hapus favorit milik sendiri
    public function favoriteDestroy($id)
    {
        $uid      = $this->userId();
        $favorite = Favorite::find($id);

        if (!$favorite) {
            return response()->json(['success' => false, 'message' => 'Favorit tidak ditemukan.'], 404);
        }

        // Pastikan milik user ini
        if ($uid && (string)($favorite->user_id ?? '') !== $uid) {
            return response()->json(['success' => false, 'message' => 'Tidak diizinkan.'], 403);
        }

        $favorite->delete();

        return response()->json(['success' => true, 'message' => 'Favorit berhasil dihapus.']);
    }

    // ═══════════════════════════════════════════════════════
    // GET /api/user/prediksi/stats — statistik dataset untuk UI
    // ═══════════════════════════════════════════════════════
    public function prediksiStats()
    {
        $kosts = Kost::where('status', 'Aktif')->get();
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
    // POST /api/user/prediksi — algoritma scoring ML sederhana
    //
    // Skor per kost:
    //   fasilitas cocok  : +10 per item
    //   kedekatan harga  : max 50 poin (makin dekat anggaran max = lebih tinggi)
    //   rating           : avg_rating × 5
    //
    // Diurutkan skor tertinggi, ambil top 8.
    // ═══════════════════════════════════════════════════════
    public function prediksi(Request $request)
    {
        $request->validate([
            'harga_max'   => 'required|numeric|min:0',
            'harga_min'   => 'nullable|numeric|min:0',
            'fasilitas'   => 'nullable|array',
            'fasilitas.*' => 'nullable|string',
            'kelas'       => 'nullable|string',
        ]);

        $hargaMax  = (float) $request->harga_max;
        $hargaMin  = (float) ($request->harga_min ?? 0);
        $fasilitas = array_filter($request->fasilitas ?? [], 'strlen');
        $kelas     = $request->kelas ?? '';

        $query = Kost::with('reviews')->where('status', 'Aktif');
        if ($kelas) $query->where('kelas', $kelas);
        $kosts = $query->get();

        // Filter rentang harga di PHP (aman untuk MongoDB)
        $kosts = $kosts->filter(function ($k) use ($hargaMin, $hargaMax) {
            $h = (float)($k->harga_kost ?? 0);
            if ($hargaMin > 0 && $h < $hargaMin) return false;
            return $h <= $hargaMax;
        });

        if ($kosts->isEmpty()) {
            return response()->json([
                'success' => true,
                'data'    => [],
                'meta'    => ['max_skor' => 0],
            ]);
        }

        $scored = $kosts->map(function ($k) use ($fasilitas, $hargaMax) {
            $id = (string)($k->_id ?? $k->id ?? '');

            // Skor fasilitas
            $kosFas  = strtolower($k->fasilitas ?? '');
            $skorFas = 0;
            foreach ($fasilitas as $f) {
                if (str_contains($kosFas, strtolower($f))) $skorFas += 10;
            }

            // Skor harga — makin dekat ke anggaran max = makin tinggi
            $harga     = (float)($k->harga_kost ?? 0);
            $skorHarga = $hargaMax > 0
                ? max(0, (1 - abs($harga - $hargaMax) / $hargaMax) * 50)
                : 0;

            // Skor rating
            $reviews     = $k->reviews ?? collect();
            $reviewCount = is_countable($reviews) ? count($reviews) : 0;
            $avgRating   = $reviewCount > 0
                ? round(collect($reviews)->avg('rating'), 2)
                : 0;
            $skorRating  = $avgRating * 5;

            $total = round($skorFas + $skorHarga + $skorRating, 2);

            $foto = $k->foto_kost;
            if ($foto && !str_starts_with((string)$foto, 'http')) {
                $foto = asset('storage/' . $foto);
            }

            return [
                'id'            => $id,
                'nama_kost'     => (string)($k->nama_kost    ?? ''),
                'foto_kost'     => $foto,
                'alamat_kost'   => (string)($k->alamat_kost  ?? ''),
                'kelas'         => (string)($k->kelas         ?? ''),
                'harga_kost'    => (float)($k->harga_kost     ?? 0),
                'fasilitas'     => (string)($k->fasilitas      ?? ''),
                'nomor_telepon' => (string)($k->nomor_telepon  ?? ''),
                'avg_rating'    => $avgRating,
                'reviews_count' => $reviewCount,
                'skor_cocok'    => $total,
            ];
        });

        $result  = $scored->sortByDesc('skor_cocok')->take(8)->values();
        $maxSkor = $result->max('skor_cocok') ?: 1;

        return response()->json([
            'success' => true,
            'data'    => $result,
            'meta'    => ['max_skor' => $maxSkor],
        ]);
    }
}
