<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wilayah;
use App\Http\Resources\WilayahResource;
use Illuminate\Http\Request;

class WilayahController extends Controller
{
    // GET /api/wilayah
    public function index()
    {
        $wilayah = Wilayah::orderBy('kode_lokasi')->get();

        return response()->json([
            'success' => true,
            'data'    => WilayahResource::collection($wilayah),
        ]);
    }

    // GET /api/wilayah/{id}
    public function show($id)
    {
        $wilayah = Wilayah::find($id);

        if (!$wilayah) {
            return response()->json(['success' => false, 'message' => 'Wilayah tidak ditemukan.'], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => new WilayahResource($wilayah),
        ]);
    }

    // POST /api/wilayah
    public function store(Request $request)
    {
        $request->validate([
            'nama_wilayah' => 'required|string|max:100',
            'kode_lokasi'  => 'required|integer|min:1',
            'deskripsi'    => 'nullable|string',
        ]);

        $wilayah = Wilayah::create([
            'nama_wilayah' => $request->nama_wilayah,
            'kode_lokasi'  => (int) $request->kode_lokasi,
            'deskripsi'    => $request->deskripsi ?? '',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Wilayah berhasil ditambahkan.',
            'data'    => new WilayahResource($wilayah),
        ], 201);
    }

    // PUT /api/wilayah/{id}
    public function update(Request $request, $id)
    {
        $wilayah = Wilayah::find($id);

        if (!$wilayah) {
            return response()->json(['success' => false, 'message' => 'Wilayah tidak ditemukan.'], 404);
        }

        $request->validate([
            'nama_wilayah' => 'sometimes|required|string|max:100',
            'kode_lokasi'  => 'sometimes|required|integer|min:1',
            'deskripsi'    => 'nullable|string',
        ]);

        if ($request->has('nama_wilayah')) $wilayah->nama_wilayah = $request->nama_wilayah;
        if ($request->has('kode_lokasi'))  $wilayah->kode_lokasi  = (int) $request->kode_lokasi;
        if ($request->has('deskripsi'))    $wilayah->deskripsi    = $request->deskripsi;
        $wilayah->save();

        return response()->json([
            'success' => true,
            'message' => 'Wilayah berhasil diperbarui.',
            'data'    => new WilayahResource($wilayah),
        ]);
    }

    // DELETE /api/wilayah/{id}
    public function destroy($id)
    {
        $wilayah = Wilayah::find($id);

        if (!$wilayah) {
            return response()->json(['success' => false, 'message' => 'Wilayah tidak ditemukan.'], 404);
        }

        $wilayah->delete();

        return response()->json(['success' => true, 'message' => 'Wilayah berhasil dihapus.']);
    }
}
