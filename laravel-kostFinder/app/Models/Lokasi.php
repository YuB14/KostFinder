<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Lokasi extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'lokasi';

    protected $fillable = [
        'kode',       // int 1-10
        'label',      // nama kategori lokasi
        'deskripsi',
    ];

    protected $casts = [
        'kode' => 'integer',
    ];

    public static function allLabels(): array
    {
        return [
            1  => 'Dekat Kampus',
            2  => 'Pusat Kota',
            3  => 'Pinggir Kota',
            4  => 'Dekat Transportasi Umum',
            5  => 'Perumahan',
            6  => 'Dekat Pasar',
            7  => 'Kawasan Industri',
            8  => 'Pinggir Jalan Utama',
            9  => 'Pedesaan / Wisata',
            10 => 'Lainnya',
        ];
    }
}
