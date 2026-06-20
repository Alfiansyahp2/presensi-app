@echo off
REM ============================================
REM Presensi App - Start Frontend Only
REM ============================================

echo.
echo ============================================
echo   Starting Frontend (Flutter)
echo ============================================
echo.

cd /d "%~dp0..\frontend"

REM Check devices
echo Checking for connected devices...
flutter devices
echo.

flutter run
