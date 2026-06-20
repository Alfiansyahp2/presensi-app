@echo off
REM ============================================
REM Presensi App - Git Status Check
REM ============================================

echo.
echo ============================================
echo   Git Status - Presensi App
echo ============================================
echo.

cd /d "%~dp0.."

echo Root Repository Status:
echo.
git status
echo.

echo ============================================
echo.
echo Branch:
git branch --show-current
echo.

echo Latest Commit:
git log -1 --oneline
echo.

pause
