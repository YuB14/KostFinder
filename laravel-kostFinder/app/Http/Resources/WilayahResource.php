<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class WilayahResource extends JsonResource
{
    public function toArray($request): array
    {
        $id = (string) ($this->_id ?? $this->id ?? '');

        return [
            'id'           => $id,
            'nama_wilayah' => (string) ($this->nama_wilayah ?? ''),
            'kode_lokasi'  => (int)    ($this->kode_lokasi  ?? 0),
            'deskripsi'    => (string) ($this->deskripsi    ?? ''),
        ];
    }
}
