<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ReviewResource extends JsonResource
{
    public function toArray($request): array
    {
        $id = (string) ($this->_id ?? $this->id ?? '');

        // Data user dari relasi
        $userName     = $this->user?->name    ?? 'Pengguna';
        $userInitials = $this->getInitials($userName);
        $userColor    = $this->avatarColor((string) ($this->user_id ?? ''));

        $userPhoto = $this->user?->profile_picture ?? null;
        if ($userPhoto && !str_starts_with((string) $userPhoto, 'http')) {
            $userPhoto = asset('storage/' . $userPhoto);
        }

        // Data kost dari relasi
        $kostName = $this->kost?->nama_kost ?? '-';

        return [
            'id'            => $id,
            'user_id'       => (string) ($this->user_id  ?? ''),
            'kost_id'       => (string) ($this->kost_id  ?? ''),
            'rating'        => (int)    ($this->rating    ?? 0),
            'komentar'      => (string) ($this->komentar  ?? ''),
            'status'        => (string) ($this->status    ?? 'Menunggu'),
            'user_name'     => $userName,
            'user_initials' => $userInitials,
            'user_color'    => $userColor,
            'user_photo'    => $userPhoto,
            'kost_name'     => $kostName,
            'created_at'    => $this->created_at
                ? \Carbon\Carbon::parse($this->created_at)->format('d M Y')
                : '-',
        ];
    }

    private function getInitials(string $name): string
    {
        return collect(explode(' ', $name))
            ->take(2)
            ->map(fn($w) => strtoupper(substr($w, 0, 1)))
            ->implode('');
    }

    private function avatarColor(string $id): string
    {
        $colors = [
            'linear-gradient(135deg,#E8430D,#FF6B3D)',
            'linear-gradient(135deg,#008F78,#00C9A7)',
            'linear-gradient(135deg,#D48D00,#F6C244)',
            'linear-gradient(135deg,#2563EB,#60A5FA)',
            'linear-gradient(135deg,#805AD5,#B794F4)',
            'linear-gradient(135deg,#38A169,#68D391)',
        ];
        $seed = $id ? (ord($id[strlen($id) - 1]) % count($colors)) : 0;
        return $colors[$seed];
    }
}
