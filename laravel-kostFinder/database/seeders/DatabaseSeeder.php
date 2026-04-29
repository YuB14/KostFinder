<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed kode lokasi 1-10
        $this->call(LokasiSeeder::class);

        // Seed seluruh kabupaten/kota Indonesia ke koleksi wilayah
        $this->call(WilayahSeeder::class);
    }
}
