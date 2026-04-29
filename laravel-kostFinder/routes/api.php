<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\KostController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\WilayahController;
use App\Http\Controllers\Api\User\UserApiController;

Route::prefix("auth")->group(function () {

    Route::post("/register", [AuthController::class, "register"]);
    Route::post("/login", [AuthController::class, "login"]);

});

Route::prefix('dashboard')->group(function () {
    Route::get('/stats', [DashboardController::class, 'stats']);
    Route::get('/registrations', [DashboardController::class, 'registrations']);
    Route::get('/kelas-distribution', [DashboardController::class, 'kelasDistribution']);
    Route::get('/recent-activity', [DashboardController::class, 'recentActivity']);
    Route::get('/top-kost', [DashboardController::class, 'topKost']);
});

Route::get('/users/stats', [UserController::class, 'stats']);
Route::apiResource('users', UserController::class);

Route::post('kost/import-csv', [KostController::class, 'importCsv']);
Route::apiResource('kost', KostController::class);

// Wilayah — public (dibutuhkan oleh form admin & Flask)
Route::apiResource('wilayah', WilayahController::class);

Route::get('review/stats', [ReviewController::class, 'stats']);
Route::apiResource('review', ReviewController::class);

Route::get('favorite/stats', [FavoriteController::class, 'stats']);
Route::apiResource('favorite', FavoriteController::class);

Route::prefix('user')->middleware(['web', 'auth'])->group(function () {

    // Statistik ringkasan
    Route::get('stats',                    [UserApiController::class, 'stats']);

    // Kost — read only
    Route::get('kost',                     [UserApiController::class, 'kostIndex']);
    Route::get('kost/{id}/reviews',        [UserApiController::class, 'kostReviews']);

    // Review — tambah & edit saja (tidak bisa hapus)
    Route::get('review',           [UserApiController::class, 'reviewIndex']);
    Route::post('review',          [UserApiController::class, 'reviewStore']);
    Route::put('review/{id}',      [UserApiController::class, 'reviewUpdate']);

    // Favorit — tambah & hapus
    Route::get('favorite',         [UserApiController::class, 'favoriteIndex']);
    Route::post('favorite',        [UserApiController::class, 'favoriteStore']);
    Route::delete('favorite/{id}', [UserApiController::class, 'favoriteDestroy']);

    // Prediksi ML
    Route::get('prediksi/stats',   [UserApiController::class, 'prediksiStats']);
    Route::post('prediksi',        [UserApiController::class, 'prediksi']);
});
