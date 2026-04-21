<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\KostResource;
use App\Models\Kost;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KostController extends Controller
{
    // GET /api/kost
    public function index()
    {
        $kosts = Kost::with('reviews')->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar kost berhasil diambil',
            'data'    => KostResource::collection($kosts),
        ]);
    }

    // GET /api/kost/{id}
    public function show($id)
    {
        $kost = Kost::with('reviews')->find($id);

        if (!$kost) {
            return response()->json([
                'success' => false,
                'message' => 'Kost tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => new KostResource($kost),
        ]);
    }

    // POST /api/kost
    public function store(Request $request)
    {
        $request->validate([
            'nama_kost'     => 'required|string',
            'foto_kost'     => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'alamat_kost'   => 'required|string',
            'kelas'         => 'required|string',
            'jenis_kost'    => 'nullable|string|in:Pria,Wanita,Bebas',
            'status'        => 'required|string',
            'fasilitas'     => 'nullable|string',
            'harga_kost'    => 'required|numeric',
            'nomor_telepon' => 'nullable|string',
        ]);

        $fotoPath = null;
        if ($request->hasFile('foto_kost')) {
            $fotoPath = $request->file('foto_kost')->store('kosts', 'public');
        }

        $kost = Kost::create([
            'nama_kost'     => $request->nama_kost,
            'foto_kost'     => $fotoPath,
            'alamat_kost'   => $request->alamat_kost,
            'kelas'         => $request->kelas,
            'jenis_kost'    => $request->jenis_kost ?? 'Bebas',
            'status'        => $request->status,
            'fasilitas'     => $request->fasilitas,
            'harga_kost'    => (float) $request->harga_kost,
            'nomor_telepon' => $request->nomor_telepon,
        ]);

        $kost->load('reviews');

        return response()->json([
            'success' => true,
            'message' => 'Kost berhasil ditambahkan',
            'data'    => new KostResource($kost),
        ], 201);
    }

    // POST /api/kost/{id}  (_method=PUT)
    public function update(Request $request, $id)
    {
        $kost = Kost::with('reviews')->find($id);

        if (!$kost) {
            return response()->json([
                'success' => false,
                'message' => 'Kost tidak ditemukan',
            ], 404);
        }

        $request->validate([
            'nama_kost'     => 'sometimes|required|string',
            'foto_kost'     => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'alamat_kost'   => 'sometimes|required|string',
            'kelas'         => 'sometimes|required|string',
            'jenis_kost'    => 'nullable|string|in:Pria,Wanita,Bebas',
            'status'        => 'sometimes|required|string',
            'fasilitas'     => 'nullable|string',
            'harga_kost'    => 'sometimes|required|numeric',
            'nomor_telepon' => 'nullable|string',
        ]);

        if ($request->hasFile('foto_kost')) {
            if ($kost->foto_kost) {
                Storage::disk('public')->delete($kost->foto_kost);
            }
            $kost->foto_kost = $request->file('foto_kost')->store('kosts', 'public');
        }

        foreach (['nama_kost', 'alamat_kost', 'kelas', 'jenis_kost', 'status', 'fasilitas', 'nomor_telepon'] as $field) {
            if ($request->has($field)) $kost->$field = $request->$field;
        }
        if ($request->has('harga_kost')) {
            $kost->harga_kost = (float) $request->harga_kost;
        }

        $kost->save();

        return response()->json([
            'success' => true,
            'message' => 'Kost berhasil diperbarui',
            'data'    => new KostResource($kost),
        ]);
    }

    // DELETE /api/kost/{id}
    public function destroy($id)
    {
        $kost = Kost::find($id);

        if (!$kost) {
            return response()->json([
                'success' => false,
                'message' => 'Kost tidak ditemukan',
            ], 404);
        }

        if ($kost->foto_kost) {
            Storage::disk('public')->delete($kost->foto_kost);
        }

        $kost->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kost berhasil dihapus',
        ]);
    }
}
