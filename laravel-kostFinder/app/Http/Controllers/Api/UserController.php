<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    // GET /api/users
    public function index()
    {
        $users = User::latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar pengguna berhasil diambil',
            'data'    => UserResource::collection($users),
        ]);
    }

    // GET /api/users/stats
    // Key yang dikembalikan harus cocok persis dengan yang dibaca Blade:
    // d.total_users, d.active_today, d.new_this_month,
    // d.change_total, d.change_active, d.change_monthly
    public function stats()
    {
        $now            = Carbon::now();
        $todayStart     = $now->copy()->startOfDay();
        $yesterdayStart = $now->copy()->subDay()->startOfDay();
        $yesterdayEnd   = $now->copy()->subDay()->endOfDay();
        $thisMonthStart = $now->copy()->startOfMonth();
        $lastMonthStart = $now->copy()->subMonth()->startOfMonth();
        $lastMonthEnd   = $now->copy()->subMonth()->endOfMonth();

        // Ambil semua user sekali lalu filter di PHP
        // Ini menghindari query MongoDB dengan operator tanggal yang tidak konsisten
        $users = User::all();
        $totalUsers = $users->count();

        // Aktif hari ini — login sejak awal hari ini
        $activeToday = $users->filter(function ($u) use ($todayStart) {
            $carbon = $this->parseDate($u->last_login_at ?? null);
            return $carbon && $carbon->gte($todayStart);
        })->count();

        // Aktif kemarin — untuk hitung perubahan
        $activeYesterday = $users->filter(function ($u) use ($yesterdayStart, $yesterdayEnd) {
            $carbon = $this->parseDate($u->last_login_at ?? null);
            return $carbon && $carbon->between($yesterdayStart, $yesterdayEnd);
        })->count();

        // Daftar bulan ini
        $newThisMonth = $users->filter(function ($u) use ($thisMonthStart, $now) {
            $carbon = $this->parseDate($u->created_at ?? null);
            return $carbon && $carbon->between($thisMonthStart, $now);
        })->count();

        // Daftar bulan lalu
        $newLastMonth = $users->filter(function ($u) use ($lastMonthStart, $lastMonthEnd) {
            $carbon = $this->parseDate($u->created_at ?? null);
            return $carbon && $carbon->between($lastMonthStart, $lastMonthEnd);
        })->count();

        // Persentase perubahan
        // change_total: bandingkan total saat ini vs sebelum bulan ini
        $totalBeforeThisMonth = $totalUsers - $newThisMonth;
        $changeTotal   = $this->calcChange($totalUsers, max(1, $totalBeforeThisMonth));
        $changeActive  = $this->calcChange($activeToday, $activeYesterday);
        $changeMonthly = $this->calcChange($newThisMonth, $newLastMonth);

        return response()->json([
            'success' => true,
            'data'    => [
                'total_users'    => $totalUsers,
                'active_today'   => $activeToday,
                'new_this_month' => $newThisMonth,
                'change_total'   => $changeTotal,
                'change_active'  => $changeActive,
                'change_monthly' => $changeMonthly,
            ],
        ]);
    }

    // GET /api/users/{id}
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => new UserResource($user),
        ]);
    }

    // POST /api/users
    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|min:8',
            'role'     => 'nullable|string|in:admin,user',
            'photo'    => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        $fotoPath = null;
        if ($request->hasFile('photo')) {
            $fotoPath = $request->file('photo')->store('profiles', 'public');
        }

        $user = User::create([
            'name'            => $request->name,
            'email'           => $request->email,
            'password'        => Hash::make($request->password),
            'role'            => $request->role ?? 'user',
            'profile_picture' => $fotoPath,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil ditambahkan',
            'data'    => new UserResource($user),
        ], 201);
    }

    // POST /api/users/{id}  (_method=PUT)
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan',
            ], 404);
        }

        $request->validate([
            'name'     => 'sometimes|required|string|max:255',
            'email'    => 'sometimes|required|email|unique:users,email,' . $id,
            'password' => 'nullable|min:8',
            'role'     => 'nullable|string|in:admin,user',
            'photo'    => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        if ($request->hasFile('photo')) {
            if ($user->profile_picture) {
                Storage::disk('public')->delete($user->profile_picture);
            }
            $user->profile_picture = $request->file('photo')->store('profiles', 'public');
        }

        if ($request->has('name'))  $user->name  = $request->name;
        if ($request->has('email')) $user->email = $request->email;
        if ($request->has('role'))  $user->role  = $request->role;
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil diperbarui',
            'data'    => new UserResource($user),
        ]);
    }

    // DELETE /api/users/{id}
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan',
            ], 404);
        }

        if ($user->profile_picture) {
            Storage::disk('public')->delete($user->profile_picture);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pengguna berhasil dihapus',
        ]);
    }

    // ── Helpers ────────────────────────────────────────────────────────────

    /**
     * Parse tanggal ke Carbon tanpa menggunakan UTCDateTime.
     * Laravel MongoDB driver biasanya sudah auto-cast, tapi jika tidak,
     * cukup cast ke string lalu parse dengan Carbon.
     */
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

    private function calcChange(int $current, int $previous): float
    {
        if ($previous === 0) return $current > 0 ? 100.0 : 0.0;
        return round((($current - $previous) / $previous) * 100, 1);
    }
}
