<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use App\Models\Kost;
use App\Models\Wilayah;

class KostResource extends JsonResource
{
    public function toArray($request): array
    {
        // ID MongoDB → string
        $id = (string) ($this->_id ?? $this->id ?? '');

        // Foto: jika path relatif, wrap dengan asset()
        $foto = $this->foto_kost ?? null;
        if ($foto && !str_starts_with((string) $foto, 'http')) {
            $foto = asset('storage/' . $foto);
        }

        // Hitung avg_rating & reviews_count dari relasi
        try {
            $reviews      = $this->reviews ?? collect();
            $reviewsCount = is_countable($reviews) ? (int) count($reviews) : 0;
            $avgRating    = $reviewsCount > 0
                ? round((float) collect($reviews)->avg('rating'), 2)
                : 0;
        } catch (\Throwable $e) {
            $reviewsCount = 0;
            $avgRating    = 0;
        }

        // Nilai numerik dengan fallback aman
        $tipeKos    = (int) ($this->tipe_kos    ?? 3);
        $kelas      = (int) ($this->kelas       ?? 1);
        $status     = (int) ($this->status      ?? 1);
        $kodeLokas  = (int) ($this->kode_lokasi ?? 1);

        // Resolve nama wilayah — gunakan relasi eager-loaded jika tersedia
        $wilayahNama = null;
        try {
            if ($this->resource->relationLoaded('wilayah') && $this->resource->wilayah) {
                $wilayahNama = $this->resource->wilayah->nama_wilayah;
            } elseif (!empty($this->wilayah_id)) {
                $w = Wilayah::find($this->wilayah_id);
                $wilayahNama = $w ? $w->nama_wilayah : null;
            }
        } catch (\Throwable $e) {
            $wilayahNama = null;
        }

        // Label display
        $tipeKosLabels   = Kost::tipeKosLabel();
        $kelasLabels     = Kost::kelasLabel();
        $lokasiLabels    = Kost::kodeLokasiLabel();

        return [
            'id'             => $id,
            'nama_kost'      => (string) ($this->nama_kost    ?? ''),
            'foto_kost'      => $foto,
            'alamat_kost'    => (string) ($this->alamat_kost  ?? ''),
            'nomor_telepon'  => (string) ($this->nomor_telepon ?? ''),
            'deskripsi'      => (string) ($this->deskripsi    ?? ''),

            // ── Field numerik ML ─────────────────────────────────
            'harga_kost'     => (float) ($this->harga_kost    ?? 0),
            'luas_kamar'     => (float) ($this->luas_kamar    ?? 0),
            'tipe_kos'       => $tipeKos,
            'kelas'          => $kelas,
            'status'         => $status,
            'kode_lokasi'    => $kodeLokas,
            'wilayah_id'     => (string) ($this->wilayah_id   ?? ''),
            'wilayah_nama'   => $wilayahNama,

            // ── Fasilitas binary ─────────────────────────────────
            'listrik'            => (int) ($this->listrik            ?? 1),
            'ac'                 => (int) ($this->ac                 ?? 0),
            'kamar_mandi_dalam'  => (int) ($this->kamar_mandi_dalam  ?? 0),
            'parkir_motor'       => (int) ($this->parkir_motor       ?? 0),
            'laundry'            => (int) ($this->laundry            ?? 0),
            'wifi'               => (int) ($this->wifi               ?? 0),

            // ── Label display (untuk UI) ──────────────────────────
            'tipe_kos_label'  => $tipeKosLabels[$tipeKos]  ?? 'Campur',
            'kelas_label'     => $kelasLabels[$kelas]       ?? 'Ekonomi',
            'status_label'    => Kost::statusLabel($status),
            'lokasi_label'    => $lokasiLabels[$kodeLokas]  ?? '',

            // ── Feature vector (siap kirim ke Flask) ─────────────
            'feature_vector' => [
                'harga_kost'        => (float) ($this->harga_kost        ?? 0),
                'luas_kamar'        => (float) ($this->luas_kamar         ?? 0),
                'tipe_kos'          => $tipeKos,
                'kelas'             => $kelas,
                'kode_lokasi'       => $kodeLokas,
                'listrik'           => (int) ($this->listrik            ?? 1),
                'ac'                => (int) ($this->ac                 ?? 0),
                'kamar_mandi_dalam' => (int) ($this->kamar_mandi_dalam  ?? 0),
                'parkir_motor'      => (int) ($this->parkir_motor       ?? 0),
                'laundry'           => (int) ($this->laundry            ?? 0),
                'wifi'              => (int) ($this->wifi               ?? 0),
            ],

            // ── Rating ───────────────────────────────────────────
            'avg_rating'     => $avgRating,
            'reviews_count'  => $reviewsCount,
        ];
    }
}
