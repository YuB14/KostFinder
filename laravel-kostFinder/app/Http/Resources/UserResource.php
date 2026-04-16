<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use Carbon\Carbon;

class UserResource extends JsonResource
{
    public function toArray($request): array
    {
        // ID MongoDB → string
        $id = (string) ($this->_id ?? $this->id ?? '');

        // Foto profil
        $foto = $this->profile_picture ?? null;
        if ($foto && !str_starts_with((string) $foto, 'http')) {
            $foto = asset('storage/' . $foto);
        }

        // Parse tanggal dengan aman — hanya pakai Carbon::parse() dan try/catch
        $lastLoginCarbon = $this->parseDate($this->last_login_at ?? null);
        $createdAtCarbon = $this->parseDate($this->created_at ?? null);

        // Status aktif jika login dalam 30 hari terakhir
        $isAktif = $lastLoginCarbon && $lastLoginCarbon->gt(now()->subDays(30));

        return [
            'id'              => $id,
            'name'            => (string) ($this->name  ?? ''),
            'email'           => (string) ($this->email ?? ''),
            'role'            => (string) ($this->role  ?? 'user'),
            'photo'           => $foto,
            'last_login_at'   => $lastLoginCarbon ? $lastLoginCarbon->format('d M Y H:i') : null,
            'status'          => $isAktif ? 'Aktif' : 'Tidak Aktif',
            'favorites_count' => (int) ($this->favorites_count ?? 0),
            'created_at'      => $createdAtCarbon ? $createdAtCarbon->format('d M Y') : null,
        ];
    }

    /**
     * Parse tanggal dari MongoDB ke Carbon.
     * Tidak menggunakan UTCDateTime — cukup cast ke string lalu parse.
     * Laravel MongoDB driver otomatis mengubah tanggal ke Carbon saat diakses via model,
     * jadi ini hanya sebagai fallback jika nilainya masih string.
     */
    private function parseDate($value): ?Carbon
    {
        if (is_null($value) || $value === '') return null;
        try {
            if ($value instanceof Carbon) return $value;
            if ($value instanceof \DateTime) return Carbon::instance($value);
            return Carbon::parse((string) $value);
        } catch (\Throwable $e) {
            return null;
        }
    }
}
