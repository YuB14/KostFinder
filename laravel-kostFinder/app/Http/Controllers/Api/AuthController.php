<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    // POST /login
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Email dan password wajib diisi.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah.',
            ], 401);
        }

        // Cek apakah request dari API (Flutter) atau web browser
        // Hanya cek URL path, BUKAN Accept header — karena frontend web
        // juga mengirim Accept: application/json untuk fetch()
        $isApi = $request->is('api/*');

        if ($isApi) {
            // ── Mobile / API: Token-based auth ──────────────────────
            $token = Str::random(64);
            $user->api_token = hash('sha256', $token);
            $user->last_login_at = now();
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'token'   => $token,
                'user'    => [
                    'id'    => (string) ($user->_id ?? $user->id),
                    'name'  => $user->name,
                    'email' => $user->email,
                    'role'  => $user->role ?? 'user',
                    'photo' => $user->profile_picture
                        ? (str_starts_with($user->profile_picture, 'http')
                            ? $user->profile_picture
                            : asset('storage/' . $user->profile_picture))
                        : null,
                ],
            ]);
        }

        // ── Web browser: Session-based auth ─────────────────────
        $remember = (bool) $request->input('remember', false);
        Auth::login($user, $remember);

        $user->last_login_at = now();
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'user'    => [
                'id'    => (string) ($user->_id ?? $user->id),
                'name'  => $user->name,
                'email' => $user->email,
                'role'  => $user->role ?? 'user',
                'photo' => $user->profile_picture
                    ? (str_starts_with($user->profile_picture, 'http')
                        ? $user->profile_picture
                        : asset('storage/' . $user->profile_picture))
                    : null,
            ],
        ]);
    }

    // POST /register
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'            => 'required|string|max:255',
            'email'           => 'required|email|unique:users,email',
            'password'        => 'required|min:8',
            'profile_picture' => 'required|image|mimes:jpg,jpeg,png,webp|max:2048',
        ], [
            'name.required'            => 'Nama lengkap wajib diisi.',
            'email.required'           => 'Email wajib diisi.',
            'email.email'              => 'Format email tidak valid.',
            'email.unique'             => 'Email sudah digunakan, gunakan email lain.',
            'password.required'        => 'Password wajib diisi.',
            'password.min'             => 'Password minimal 8 karakter.',
            'profile_picture.required' => 'Foto profil wajib diupload.',
            'profile_picture.image'    => 'File harus berupa gambar.',
            'profile_picture.max'      => 'Ukuran foto maksimal 2 MB.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        try {
            $path = null;
            if ($request->hasFile('profile_picture')) {
                $path = $request->file('profile_picture')->store('profiles', 'public');
            }

            User::create([
                'name'            => $request->name,
                'email'           => $request->email,
                'password'        => Hash::make($request->password),
                'role'            => 'user',
                'profile_picture' => $path ?? null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Akun berhasil dibuat! Silakan masuk.',
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan server.',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }

    // POST /logout
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/login');
    }

    // POST /api/auth/logout — token-based logout untuk Flutter
    public function apiLogout(Request $request)
    {
        $token = $request->bearerToken();
        if ($token) {
            $user = User::where('api_token', hash('sha256', $token))->first();
            if ($user) {
                $user->api_token = null;
                $user->save();
            }
        }

        return response()->json(['success' => true, 'message' => 'Logout berhasil']);
    }
}
