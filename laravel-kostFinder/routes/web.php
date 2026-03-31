<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\MLController;

Route::get('/', function () {
    return view('index');
});

Route::get('/train-model', [MLController::class, 'trainModel']);

Route::get('/login', function () {
    return view('auth.login-register');
})->name('login');
Route::post('/login', [AuthController::class, 'login']);

Route::get('/register', function () {
    return view('auth.login-register');
})->name('register');
Route::post('/register', [AuthController::class, 'register']);

// Halaman Utama / Dashboard
Route::get('/dashboard', function () {
    return view('pages.dashboard');
})->name('dashboard')->middleware('auth');

// Halaman Data Pengguna
Route::get('/user', function () {
    return view('pages.user');
})->name('user');

// Halaman Data Kost
Route::get('/kost', function () {
    return view('pages.kost');
})->name('kost');

// Halaman Ulasan
Route::get('/review', function () {
    return view('pages.review');
})->name('review');

// Halaman Favorite
Route::get('/favorite', function () {
    return view('pages.favorite');
})->name('favorite');

// Route untuk Logout
Route::post('/logout', function() {
    Auth::logout(); // Jika sudah pakai sistem auth
    return redirect('/'); // Kirim ke halaman login atau home
})->name('logout');
