<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $user = Auth::user();

        if (!$user) {
            // Belum login: redirect ke halaman login
            return $request->expectsJson()
                ? response()->json(['success' => false, 'message' => 'Unauthenticated.'], 401)
                : redirect()->route('login');
        }

        if ($user->role !== 'admin') {
            // Login tapi bukan admin: untuk web redirect ke dashboard user
            return $request->expectsJson()
                ? response()->json(['success' => false, 'message' => 'Akses hanya untuk admin.'], 403)
                : redirect()->route('user.dashboard');
        }

        return $next($request);
    }
}
