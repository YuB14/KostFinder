<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FavoriteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            "id" => $this->_id,
            "user_id" => $this->user_id,
            "kost_id" => $this->kost_id
        ];
    }
}
