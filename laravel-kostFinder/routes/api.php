<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\KostController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\FavoriteController;

Route::prefix("auth")->group(function () {

    Route::post("/register", [AuthController::class, "register"]);
    Route::post("/login", [AuthController::class, "login"]);

});

Route::get('/users/stats', [UserController::class, 'stats']);

Route::apiResource('users', UserController::class)->middleware('admin');

Route::get('kost', [KostController::class, 'index']);
Route::get('kost/{id}', [KostController::class, 'show']);

Route::post('kost', [KostController::class, 'store'])->middleware('admin');
Route::put('kost/{id}', [KostController::class, 'update'])->middleware('admin');
Route::delete('kost/{id}', [KostController::class, 'destroy'])->middleware('admin');

Route::apiResource('review', ReviewController::class);

Route::apiResource('favorite', FavoriteController::class);
