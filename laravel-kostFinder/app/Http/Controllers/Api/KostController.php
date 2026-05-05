<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\KostResource;
use App\Models\Kost;
use App\Models\Wilayah;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KostController extends Controller
{
    // GET /api/kost
    public function index()
    {
        $kosts = Kost::with(['reviews', 'wilayah'])->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar kost berhasil diambil',
            'data'    => KostResource::collection($kosts),
        ]);
    }

    // GET /api/kost/{id}
    public function show($id)
    {
        $kost = Kost::with(['reviews', 'wilayah'])->find($id);

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
            'nama_kost'          => 'required|string',
            'foto_kost'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'alamat_kost'        => 'required|string',
            'harga_kost'         => 'required|numeric',
            'luas_kamar'         => 'nullable|numeric|min:0',
            'tipe_kos'           => 'nullable|integer|in:1,2,3',
            'kelas'              => 'nullable|integer|in:1,2,3',
            'status'             => 'required|integer|min:0',
            'kode_lokasi'        => 'nullable|integer|min:1|max:10',
            'wilayah_id'         => 'nullable|string',
            'listrik'            => 'nullable|integer|in:0,1',
            'ac'                 => 'nullable|integer|in:0,1',
            'kamar_mandi_dalam'  => 'nullable|integer|in:0,1',
            'parkir_motor'       => 'nullable|integer|in:0,1',
            'laundry'            => 'nullable|integer|in:0,1',
            'wifi'               => 'nullable|integer|in:0,1',
            'nomor_telepon'      => 'nullable|string',
            'deskripsi'          => 'nullable|string',
        ]);

        $fotoPath = null;
        if ($request->hasFile('foto_kost')) {
            $fotoPath = $request->file('foto_kost')->store('kosts', 'public');
        }

        // Resolve kode_lokasi dari wilayah jika tidak diisi langsung
        $kodeLokas = (int) ($request->kode_lokasi ?? 1);
        if ($request->wilayah_id && !$request->kode_lokasi) {
            $w = Wilayah::find($request->wilayah_id);
            if ($w) $kodeLokas = (int) $w->kode_lokasi;
        }

        // Auto-compute kelas from harga
        $harga = (float) $request->harga_kost;
        if ($harga > 1500000) {
            $kelas = 3; // Premium
        } elseif ($harga >= 1000000) {
            $kelas = 2; // Standar
        } else {
            $kelas = 1; // Ekonomi
        }

        $kost = Kost::create([
            'nama_kost'          => $request->nama_kost,
            'foto_kost'          => $fotoPath,
            'alamat_kost'        => $request->alamat_kost,
            'harga_kost'         => $harga,
            'luas_kamar'         => (float) ($request->luas_kamar ?? 0),
            'tipe_kos'           => (int)   ($request->tipe_kos   ?? 3),
            'kelas'              => $kelas,
            'status'             => (int)   $request->status,
            'kode_lokasi'        => $kodeLokas,
            'wilayah_id'         => $request->wilayah_id ?? null,
            'listrik'            => (int) ($request->listrik           ?? 1),
            'ac'                 => (int) ($request->ac                ?? 0),
            'kamar_mandi_dalam'  => (int) ($request->kamar_mandi_dalam ?? 0),
            'parkir_motor'       => (int) ($request->parkir_motor      ?? 0),
            'laundry'            => (int) ($request->laundry           ?? 0),
            'wifi'               => (int) ($request->wifi              ?? 0),
            'nomor_telepon'      => $request->nomor_telepon ?? '',
            'deskripsi'          => $request->deskripsi     ?? '',
        ]);

        $kost->load(['reviews', 'wilayah']);

        return response()->json([
            'success' => true,
            'message' => 'Kost berhasil ditambahkan',
            'data'    => new KostResource($kost),
        ], 201);
    }

    // POST /api/kost/{id}  (_method=PUT)
    public function update(Request $request, $id)
    {
        $kost = Kost::with(['reviews', 'wilayah'])->find($id);

        if (!$kost) {
            return response()->json([
                'success' => false,
                'message' => 'Kost tidak ditemukan',
            ], 404);
        }

        $request->validate([
            'nama_kost'          => 'sometimes|required|string',
            'foto_kost'          => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            'alamat_kost'        => 'sometimes|required|string',
            'harga_kost'         => 'sometimes|required|numeric',
            'luas_kamar'         => 'nullable|numeric|min:0',
            'tipe_kos'           => 'nullable|integer|in:1,2,3',
            'kelas'              => 'nullable|integer|in:1,2,3',
            'status'             => 'sometimes|required|integer|min:0',
            'kode_lokasi'        => 'nullable|integer|min:1|max:10',
            'wilayah_id'         => 'nullable|string',
            'listrik'            => 'nullable|integer|in:0,1',
            'ac'                 => 'nullable|integer|in:0,1',
            'kamar_mandi_dalam'  => 'nullable|integer|in:0,1',
            'parkir_motor'       => 'nullable|integer|in:0,1',
            'laundry'            => 'nullable|integer|in:0,1',
            'wifi'               => 'nullable|integer|in:0,1',
            'nomor_telepon'      => 'nullable|string',
            'deskripsi'          => 'nullable|string',
        ]);

        if ($request->hasFile('foto_kost')) {
            if ($kost->foto_kost) {
                Storage::disk('public')->delete($kost->foto_kost);
            }
            $kost->foto_kost = $request->file('foto_kost')->store('kosts', 'public');
        }

        // Update field numerik (kelas excluded — auto-computed below)
        $numericFields = ['harga_kost', 'luas_kamar', 'tipe_kos', 'status',
                          'kode_lokasi', 'listrik', 'ac', 'kamar_mandi_dalam',
                          'parkir_motor', 'laundry', 'wifi'];
        foreach ($numericFields as $field) {
            if ($request->has($field)) {
                $kost->$field = ($field === 'harga_kost' || $field === 'luas_kamar')
                    ? (float) $request->$field
                    : (int)   $request->$field;
            }
        }

        // Auto-compute kelas from harga (always sync)
        if ($request->has('harga_kost')) {
            $harga = (float) $request->harga_kost;
            if ($harga > 1500000) {
                $kost->kelas = 3; // Premium
            } elseif ($harga >= 1000000) {
                $kost->kelas = 2; // Standar
            } else {
                $kost->kelas = 1; // Ekonomi
            }
        }

        // Update wilayah_id & resolve kode_lokasi
        if ($request->has('wilayah_id')) {
            $kost->wilayah_id = $request->wilayah_id;
            if (!$request->has('kode_lokasi') && $request->wilayah_id) {
                $w = Wilayah::find($request->wilayah_id);
                if ($w) $kost->kode_lokasi = (int) $w->kode_lokasi;
            }
        }

        foreach (['nama_kost', 'alamat_kost', 'nomor_telepon', 'deskripsi'] as $field) {
            if ($request->has($field)) $kost->$field = $request->$field;
        }

        $kost->save();
        $kost->load(['reviews', 'wilayah']);

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

    // POST /api/kost/import-csv
    public function importCsv(Request $request)
    {
        $request->validate([
            'csv_file' => 'required|file|mimes:csv,txt|max:10240',
        ]);

        $file   = $request->file('csv_file');
        $handle = fopen($file->getRealPath(), 'r');

        if (!$handle) {
            return response()->json(['success' => false, 'message' => 'Gagal membaca file CSV'], 400);
        }

        // Skip header row
        $header = fgetcsv($handle, 0, ';');
        if (!$header) {
            fclose($handle);
            return response()->json(['success' => false, 'message' => 'File CSV kosong atau format salah'], 400);
        }

        /*
         * Urutan kolom CSV yang diharapkan:
         * 0  nama tempat
         * 1  wilayah        (nama kota/kabupaten)
         * 2  kode lokasi    (1-10)
         * 3  lokasi         (alamat detail / kecamatan)
         * 4  ukuran kamar   (m²)
         * 5  kelas          (1=ekonomi, 2=standar, 3=premium)
         * 6  listrik        (0/1)
         * 7  AC             (0/1)
         * 8  K. Mandi       (0/1)
         * 9  Parkir Motor   (0/1)
         * 10 Laundry        (0/1)
         * 11 Wifi           (0/1)
         * 12 Harga          (numeric)
         * 13 tipe_kos       (1=pria, 2=wanita, 3=campur)
         * 14 status         (0=penuh, 1=tersedia, 2+=sisa kamar)
         * 15 Foto           (URL/path, nullable)
         * 16 Alamat         (alamat lengkap)
         * 17 No.Telepon
         */

        // Label-to-integer maps
        $kelasMap = [
            'ekonomi' => 1, 'ekonomis' => 1, '1' => 1,
            'standar' => 2, 'standard' => 2, '2' => 2,
            'premium' => 3, '3' => 3,
        ];
        $tipeMap = [
            'pria' => 1, 'laki' => 1, 'putra' => 1, '1' => 1,
            'wanita' => 2, 'perempuan' => 2, 'putri' => 2, '2' => 2,
            'campur' => 3, 'mix' => 3, 'campuran' => 3, '3' => 3,
        ];

        $imported = 0;
        $errors   = [];
        $row      = 1;

        while (($data = fgetcsv($handle, 0, ';')) !== false) {
            $row++;

            // Pad columns if short
            while (count($data) < 18) $data[] = '';

            $namaTempat   = trim($data[0] ?? '');
            $namaWilayah  = trim($data[1] ?? '');
            $kodeLokasi   = (int) trim($data[2] ?? '1');
            $lokasiDetail = trim($data[3] ?? '');
            $luasKamar    = (float) str_replace(',', '.', trim($data[4] ?? '0'));
            $kelasRaw     = strtolower(trim($data[5] ?? '1'));
            $listrik      = (int) trim($data[6] ?? '1');
            $ac           = (int) trim($data[7] ?? '0');
            $kmd          = (int) trim($data[8] ?? '0');
            $parkir       = (int) trim($data[9] ?? '0');
            $laundry      = (int) trim($data[10] ?? '0');
            $wifi         = (int) trim($data[11] ?? '0');
            $harga        = (float) str_replace(['.', ','], ['', '.'], trim($data[12] ?? '0'));
            $tipeRaw      = strtolower(trim($data[13] ?? '3'));
            $status       = (int) trim($data[14] ?? '1');
            $fotoUrl      = trim($data[15] ?? '');
            $alamat       = trim($data[16] ?? '');
            $telepon      = trim($data[17] ?? '');

            if (empty($namaTempat)) {
                $errors[] = "Baris {$row}: nama tempat wajib diisi.";
                continue;
            }

            // Map kelas sesuai dengan harga
            if ($harga < 1000000) {
                $kelas = 1; // Ekonomi
            } elseif ($harga <= 1500000) {
                $kelas = 2; // Standar
            } else {
                $kelas = 3; // Premium
            }

            // Map tipe_kos
            $tipeKos = $tipeMap[$tipeRaw] ?? (is_numeric($tipeRaw) ? (int)$tipeRaw : 3);
            if ($tipeKos < 1 || $tipeKos > 3) $tipeKos = 3;

            // Validate kode_lokasi
            if ($kodeLokasi < 1 || $kodeLokasi > 10) $kodeLokasi = 1;

            // Resolve wilayah_id from name (case insensitive regex support for MongoDB)
            $wilayahId = null;
            if (!empty($namaWilayah)) {
                $w = \App\Models\Wilayah::where('nama_wilayah', 'regex', '/' . preg_quote($namaWilayah, '/') . '/i')
                    ->orWhere('nama_wilayah', 'like', '%' . $namaWilayah . '%')
                    ->first();
                $wilayahId = $w ? (string)$w->id : null;
            }

            // Combine alamat: lokasiDetail + alamat
            $alamatFinal = trim(array_filter([$lokasiDetail, $alamat], fn($s) => $s !== '') ? implode(', ', array_filter([$lokasiDetail, $alamat])) : '');

            try {
                \App\Models\Kost::create([
                    'nama_kost'          => $namaTempat,
                    'alamat_kost'        => $alamatFinal ?: $lokasiDetail,
                    'harga_kost'         => $harga,
                    'luas_kamar'         => $luasKamar,
                    'kelas'              => $kelas,
                    'tipe_kos'           => $tipeKos,
                    'status'             => $status,
                    'kode_lokasi'        => $kodeLokasi,
                    'wilayah_id'         => $wilayahId,
                    'listrik'            => $listrik,
                    'ac'                 => $ac,
                    'kamar_mandi_dalam'  => $kmd,
                    'parkir_motor'       => $parkir,
                    'laundry'            => $laundry,
                    'wifi'               => $wifi,
                    'nomor_telepon'      => $telepon,
                    'foto_kost'          => !empty($fotoUrl) ? $fotoUrl : null,
                    'deskripsi'          => '',
                ]);
                $imported++;
            } catch (\Throwable $e) {
                $errors[] = "Baris {$row}: " . $e->getMessage();
            }
        }

        fclose($handle);

        return response()->json([
            'success'  => true,
            'message'  => "{$imported} data kost berhasil diimpor.",
            'imported' => $imported,
            'errors'   => $errors,
        ]);
    }
}
