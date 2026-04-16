<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Kost extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'kosts';

    protected $fillable = [
        'nama_kost',
        'foto_kost',
        'alamat_kost',
        'kelas',
        'jenis_kost',
        'status',
        'fasilitas',
        'harga_kost',
        'nomor_telepon',
    ];

    // Cast harga ke float agar konsisten dari DB
    protected $casts = [
        'harga_kost' => 'float',
    ];

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}
