@echo off
REM ============================================
REM Presensi App - Start All Services
REM ============================================
REM Purpose: Start backend & frontend simultaneously
REM Created: 2026-06-21

echo.
echo ============================================
echo   Presensi App - Start All Services
echo ============================================
echo.

REM Get script directory
set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..

echo [INFO] Root directory: %ROOT_DIR%
echo.
echo [INFO] This will start:
echo   - Backend: Laravel API (http://localhost:8000)
echo   - Frontend: Flutter app (requires device/emulator)
echo.
echo [WARNING] Two terminal windows will open!
echo.
pause

REM ============================================
REM Start Backend
REM ============================================
echo.
echo [1/2] Starting Backend (Laravel API)...
echo.

start "Presensi App - Backend" cmd /k "cd /d "%ROOT_DIR%\backend" && php artisan serve && pause"

REM Wait for backend to start
timeout /t 3 /nobreak >nul

echo [OK] Backend started in new window
echo     URL: http://localhost:8000
echo     API: http://localhost:8000/api
echo.

REM ============================================
REM Start Frontend
REM ============================================
echo [2/2] Starting Frontend (Flutter)...
echo.

REM Check if device/emulator is connected
cd /d "%ROOT_DIR%\frontend"
flutter devices >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] No Flutter device found!
    echo.
    echo Please:
    echo   1. Connect Android device with USB debugging
    echo   2. OR start Android emulator
    echo   3. OR use iOS simulator (Mac only)
    echo.
    echo Then run: flutter devices
    echo.
    pause
)

start "Presensi App - Frontend" cmd /k "cd /d "%ROOT_DIR%\frontend" && flutter run && pause"

echo.
echo ============================================
echo   All Services Started!
echo ============================================
echo.
echo Backend Window:
echo   - Running in: "Presensi App - Backend"
echo   - URL: http://localhost:8000
echo   - API: http://localhost:8000/api
echo.
echo Frontend Window:
echo   - Running in: "Presensi App - Frontend"
echo   - App will launch on connected device
echo.
echo To stop all services, close the opened windows.
echo.
echo ============================================
echo.

REM Show backend logs
echo Backend logs will appear in the backend window.
echo.
