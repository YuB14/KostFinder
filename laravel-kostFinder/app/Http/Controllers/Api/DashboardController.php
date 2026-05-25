<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kost;
use App\Models\User;
use App\Models\Review;
use App\Models\Favorite;
use Carbon\Carbon;

class DashboardController extends Controller
{
    // GET /api/dashboard/stats
    public function stats()
    {
        $now            = Carbon::now();
        $thisMonthStart = $now->copy()->startOfMonth();
        $lastMonthStart = $now->copy()->subMonth()->startOfMonth();
        $lastMonthEnd   = $now->copy()->subMonth()->endOfMonth();

        $totalKost = Kost::count();
        $totalUser = User::count();
        $totalFav  = Favorite::count();

        // FIX: avg() dipanggil sekali saja, bukan dua kali
        $rawAvg    = Review::avg('rating');
        $avgRating = $rawAvg ? round((float) $rawAvg, 2) : 0;

        $kostThisMonth = Kost::whereBetween('created_at', [$thisMonthStart, $now])->count();
        $kostLastMonth = Kost::whereBetween('created_at', [$lastMonthStart, $lastMonthEnd])->count();

        $userThisMonth = User::whereBetween('created_at', [$thisMonthStart, $now])->count();
        $userLastMonth = User::whereBetween('created_at', [$lastMonthStart, $lastMonthEnd])->count();

        $favThisMonth = Favorite::whereBetween('created_at', [$thisMonthStart, $now])->count();
        $favLastMonth = Favorite::whereBetween('created_at', [$lastMonthStart, $lastMonthEnd])->count();

        $reviewThisMonth = Review::whereBetween('created_at', [$thisMonthStart, $now])->count();
        $reviewLastMonth = Review::whereBetween('created_at', [$lastMonthStart, $lastMonthEnd])->count();

        $avgThisMonth = Review::whereBetween('created_at', [$thisMonthStart, $now])->avg('rating') ?? 0;
        $avgLastMonth = Review::whereBetween('created_at', [$lastMonthStart, $lastMonthEnd])->avg('rating') ?? 0;

        return response()->json([
            'success' => true,
            'data'    => [
                'total_kost'    => (int) $totalKost,
                'kost_change'   => $this->calcChange($kostThisMonth, $kostLastMonth),
                'total_user'    => (int) $totalUser,
                'user_change'   => $this->calcChange($userThisMonth, $userLastMonth),
                'avg_rating'    => $avgRating,
                'rating_change' => $this->calcChange((float)$avgThisMonth, (float)$avgLastMonth),
                'total_fav'     => (int) $totalFav,
                'fav_change'    => $this->calcChange($favThisMonth, $favLastMonth),
            ],
        ]);
    }

    // GET /api/dashboard/registrations
    public function registrations()
    {
        $allUsers = User::all();
        $days     = [];

        for ($i = 6; $i >= 0; $i--) {
            $date    = Carbon::now()->subDays($i);
            $dateStr = $date->toDateString();

            $count = $allUsers->filter(function ($u) use ($dateStr) {
                $carbon = $this->parseDate($u->created_at ?? null);
                return $carbon && $carbon->toDateString() === $dateStr;
            })->count();

            $days[] = [
                'label' => $date->locale('id')->isoFormat('ddd'),
                'count' => (int) $count,
                'date'  => $dateStr,
            ];
        }

        $max = max(array_column($days, 'count')) ?: 1;

        return response()->json([
            'success' => true,
            'data'    => ['days' => $days, 'max' => (int) $max],
        ]);
    }

    // GET /api/dashboard/kelas-distribution
    // kelas: 1=ekonomi, 2=standar, 3=premium
    public function kelasDistribution()
    {
        $allKosts = Kost::all();
        $total    = $allKosts->count();
        $dist     = [];

        $kelasMap = [
            1 => 'Ekonomi',
            2 => 'Standar',
            3 => 'Premium',
        ];

        foreach ($kelasMap as $kode => $label) {
            $count  = $allKosts->where('kelas', $kode)->count();
            $persen = $total > 0 ? round(($count / $total) * 100) : 0;
            $dist[] = [
                'kelas'  => $label,
                'kode'   => $kode,
                'count'  => (int) $count,
                'persen' => (int) $persen,
            ];
        }

        return response()->json([
            'success' => true,
            'data'    => $dist,
        ]);
    }

