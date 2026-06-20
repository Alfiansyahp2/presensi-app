@echo off
REM ============================================
REM Presensi App - Start Backend Only
REM ============================================

echo.
echo ============================================
echo   Starting Backend (Laravel API)
echo ============================================
echo.

cd /d "%~dp0..\backend"
php artisan serve
