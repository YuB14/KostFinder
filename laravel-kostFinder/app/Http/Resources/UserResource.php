<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            "id" => $this->_id,
            "name" => $this->name,
            "email" => $this->email,
            "role" => $this->role,
            "profile_picture" => $this->profile_picture
        ];
    }
}
