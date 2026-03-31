<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Http\Resources\ReviewResource;
use Illuminate\Http\Request;

class ReviewController extends Controller
{

    // GET /api/review
    public function index()
    {
        $reviews = Review::all();

        return response()->json([
            "success" => true,
            "message" => "Daftar review berhasil diambil",
            "data" => ReviewResource::collection($reviews)
        ]);
    }


    // GET /api/review/{id}
    public function show($id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json([
                "success" => false,
                "message" => "Review tidak ditemukan"
            ], 404);
        }

        return response()->json([
            "success" => true,
            "data" => new ReviewResource($review)
        ]);
    }


    // POST /api/review
    public function store(Request $request)
    {
        $request->validate([
            "user_id" => "required",
            "kost_id" => "required",
            "rating" => "required|integer|min:1|max:5",
            "komentar" => "required|string"
        ]);

        $review = Review::create([
            "user_id" => $request->user_id,
            "kost_id" => $request->kost_id,
            "rating" => $request->rating,
            "komentar" => $request->komentar
        ]);

        return response()->json([
            "success" => true,
            "message" => "Review berhasil dibuat",
            "data" => new ReviewResource($review)
        ], 201);
    }


    // DELETE /api/review/{id}
    public function destroy($id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json([
                "success" => false,
                "message" => "Review tidak ditemukan"
            ], 404);
        }

        $review->delete();

        return response()->json([
            "success" => true,
            "message" => "Review berhasil dihapus"
        ]);
    }

}
