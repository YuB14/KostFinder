<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\FavoriteResource;
use App\Models\Favorite;
use App\Models\Kost;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    // GET /api/favorite
    public function index()
    {
        $favorites = Favorite::with(['user', 'kost'])->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar favorit berhasil diambil',
            'data'    => FavoriteResource::collection($favorites),
        ]);
    }

    // GET /api/favorite/stats
    public function stats()
    {
        $total     = Favorite::count();
        $perKost   = Favorite::all()->groupBy('kost_id')->map->count()->sortDesc();
        $topKostId = $perKost->keys()->first();
        $topKost   = $topKostId ? Kost::find($topKostId) : null;
        $userCount = Favorite::all()->groupBy('user_id')->count();
        $avg       = $userCount > 0 ? round($total / $userCount, 1) : 0;

        return response()->json([
            'success' => true,
            'data'    => [
                'total'         => $total,
                'top_kost_nama' => $topKost?->nama_kost ?? '-',
                'avg_per_user'  => $avg,
            ],
        ]);
    }

    // GET /api/favorite/{id}
    public function show($id)
    {
        $favorite = Favorite::with(['user', 'kost'])->find($id);

        if (!$favorite) {
            return response()->json([
                'success' => false,
                'message' => 'Favorit tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => new FavoriteResource($favorite),
        ]);
    }

    // POST /api/favorite
    public function store(Request $request)
    {
        $request->validate([
            'kost_id' => 'required|string',
        ]);

        $userId = (string) Auth::id();
        $kostId = $request->kost_id;

        // Cegah duplikat
        $existing = Favorite::where('user_id', $userId)
            ->where('kost_id', $kostId)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Kost sudah ada di daftar favorit.',
            ], 409);
        }

        $favorite = Favorite::create([
            'user_id' => $userId,
            'kost_id' => $kostId,
        ]);

        $favorite->load(['user', 'kost']);

        return response()->json([
            'success' => true,
            'message' => 'Kost berhasil ditambahkan ke favorit',
            'data'    => new FavoriteResource($favorite),
        ], 201);
    }

    // DELETE /api/favorite/{id}
    public function destroy($id)
    {
        $favorite = Favorite::find($id);

        if (!$favorite) {
            return response()->json([
                'success' => false,
                'message' => 'Favorit tidak ditemukan',
            ], 404);
        }

        $favorite->delete();

        return response()->json([
            'success' => true,
            'message' => 'Favorit berhasil dihapus',
        ]);
    }
}
