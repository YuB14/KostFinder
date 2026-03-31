<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Kost extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'kosts';

    protected $fillable = [
        'nama_kost',
        'alamat',
        'wifi',
        'listrik',
        'fasilitas',
        'pendingin_ruangan',
        'kamar_mandi',
        'parkir_motor',
        'ukuran_kamar',
        'harga'
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
