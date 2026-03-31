<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Http\Resources\UserResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class UserController extends Controller
{

    // GET /api/users
    public function index()
    {
        $users = User::all();

        return response()->json([
            "success" => true,
            "message" => "Daftar user berhasil diambil",
            "data" => UserResource::collection($users)
        ]);
    }

    public function stats()
    {
        // 1. TOTAL USERS & CHANGE (Bandingkan dengan total minggu lalu)
        $totalUsers = User::count();
        $lastWeekTotal = User::where('created_at', '<', now()->subWeek())->count();
        $changeTotal = $lastWeekTotal > 0 ? (($totalUsers - $lastWeekTotal) / $lastWeekTotal) * 100 : ($totalUsers > 0 ? 100 : 0);

        // 2. ACTIVE TODAY & CHANGE (Bandingkan Today vs Yesterday)
        $todayUsers = User::whereDate('created_at', Carbon::today())->count();
        $yesterdayUsers = User::whereDate('created_at', Carbon::yesterday())->count();
        $changeActive = $yesterdayUsers > 0 ? (($todayUsers - $yesterdayUsers) / $yesterdayUsers) * 100 : ($todayUsers > 0 ? 100 : 0);

        // 3. MONTHLY & CHANGE (Bandingkan Bulan Ini vs Bulan Lalu)
        $thisMonth = User::whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)->count();

        // Gunakan subMonthNoOverflow untuk menghindari bug tanggal 31
        $lastMonthDate = now()->subMonthNoOverflow();
        $lastMonth = User::whereMonth('created_at', $lastMonthDate->month)
            ->whereYear('created_at', $lastMonthDate->year)->count();

        if ($lastMonth == 0) {
            $changeMonthly = $thisMonth > 0 ? 100 : 0;
        } else {
            $changeMonthly = (($thisMonth - $lastMonth) / $lastMonth) * 100;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_users'    => $totalUsers,
                'change_total'   => round($changeTotal, 1),
                'active_today'   => $todayUsers,
                'change_active'  => round($changeActive, 1),
                'new_this_month' => $thisMonth,
                'change_monthly' => round($changeMonthly, 1)
            ]
        ]);
    }

    // GET /api/users/{id}
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                "success" => false,
                "message" => "User tidak ditemukan"
            ], 404);
        }

        return response()->json([
            "success" => true,
            "message" => "Detail user berhasil diambil",
            "data" => new UserResource($user)
        ]);
    }


    // POST /api/users
    public function store(Request $request)
    {
        $request->validate([
            "name" => "required|string|max:255",
            "email" => "required|email|unique:users,email",
            "password" => "required|min:6",
            "role" => "required|in:admin,user"
        ]);

        $user = User::create([
            "name" => $request->name,
            "email" => $request->email,
            "password" => Hash::make($request->password),
            "role" => $request->role
        ]);

        return response()->json([
            "success" => true,
            "message" => "User berhasil dibuat",
            "data" => new UserResource($user)
        ], 201);
    }

    // PUT /api/users/{id}
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                "success" => false,
                "message" => "User tidak ditemukan"
            ], 404);
        }

        $request->validate([
            "name" => "sometimes|string|max:255",
            "email" => "sometimes|email",
            "role" => "sometimes|in:admin,user",
            "password" => "sometimes|min:6"
        ]);

        $data = $request->only(["name", "email", "role"]);

        if ($request->password) {
            $data["password"] = Hash::make($request->password);
        }

        $user->update($data);

        return response()->json([
            "success" => true,
            "message" => "User berhasil diupdate",
            "data" => new UserResource($user)
        ]);
    }


    // DELETE /api/users/{id}
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                "success" => false,
                "message" => "User tidak ditemukan"
            ], 404);
        }

        $user->delete();

        return response()->json([
            "success" => true,
            "message" => "User berhasil dihapus"
        ]);
    }
}
