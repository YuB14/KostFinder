<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Kost;

/**
 * FixKostDataSeeder
 * -----------------
 * Memperbaiki data kost yang korupsi akibat migrasi skema ML:
 *   1. kelas = 0  → set ke 1 (Ekonomi)
 *   2. harga_kost = 0 → set default berdasarkan kelas
 *   3. Fasilitas yang semuanya 0 → set listrik = 1 (default)
 *
 * Jalankan sekali saja:
 *   php artisan db:seed --class=FixKostDataSeeder
 */
class FixKostDataSeeder extends Seeder
{
    public function run(): void
    {
        $fixed = 0;

        Kost::all()->each(function (Kost $kost) use (&$fixed) {
            $changed = false;

            // ── 1. Perbaiki kelas = 0 ──────────────────────────────
            if ((int) ($kost->kelas ?? 0) === 0) {
                // Tebak kelas dari harga jika ada, kalau tidak → Ekonomi
                $harga = (float) ($kost->harga_kost ?? 0);
                if ($harga > 1_500_000) {
                    $kost->kelas = 3; // Premium
                } elseif ($harga > 700_000) {
                    $kost->kelas = 2; // Standar
                } else {
                    $kost->kelas = 1; // Ekonomi
                }
                $changed = true;
            }

            // ── 2. Perbaiki harga_kost = 0 ────────────────────────
            if ((float) ($kost->harga_kost ?? 0) <= 0) {
                $kelas = (int) ($kost->kelas ?? 1);
                $kost->harga_kost = match($kelas) {
                    3       => 2_000_000.0,  // Premium default
                    2       => 1_000_000.0,  // Standar default
                    default => 500_000.0,    // Ekonomi default
                };
                $changed = true;
            }

            // ── 3. Set listrik = 1 jika semua fasilitas = 0 ───────
            $totalFas = (int)($kost->listrik ?? 0)
                      + (int)($kost->ac ?? 0)
                      + (int)($kost->kamar_mandi_dalam ?? 0)
                      + (int)($kost->parkir_motor ?? 0)
                      + (int)($kost->laundry ?? 0)
                      + (int)($kost->wifi ?? 0);

            if ($totalFas === 0) {
                $kost->listrik = 1;
                $changed = true;
            }

            // ── 4. Pastikan status valid (0 atau >= 1) ─────────────
            if (!isset($kost->status)) {
                $kost->status = 1;
                $changed = true;
            }

            if ($changed) {
                $kost->save();
                $fixed++;
                $this->command->line("  Fixed: {$kost->nama_kost} → kelas={$kost->kelas}, harga={$kost->harga_kost}, listrik={$kost->listrik}");
            }
        });

        $this->command->info("✅ Selesai. {$fixed} data kost diperbaiki.");
    }
}
