<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class ApiTokenAuth
{
    /**
     * Autentikasi via Bearer token untuk request dari Flutter.
     * Jika token valid, set user ke Auth guard.
     */
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();

        if ($token) {
            $user = User::where('api_token', hash('sha256', $token))->first();

            if ($user) {
                Auth::login($user);
                return $next($request);
            }

            return response()->json([
                'success' => false,
                'message' => 'Token tidak valid atau sudah kadaluarsa.',
            ], 401);
        }

        // Fallback ke session-based auth (web browser)
        if (Auth::check()) {
            return $next($request);
        }

        return response()->json([
            'success' => false,
            'message' => 'Silakan login terlebih dahulu.',
        ], 401);
    }
}
