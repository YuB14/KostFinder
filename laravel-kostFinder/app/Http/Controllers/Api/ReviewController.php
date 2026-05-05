<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ReviewResource;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    // GET /api/review
    public function index()
    {
        $reviews = Review::with(['user', 'kost'])->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar review berhasil diambil',
            'data'    => ReviewResource::collection($reviews),
        ]);
    }

    // GET /api/review/stats
    public function stats()
    {
        $reviews   = Review::all();
        $total     = $reviews->count();

        return response()->json([
            'success' => true,
            'data'    => [
                'total'     => $total,
                'disetujui' => $reviews->where('status', 'Disetujui')->count(),
                'menunggu'  => $reviews->where('status', 'Menunggu')->count(),
                'ditolak'   => $reviews->where('status', 'Ditolak')->count(),
            ],
        ]);
    }

    // GET /api/review/{id}
    public function show($id)
    {
        $review = Review::with(['user', 'kost'])->find($id);

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => new ReviewResource($review),
        ]);
    }

    // POST /api/review
    public function store(Request $request)
    {
        $request->validate([
            'kost_id'  => 'required|string',
            'rating'   => 'required|integer|min:1|max:5',
            'komentar' => 'required|string',
            'status'   => 'nullable|string|in:Menunggu,Disetujui,Ditolak',
        ]);

        // user_id selalu dari Auth — tidak bisa dimanipulasi frontend
        $review = Review::create([
            'user_id'  => (string) Auth::id(),
            'kost_id'  => $request->kost_id,
            'rating'   => (int) $request->rating,
            'komentar' => $request->komentar,
            'status'   => $request->status ?? 'Menunggu',
        ]);

        $review->load(['user', 'kost']);

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil dibuat',
            'data'    => new ReviewResource($review),
        ], 201);
    }

    // PUT /api/review/{id}
    public function update(Request $request, $id)
    {
        $review = Review::with(['user', 'kost'])->find($id);

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review tidak ditemukan',
            ], 404);
        }

        $request->validate([
            'kost_id'  => 'sometimes|string',
            'rating'   => 'sometimes|integer|min:1|max:5',
            'komentar' => 'sometimes|string',
            'status'   => 'sometimes|string|in:Menunggu,Disetujui,Ditolak',
        ]);

        if ($request->has('kost_id'))  $review->kost_id  = $request->kost_id;
        if ($request->has('rating'))   $review->rating   = (int) $request->rating;
        if ($request->has('komentar')) $review->komentar = $request->komentar;
        if ($request->has('status'))   $review->status   = $request->status;

        $review->save();

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil diperbarui',
            'data'    => new ReviewResource($review),
        ]);
    }

    // DELETE /api/review/{id}
    public function destroy($id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review tidak ditemukan',
            ], 404);
        }

        $review->delete();

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil dihapus',
        ]);
    }
}
