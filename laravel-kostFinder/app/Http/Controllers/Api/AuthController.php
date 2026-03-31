<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            "name" => "required|string|max:255",
            "email" => "required|email|unique:users,email",
            "password" => "required|min:6",
            "profile_picture" => "required|image|mimes:jpg,jpeg,png|max:2048"
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $path = null;

            if ($request->hasFile('profile_picture')) {
                $path = $request->file('profile_picture')->store('profiles', 'public');
            }

            User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role' => 'user',
                'profile_picture' => $path ?? 'profile/default.png'
            ]);

            return response()->json([
                'message' => 'Register berhasil'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Server error',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function login(Request $request)
    {
        $user = User::where("email", $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                "success" => false,
                "message" => "Email atau password salah"
            ], 401);
        }

        // ✅ INI YANG PENTING
        Auth::login($user);

        $user->last_login_at = now();
        $user->save();

        return response()->json([
            "success" => true,
            "message" => "Login berhasil",
            "user" => [
                "name" => $user->name,
                "email" => $user->email,
                "role" => $user->role
            ]
        ]);
    }
}
