<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AbsensiController;
use App\Http\Controllers\SchoolController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    // User profile
    Route::get('/user', [AuthController::class, 'profile']);
    Route::get('/profile', [AuthController::class, 'profile']); // Alias untuk Flutter
    Route::post('/logout', [AuthController::class, 'logout']);

    // Absensi routes - NEW multi-tenant endpoints
    Route::prefix('absensi')->group(function () {
        Route::post('/checkin', [AbsensiController::class, 'checkIn']);
        Route::post('/checkout', [AbsensiController::class, 'checkOut']);
        Route::get('/today', [AbsensiController::class, 'getTodayStatus']);
        Route::get('/history', [AbsensiController::class, 'history']);
    });

    // Legacy routes untuk backward compatibility (Flutter lama)
    Route::post('/absen', [AbsensiController::class, 'checkIn']); // Redirect ke checkIn
    Route::get('/history', [AbsensiController::class, 'history']); // Tetap ada

    // School management (admin only)
    // TODO: Tambah middleware role check untuk admin
    Route::prefix('schools')->group(function () {
        Route::get('/', [SchoolController::class, 'index']);
        Route::post('/', [SchoolController::class, 'store']);
        Route::get('/{id}', [SchoolController::class, 'show']);
        Route::put('/{id}', [SchoolController::class, 'update']);
        Route::patch('/{id}', [SchoolController::class, 'update']);
        Route::delete('/{id}', [SchoolController::class, 'destroy']);
        Route::get('/{id}/statistics', [SchoolController::class, 'statistics']);
    });
});

