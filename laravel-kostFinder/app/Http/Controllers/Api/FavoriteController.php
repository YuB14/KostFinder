<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Http\Resources\FavoriteResource;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{

    // GET /api/favorite
    public function index()
    {
        $favorites = Favorite::all();

        return response()->json([
            "success" => true,
            "message" => "Daftar favorite berhasil diambil",
            "data" => FavoriteResource::collection($favorites)
        ]);
    }


    // GET /api/favorite/{id}
    public function show($id)
    {
        $favorite = Favorite::find($id);

        if (!$favorite) {
            return response()->json([
                "success" => false,
                "message" => "Favorite tidak ditemukan"
            ], 404);
        }

        return response()->json([
            "success" => true,
            "data" => new FavoriteResource($favorite)
        ]);
    }


    // POST /api/favorite
    public function store(Request $request)
    {
        $request->validate([
            "user_id" => "required",
            "kost_id" => "required"
        ]);

        $favorite = Favorite::create([
            "user_id" => $request->user_id,
            "kost_id" => $request->kost_id
        ]);

        return response()->json([
            "success" => true,
            "message" => "Kost berhasil ditambahkan ke favorite",
            "data" => new FavoriteResource($favorite)
        ], 201);
    }


    // DELETE /api/favorite/{id}
    public function destroy($id)
    {
        $favorite = Favorite::find($id);

        if (!$favorite) {
            return response()->json([
                "success" => false,
                "message" => "Favorite tidak ditemukan"
            ], 404);
        }

        $favorite->delete();

        return response()->json([
            "success" => true,
            "message" => "Favorite berhasil dihapus"
        ]);
    }

}
