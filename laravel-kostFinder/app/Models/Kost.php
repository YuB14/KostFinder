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
        // ── Field numerik ML ──────────────────────────
        'harga_kost',
        'luas_kamar',           // float, dalam m²
        'tipe_kos',             // int: 1=pria, 2=wanita, 3=campur
        'kelas',                // int: 1=ekonomi, 2=standar, 3=premium
        'status',               // int: 0=penuh, 1=tersedia, >=2=sisa kamar
        'kode_lokasi',          // int: 1=dekat kampus, 2=pusat kota, 3=pinggir kota, 4=dekat transportasi
        'wilayah_id',           // string: _id dari koleksi wilayah
        // ── Fasilitas binary (0/1) ────────────────────
        'listrik',
        'ac',
        'kamar_mandi_dalam',
        'parkir_motor',
        'laundry',
        'wifi',
        // ── Field umum ───────────────────────────────
        'nomor_telepon',
        'deskripsi',
    ];

    protected $casts = [
        'harga_kost'        => 'float',
        'luas_kamar'        => 'float',
        'tipe_kos'          => 'integer',
        'kelas'             => 'integer',
        'status'            => 'integer',
        'kode_lokasi'       => 'integer',
        'listrik'           => 'integer',
        'ac'                => 'integer',
        'kamar_mandi_dalam' => 'integer',
        'parkir_motor'      => 'integer',
        'laundry'           => 'integer',
        'wifi'              => 'integer',
    ];

    // ── Mapping Statis (konsisten antara Laravel & Flask) ───────
    public static function tipeKosLabel(): array
    {
        return [1 => 'Pria', 2 => 'Wanita', 3 => 'Campur'];
    }

    public static function kelasLabel(): array
    {
        return [1 => 'Ekonomi', 2 => 'Standar', 3 => 'Premium'];
    }

    public static function statusLabel(int $status): string
    {
        if ($status === 0) return 'Penuh';
        if ($status === 1) return 'Tersedia';
        return $status . ' kamar tersisa';
    }

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

    /**
     * Feature vector untuk Flask ML (urutan FIXED — harus konsisten
     * antara training dan prediksi).
     */
    public function toFeatureVector(): array
    {
        return [
            'harga_kost'        => (float) ($this->harga_kost        ?? 0),
            'luas_kamar'        => (float) ($this->luas_kamar         ?? 0),
            'tipe_kos'          => (int)   ($this->tipe_kos           ?? 3),
            'kelas'             => (int)   ($this->kelas              ?? 1),
            'kode_lokasi'       => (int)   ($this->kode_lokasi        ?? 1),
            'listrik'           => (int)   ($this->listrik            ?? 1),
            'ac'                => (int)   ($this->ac                 ?? 0),
            'kamar_mandi_dalam' => (int)   ($this->kamar_mandi_dalam  ?? 0),
            'parkir_motor'      => (int)   ($this->parkir_motor       ?? 0),
            'laundry'           => (int)   ($this->laundry            ?? 0),
            'wifi'              => (int)   ($this->wifi               ?? 0),
        ];
    }

    // ── Relasi ─────────────────────────────────────────────────
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }

    public function wilayah()
    {
        return $this->belongsTo(Wilayah::class, 'wilayah_id');
    }
}
