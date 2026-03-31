<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class KostResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            "id" => $this->_id,
            "nama_kost" => $this->nama_kost,
            "alamat" => $this->alamat,
            "wifi" => $this->wifi,
            "listrik" => $this->listrik,
            "fasilitas" => $this->fasilitas,
            "pendingin_ruangan" => $this->pendingin_ruangan,
            "kamar_mandi" => $this->kamar_mandi,
            "parkir_motor" => $this->parkir_motor,
            "ukuran_kamar" => $this->ukuran_kamar,
            "harga" => $this->harga
        ];
    }
}
