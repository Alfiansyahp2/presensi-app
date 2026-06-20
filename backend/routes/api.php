<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AbsensiController;


Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'profile']);
    Route::get('/profile', [AuthController::class, 'profile']); // Alias untuk Flutter
    Route::post('/absen', [AbsensiController::class, 'store']);
    Route::get('/absen/history', [AbsensiController::class, 'history']);
    Route::get('/history', [AbsensiController::class, 'history']); // Alias untuk Flutter
    Route::post('/logout', [AuthController::class, 'logout']);
});