    // GET /api/dashboard/recent-activity
    public function recentActivity()
    {
        $activities = collect();

        try {
            Kost::latest()->limit(3)->get()->each(function ($k) use (&$activities) {
                $time = $this->parseDate($k->created_at ?? null);
                if (!$time) return;
                $activities->push([
                    'icon'      => '🏘️',
                    'bg'        => 'coral',
                    'title'     => 'Kost Baru Ditambahkan',
                    'desc'      => ($k->nama_kost ?? '-') . ' — ' . ($k->alamat_kost ?? ''),
                    'timestamp' => $time->timestamp,
                    'time_str'  => $this->timeAgo($time),
                ]);
            });
        } catch (\Throwable $e) {}

        try {
            User::latest()->limit(3)->get()->each(function ($u) use (&$activities) {
                $time = $this->parseDate($u->created_at ?? null);
                if (!$time) return;
                $activities->push([
                    'icon'      => '👤',
                    'bg'        => 'teal',
                    'title'     => 'Pengguna Baru Daftar',
                    'desc'      => ($u->name ?? '-') . ' mendaftar',
                    'timestamp' => $time->timestamp,
                    'time_str'  => $this->timeAgo($time),
                ]);
            });
        } catch (\Throwable $e) {}

        try {
            Review::with('kost')->latest()->limit(3)->get()->each(function ($r) use (&$activities) {
                $time = $this->parseDate($r->created_at ?? null);
                if (!$time) return;
                $activities->push([
                    'icon'      => '⭐',
                    'bg'        => 'yellow',
                    'title'     => 'Ulasan Baru Masuk',
                    'desc'      => 'Rating ' . ($r->rating ?? '-') . ' — ' . ($r->kost?->nama_kost ?? '-'),
                    'timestamp' => $time->timestamp,
                    'time_str'  => $this->timeAgo($time),
                ]);
            });
        } catch (\Throwable $e) {}

        try {
            Favorite::with('kost')->latest()->limit(3)->get()->each(function ($f) use (&$activities) {
                $time = $this->parseDate($f->created_at ?? null);
                if (!$time) return;
                $activities->push([
                    'icon'      => '❤️',
                    'bg'        => 'coral',
                    'title'     => 'Kost Difavoritkan',
                    'desc'      => ($f->kost?->nama_kost ?? '-') . ' ditambahkan ke favorit',
                    'timestamp' => $time->timestamp,
                    'time_str'  => $this->timeAgo($time),
                ]);
            });
        } catch (\Throwable $e) {}

        $sorted = $activities
            ->filter(fn($a) => isset($a['timestamp']))
            ->sortByDesc('timestamp')
            ->take(5)
            ->map(fn($a) => [
                'icon'     => $a['icon'],
                'bg'       => $a['bg'],
                'title'    => $a['title'],
                'desc'     => $a['desc'],
                'time_str' => $a['time_str'],
            ])
            ->values();

        return response()->json(['success' => true, 'data' => $sorted]);
    }

    // GET /api/dashboard/top-kost
    public function topKost()
    {
        $kosts = Kost::with('reviews')->get();

        $kelasLabels   = [1 => 'Ekonomi', 2 => 'Standar', 3 => 'Premium'];
        $kelasClassMap = [1 => 'avail',   2 => 'pop',     3 => 'prem'];

        $scored = $kosts->map(function ($k) use ($kelasLabels, $kelasClassMap) {
            $id = (string) ($k->_id ?? $k->id ?? '');

            $favCount    = Favorite::where('kost_id', $id)->count();
            $reviews     = $k->reviews ?? collect();
            $reviewCount = is_countable($reviews) ? count($reviews) : 0;
            $avgRating   = $reviewCount > 0
                ? round((float) collect($reviews)->avg('rating'), 2)
                : 0;
            $score = ($favCount * 2) + $reviewCount + ($avgRating * 10);

            $foto = $k->foto_kost ?? null;
            if ($foto && !str_starts_with((string) $foto, 'http')) {
                $foto = asset('storage/' . $foto);
            }

            $kelasInt   = (int) ($k->kelas ?? 1);
            $kelasLabel = $kelasLabels[$kelasInt] ?? 'Ekonomi';
            $badgeClass = $kelasClassMap[$kelasInt] ?? 'avail';

            return [
                'id'          => $id,
                'nama'        => (string) ($k->nama_kost   ?? ''),
                'alamat'      => (string) ($k->alamat_kost ?? ''),
                'harga'       => (float)  ($k->harga_kost  ?? 0),
                'kelas'       => $kelasInt,
                'kelas_label' => $kelasLabel,
                'foto'        => $foto,
                'fav_count'   => (int) $favCount,
                'avg_rating'  => $avgRating,
                'badge_class' => $badgeClass,
                'score'       => $score,
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => $scored->sortByDesc('score')->take(4)->values(),
        ]);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private function parseDate($value): ?Carbon
    {
        if (is_null($value) || $value === '') return null;
        try {
            if ($value instanceof Carbon)    return $value;
            if ($value instanceof \DateTime) return Carbon::instance($value);
            return Carbon::parse((string) $value);
        } catch (\Throwable $e) {
            return null;
        }
    }

    private function timeAgo(Carbon $carbon): string
    {
        $now  = Carbon::now();
        $secs = $now->diffInSeconds($carbon, false);
        $diff = $now->diff($carbon);

        if (abs($secs) < 60) return 'baru saja';
        if ($diff->d === 0 && $diff->h === 0) return $diff->i . ' mnt lalu';
        if ($diff->d === 0) return $diff->h . ' jam lalu';
        if ($diff->d < 7)   return $diff->d . ' hari lalu';

        return $carbon->locale('id')->isoFormat('D MMM YYYY');
    }

    private function calcChange(float $current, float $previous): float
    {
        if ($previous == 0) return $current > 0 ? 100.0 : 0.0;
        return round((($current - $previous) / $previous) * 100, 1);
    }
}