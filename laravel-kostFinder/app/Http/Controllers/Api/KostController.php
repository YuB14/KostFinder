<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kost;
use App\Http\Resources\KostResource;
use Illuminate\Http\Request;

class KostController extends Controller
{

    // GET /api/kost
    public function index()
    {
        $kosts = Kost::all();

        return response()->json([
            "success" => true,
            "message" => "Daftar kost berhasil diambil",
            "data" => KostResource::collection($kosts)
        ]);
    }


    // GET /api/kost/{id}
    public function show($id)
    {
        $kost = Kost::find($id);

        if (!$kost) {
            return response()->json([
                "success" => false,
                "message" => "Kost tidak ditemukan"
            ], 404);
        }

        return response()->json([
            "success" => true,
            "data" => new KostResource($kost)
        ]);
    }


    // POST /api/kost
    public function store(Request $request)
    {
        $request->validate([
            "nama_kost" => "required|string",
            "alamat" => "required|string",
            "wifi" => "required|string",
            "listrik" => "required|string",
            "fasilitas" => "required|string",
            "pendingin_ruangan" => "required|string",
            "kamar_mandi" => "required|string",
            "parkir_motor" => "required|string",
            "ukuran_kamar" => "required|string",
            "harga" => "required|numeric"
        ]);

        $kost = Kost::create($request->all());

        return response()->json([
            "success" => true,
            "message" => "Kost berhasil ditambahkan",
            "data" => new KostResource($kost)
        ], 201);
    }


    // PUT /api/kost/{id}
    public function update(Request $request, $id)
    {
        $kost = Kost::find($id);

        if (!$kost) {
            return response()->json([
                "success" => false,
                "message" => "Kost tidak ditemukan"
            ], 404);
        }

        $kost->update($request->all());

        return response()->json([
            "success" => true,
            "message" => "Kost berhasil diupdate",
            "data" => new KostResource($kost)
        ]);
    }


    // DELETE /api/kost/{id}
    public function destroy($id)
    {
        $kost = Kost::find($id);

        if (!$kost) {
            return response()->json([
                "success" => false,
                "message" => "Kost tidak ditemukan"
            ], 404);
        }

        $kost->delete();

        return response()->json([
            "success" => true,
            "message" => "Kost berhasil dihapus"
        ]);
    }
}
