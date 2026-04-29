<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Wilayah extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'wilayah';

    protected $fillable = [
        'nama_wilayah',
        'kode_lokasi',
        'deskripsi',
    ];

    protected $casts = [
        'kode_lokasi' => 'integer',
    ];

    /**
     * Mapping kode_lokasi → label
     */
    public static function kodeLokasiLabel(): array
    {
        return [
            1  => 'Dekat Kampus',
            2  => 'Pusat Kota',
            3  => 'Pinggir Kota',
            4  => 'Dekat Transportasi Umum',
            5  => 'Perumahan',
            6  => 'Dekat Pasar / Mall',
            7  => 'Kawasan Industri',
            8  => 'Pinggir Jalan Utama',
            9  => 'Pedesaan / Wisata',
            10 => 'Lainnya',
        ];
    }

    public function kosts()
    {
        return $this->hasMany(Kost::class, 'wilayah_id');
    }
}
