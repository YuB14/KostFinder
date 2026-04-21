<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

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

        // Hitung avg_rating & reviews_count HANYA untuk review yang Disetujui
        try {
            $allReviews   = $this->reviews ?? collect();
            $reviews      = collect($allReviews)->where('status', 'Disetujui');
            $reviewsCount = $reviews->count();
            $avgRating    = $reviewsCount > 0
                ? round((float) $reviews->avg('rating'), 2)
                : 0;
        } catch (\Throwable $e) {
            $reviewsCount = 0;
            $avgRating    = 0;
        }

        return [
            'id'            => $id,
            'nama_kost'     => (string) ($this->nama_kost     ?? ''),
            'foto_kost'     => $foto,
            'alamat_kost'   => (string) ($this->alamat_kost   ?? ''),
            'kelas'         => (string) ($this->kelas          ?? ''),
            'jenis_kost'    => (string) ($this->jenis_kost    ?? 'Bebas'),
            'status'        => (string) ($this->status         ?? ''),
            'fasilitas'     => (string) ($this->fasilitas      ?? ''),
            'harga_kost'    => (float)  ($this->harga_kost     ?? 0),
            'nomor_telepon' => (string) ($this->nomor_telepon  ?? ''),
            'avg_rating'    => $avgRating,
            'reviews_count' => $reviewsCount,
        ];
    }
}
