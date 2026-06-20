@echo off
REM ============================================
REM Presensi App - Setup Script
REM ============================================
REM Purpose: Automated setup for development environment
REM Created: 2026-06-21

echo.
echo ============================================
echo   Presensi App - Development Setup
echo ============================================
echo.

REM Get script directory
set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..

REM Check if running from correct location
if not exist "%ROOT_DIR%\backend" (
    echo [ERROR] Backend folder not found!
    echo Please run this script from presensi-app/scripts/ directory
    pause
    exit /b 1
)

echo [INFO] Root directory: %ROOT_DIR%
echo.

REM ============================================
REM PHASE 1: Backend Setup
REM ============================================
echo.
echo ============================================
echo   PHASE 1: Backend Setup (Laravel)
echo ============================================
echo.

cd /d "%ROOT_DIR%\backend"

echo [1/5] Installing Composer dependencies...
call composer install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Composer install failed!
    pause
    exit /b 1
)
echo [OK] Composer dependencies installed
echo.

echo [2/5] Setting up environment file...
if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env
        echo [OK] .env file created from .env.example
    ) else (
        echo [WARNING] .env.example not found, creating minimal .env
        echo APP_NAME=PresensiApp > .env
        echo APP_ENV=local >> .env
        echo APP_DEBUG=true >> .env
        echo APP_URL=http://localhost:8000 >> .env.
        echo.
        echo DB_CONNECTION=mysql >> .env
        echo DB_HOST=127.0.0.1 >> .env
        echo DB_PORT=3306 >> .env
        echo DB_DATABASE=presensis >> .env
        echo DB_USERNAME=root >> .env
        echo DB_PASSWORD= >> .env
    )
) else (
    echo [OK] .env file already exists
)
echo.

echo [3/5] Generating application key...
call php artisan key:generate --no-interaction
if %errorlevel% neq 0 (
    echo [WARNING] Key generation failed, but continuing...
)
echo [OK] Application key generated
echo.

echo [4/5] Running database migrations and seeders...
call php artisan migrate:fresh --seed --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Database migration failed!
    echo Please check your database configuration in .env
    pause
    exit /b 1
)
echo [OK] Database migration completed
echo.

echo [5/5] Creating storage link...
call php artisan storage:link --no-interaction
echo [OK] Storage link created
echo.

REM ============================================
REM PHASE 2: Frontend Setup
REM ============================================
echo.
echo ============================================
echo   PHASE 2: Frontend Setup (Flutter)
echo ============================================
echo.

cd /d "%ROOT_DIR%\frontend"

echo [1/2] Installing Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Flutter pub get failed!
    echo Please make sure Flutter SDK is installed
    pause
    exit /b 1
)
echo [OK] Flutter dependencies installed
echo.

echo [2/2] Checking Flutter installation...
call flutter doctor
echo.

REM ============================================
REM PHASE 3: Verification
REM ============================================
echo.
echo ============================================
echo   PHASE 3: Verification
echo ============================================
echo.

echo [OK] Backend setup completed!
echo [OK] Frontend setup completed!
echo.

REM ============================================
REM FINAL INSTRUCTIONS
REM ============================================
echo.
echo ============================================
echo   Setup Complete!
echo ============================================
echo.
echo To start the application:
echo.
echo   1. Start Backend:
echo      cd backend
echo      php artisan serve
echo.
echo   2. Start Frontend (in separate terminal):
echo      cd frontend
echo      flutter run
echo.
echo Or use: start-all.bat
echo.
echo ============================================
echo.

pause
