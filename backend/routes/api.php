<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AbsensiController;
use App\Http\Controllers\SchoolController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ReportController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::post('/register', [AuthController::class, 'register'])->name('register');
Route::post('/login', [AuthController::class, 'login'])->name('login');

// Protected routes (require authentication + active status)
Route::middleware(['auth:sanctum', 'auth.status'])->group(function () {

    // ============================================
    // USER PROFILE ROUTES (All authenticated users)
    // ============================================
    Route::get('/user', [AuthController::class, 'profile'])->name('profile');
    Route::get('/profile', [AuthController::class, 'profile']); // Alias for Flutter
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
    Route::put('/profile', [AuthController::class, 'updateProfile'])->name('profile.update');

    // ============================================
    // ATTENDANCE ROUTES (Multi-tenant)
    // ============================================
    Route::prefix('absensi')->group(function () {
        // Student attendance operations
        Route::post('/checkin', [AbsensiController::class, 'checkIn'])
            ->middleware('role:STUDENT')
            ->name('attendance.checkin');

        Route::post('/checkout', [AbsensiController::class, 'checkOut'])
            ->middleware('role:STUDENT')
            ->name('attendance.checkout');

        Route::get('/today', [AbsensiController::class, 'getTodayStatus'])
            ->name('attendance.today');

        Route::get('/history', [AbsensiController::class, 'history'])
            ->name('attendance.history');

        // Admin/Teacher attendance management
        Route::get('/admin', [AbsensiController::class, 'adminIndex'])
            ->middleware('permission:attendance.view')
            ->name('attendance.admin');

        Route::put('/{id}/approve', [AbsensiController::class, 'approve'])
            ->middleware('permission:attendance.approve')
            ->name('attendance.approve');
    });

    // Legacy routes for backward compatibility (old Flutter apps)
    Route::post('/absen', [AbsensiController::class, 'checkIn']); // Redirect to checkIn
    Route::get('/history', [AbsensiController::class, 'history']); // Still available

    // ============================================
    // SCHOOL MANAGEMENT ROUTES (Role-based access)
    // ============================================
    Route::prefix('schools')->group(function () {
        // View schools (multi-tenant scoped)
        Route::get('/', [SchoolController::class, 'index'])
            ->name('schools.index');

        Route::get('/{id}', [SchoolController::class, 'show'])
            ->name('schools.show');

        // Create schools (SUPER_ADMIN only)
        Route::post('/', [SchoolController::class, 'store'])
            ->middleware('permission:school.create')
            ->name('schools.store');

        // Update schools (SUPER_ADMIN & SCHOOL_ADMIN)
        Route::put('/{id}', [SchoolController::class, 'update'])
            ->middleware('permission:school.update')
            ->name('schools.update');

        Route::patch('/{id}', [SchoolController::class, 'update'])
            ->middleware('permission:school.update')
            ->name('schools.update.patch');

        // Delete schools (SUPER_ADMIN only)
        Route::delete('/{id}', [SchoolController::class, 'destroy'])
            ->middleware('permission:school.delete')
            ->name('schools.destroy');

        // School statistics
        Route::get('/{id}/statistics', [SchoolController::class, 'statistics'])
            ->middleware('permission:report.view')
            ->name('schools.statistics');

        // Toggle school status (SUPER_ADMIN only)
        Route::post('/{id}/toggle-status', [SchoolController::class, 'toggleStatus'])
            ->middleware('permission:school.suspend')
            ->name('schools.toggle-status');

        // School users and attendance
        Route::get('/{id}/users', [SchoolController::class, 'users'])
            ->middleware('permission:user.view_all')
            ->name('schools.users');

        Route::get('/{id}/attendance', [SchoolController::class, 'attendance'])
            ->middleware('permission:attendance.view')
            ->name('schools.attendance');
    });

    // ============================================
    // USER MANAGEMENT ROUTES (Admin only)
    // ============================================
    Route::prefix('users')->group(function () {
        // View users (multi-tenant scoped)
        Route::get('/', [UserController::class, 'index'])
            ->middleware('permission:user.view_all')
            ->name('users.index');

        Route::get('/{id}', [UserController::class, 'show'])
            ->middleware('permission:user.view_all')
            ->name('users.show');

        // Create users (Admins only)
        Route::post('/', [UserController::class, 'store'])
            ->middleware('permission:student.create')
            ->name('users.store');

        // Create teachers (SCHOOL_ADMIN & SUPER_ADMIN)
        Route::post('/teacher', [UserController::class, 'createTeacher'])
            ->middleware('permission:teacher.create')
            ->name('users.create.teacher');

        // Update users
        Route::put('/{id}', [UserController::class, 'update'])
            ->middleware('permission:student.update')
            ->name('users.update');

        // Approve pending registrations
        Route::put('/{id}/approve', [UserController::class, 'approve'])
            ->middleware('permission:student.approve')
            ->name('users.approve');

        // Suspend/activate users
        Route::put('/{id}/toggle-status', [UserController::class, 'toggleStatus'])
            ->middleware('permission:user.suspend')
            ->name('users.toggle-status');

        // Delete users
        Route::delete('/{id}', [UserController::class, 'destroy'])
            ->middleware('permission:student.delete')
            ->name('users.destroy');
    });

    // ============================================
    // REPORT ROUTES (Multi-tenant)
    // ============================================
    Route::prefix('reports')->group(function () {
        Route::get('/attendance', [ReportController::class, 'attendanceReport'])
            ->middleware('permission:report.view')
            ->name('reports.attendance');

        Route::get('/attendance/export', [ReportController::class, 'exportAttendance'])
            ->middleware('permission:report.export')
            ->name('reports.attendance.export');

        Route::get('/summary', [ReportController::class, 'summary'])
            ->middleware('permission:report.view')
            ->name('reports.summary');
    });
});

// ============================================
// DEV/DEBUG ROUTES (Remove in production)
// ============================================
if (config('app.env') !== 'production') {
    Route::get('/debug/permissions', function (Request $request) {
        return response()->json([
            'user' => $request->user(),
            'permissions' => $request->user()->permissions(),
            'role' => $request->user()->role,
        ]);
    })->middleware('auth:sanctum');
}
