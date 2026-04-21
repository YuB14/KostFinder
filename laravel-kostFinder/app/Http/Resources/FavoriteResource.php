<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use App\Models\Favorite;

class FavoriteResource extends JsonResource
{
    public function toArray($request): array
    {
        $id   = (string) ($this->_id ?? $this->id ?? '');
        $kost = $this->kost;

        // Foto kost
        $foto = $kost?->foto_kost ?? null;
        if ($foto && !str_starts_with((string) $foto, 'http')) {
            $foto = asset('storage/' . $foto);
        }

        // Jumlah favorit untuk kost ini
        $kostId   = (string) ($kost?->_id ?? $kost?->id ?? '');
        $favCount = $kostId ? Favorite::where('kost_id', $kostId)->count() : 0;

        // Status pill
        $status   = (string) ($kost?->status ?? '');
        $pillMap  = ['Aktif' => 'green', 'Review' => 'blue', 'Nonaktif' => 'muted'];
        $pillClass = $pillMap[$status] ?? 'green';

        return [
            'id'             => $id,
            'user_id'        => (string) ($this->user_id ?? ''),
            'kost_id'        => (string) ($this->kost_id ?? ''),
            'kost_nama'      => (string) ($kost?->nama_kost   ?? ''),
            'kost_alamat'    => (string) ($kost?->alamat_kost ?? ''),
            'kost_harga'     => (float)  ($kost?->harga_kost  ?? 0),
            'kost_kelas'     => (string) ($kost?->kelas        ?? ''),
            'kost_status'    => $status,
            'kost_foto'      => $foto,
            'kost_fasilitas' => (string) ($kost?->fasilitas   ?? ''),
            'pill_class'     => $pillClass,
            'fav_count'      => $favCount,
            'created_at'     => $this->created_at
                ? \Carbon\Carbon::parse($this->created_at)->format('d M Y')
                : '-',
        ];
    }
}
