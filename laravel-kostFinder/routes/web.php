<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Api\AuthController;

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
    Route::get('/dashboard', fn() => view('admin.pages.dashboard'))->name('dashboard');
    Route::get('/user',      fn() => view('admin.pages.user'))->name('user');
    Route::get('/kost',      fn() => view('admin.pages.kost'))->name('kost');
    Route::get('/review',    fn() => view('admin.pages.review'))->name('review');
    Route::get('/favorite',  fn() => view('admin.pages.favorite'))->name('favorite');
});

// ─── Halaman User (harus login) ──────────────────────────────
Route::middleware('auth')->prefix('user')->name('user.')->group(function () {
    Route::get('/dashboard', fn() => view('user.pages.dashboard-user'))->name('dashboard');
    Route::get('/kost',      fn() => view('user.pages.kost-user'))->name('kost');
    Route::get('/review',    fn() => view('user.pages.review-user'))->name('review');
    Route::get('/favorite',  fn() => view('user.pages.favorite-user'))->name('favorite');
    Route::get('/prediksi',  fn() => view('user.pages.prediksi-user'))->name('prediksi');
});

// ─── Landing Page ──────────────────────────────────────────────
Route::get('/', function () {
    return view('index');
});

