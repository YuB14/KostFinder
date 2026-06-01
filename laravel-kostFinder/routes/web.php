<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\LandingController;

// ─── Halaman Auth (hanya untuk tamu/belum login) ──────────────
Route::middleware('guest')->group(function () {
    Route::get('/login',    fn() => view('auth.login-register'))->name('login');
    Route::get('/register', fn() => view('auth.login-register'))->name('register');
});

Route::post('/login',   [AuthController::class, 'login'])->name('auth.login');
Route::post('/register',[AuthController::class, 'register'])->name('auth.register');
Route::post('/logout',  [AuthController::class, 'logout'])->name('logout')->middleware('auth');

// ─── Halaman Admin (harus login + role admin) ─────────────────
Route::middleware(['auth', 'admin'])->group(function () {
    Route::get('/dashboard',   fn() => view('admin.pages.dashboard'))->name('dashboard');
    Route::get('/user',        fn() => view('admin.pages.user'))->name('user');
    Route::get('/kost',        fn() => view('admin.pages.kost'))->name('kost');
    Route::get('/review',      fn() => view('admin.pages.review'))->name('review');
    Route::get('/favorite',    fn() => view('admin.pages.favorite'))->name('favorite');
    Route::get('/api-tester',  fn() => view('admin.pages.api-tester'))->name('api-tester');
});

// ─── Halaman User (harus login) ──────────────────────────────
Route::middleware('auth')->prefix('user')->name('user.')->group(function () {
    Route::get('/dashboard',   fn() => view('user.pages.dashboard-user'))->name('dashboard');
    Route::get('/kost',        fn() => view('user.pages.kost-user'))->name('kost');
    Route::get('/review',      fn() => view('user.pages.review-user'))->name('review');
    Route::get('/favorite',    fn() => view('user.pages.favorite-user'))->name('favorite');
    Route::get('/prediksi',    fn() => view('user.pages.prediksi-user'))->name('prediksi');
    Route::get('/api-tester',  fn() => view('user.pages.api-tester-user'))->name('api-tester');
});

// ─── Web API untuk halaman User (session-based auth) ─────────
// Blade view user menggunakan fetch() ke endpoint ini.
// Karena web route sudah punya session middleware,
// Auth::check() dan Auth::id() berfungsi dengan benar.
Route::middleware('auth')->prefix('w/user')->group(function () {
    Route::get('stats',                    [\App\Http\Controllers\Api\User\UserApiController::class, 'stats']);
    Route::get('kost',                     [\App\Http\Controllers\Api\User\UserApiController::class, 'kostIndex']);
    Route::get('kost/{id}/reviews',        [\App\Http\Controllers\Api\User\UserApiController::class, 'kostReviews']);
    Route::get('review',                   [\App\Http\Controllers\Api\User\UserApiController::class, 'reviewIndex']);
    Route::post('review',                  [\App\Http\Controllers\Api\User\UserApiController::class, 'reviewStore']);
    Route::put('review/{id}',              [\App\Http\Controllers\Api\User\UserApiController::class, 'reviewUpdate']);
    Route::get('favorite',                 [\App\Http\Controllers\Api\User\UserApiController::class, 'favoriteIndex']);
    Route::post('favorite',                [\App\Http\Controllers\Api\User\UserApiController::class, 'favoriteStore']);
    Route::delete('favorite/{id}',         [\App\Http\Controllers\Api\User\UserApiController::class, 'favoriteDestroy']);
    Route::get('prediksi/stats',           [\App\Http\Controllers\Api\User\UserApiController::class, 'prediksiStats']);
    Route::get('prediksi/health',          [\App\Http\Controllers\Api\User\UserApiController::class, 'prediksiHealth']);
    Route::post('prediksi',                [\App\Http\Controllers\Api\User\UserApiController::class, 'prediksi']);
});

// ─── Landing Page ──────────────────────────────────────────────
Route::get('/',       [LandingController::class, 'index']);
Route::get('/search', [LandingController::class, 'search'])->name('landing.search');