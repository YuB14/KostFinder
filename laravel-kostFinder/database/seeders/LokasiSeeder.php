<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Lokasi;

class LokasiSeeder extends Seeder
{
    public function run(): void
    {
        $data = [
            ['kode' => 1,  'label' => 'Dekat Kampus',               'deskripsi' => 'Area sekitar kampus atau universitas, cocok untuk mahasiswa.'],
            ['kode' => 2,  'label' => 'Pusat Kota',                  'deskripsi' => 'Lokasi di pusat kota, dekat pusat perbelanjaan dan perkantoran.'],
            ['kode' => 3,  'label' => 'Pinggir Kota',                'deskripsi' => 'Lokasi di pinggiran kota, suasana lebih tenang dengan harga terjangkau.'],
            ['kode' => 4,  'label' => 'Dekat Transportasi Umum',     'deskripsi' => 'Dekat halte, terminal, atau stasiun transportasi umum.'],
            ['kode' => 5,  'label' => 'Perumahan',                   'deskripsi' => 'Berada di kawasan perumahan, nyaman dan aman.'],
            ['kode' => 6,  'label' => 'Dekat Pasar / Mall',          'deskripsi' => 'Dekat pusat belanja, pasar tradisional, atau supermarket.'],
            ['kode' => 7,  'label' => 'Kawasan Industri',            'deskripsi' => 'Cocok untuk pekerja pabrik atau kawasan industri.'],
            ['kode' => 8,  'label' => 'Pinggir Jalan Utama',         'deskripsi' => 'Berada di tepi jalan utama, mudah diakses kendaraan.'],
            ['kode' => 9,  'label' => 'Pedesaan / Wisata',           'deskripsi' => 'Area pedesaan atau kawasan wisata, suasana asri.'],
            ['kode' => 10, 'label' => 'Lainnya',                     'deskripsi' => 'Lokasi lainnya yang tidak masuk kategori di atas.'],
        ];

        foreach ($data as $item) {
            Lokasi::updateOrCreate(['kode' => $item['kode']], $item);
        }

        $this->command->info('LokasiSeeder: 10 kode lokasi berhasil di-seed.');
    }
}
