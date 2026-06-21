# 📚 Aplikasi Presensi - Dokumentasi Lengkap

## 🎯 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Setup & Configuration](#setup--configuration)
4. [Security Guidelines](#security-guidelines)
5. [API Endpoints](#api-endpoints)
6. [Database Structure](#database-structure)
7. [Development Guidelines](#development-guidelines)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)

---

## 📋 Overview

**Presensi App** adalah sistem absensi berbasis GPS dengan geofencing untuk validasi kehadiran siswa.

### Architecture

```
presensi-app/
├── backend/         <- Laravel 10 API
├── frontend/        <- Flutter Mobile App
└── DOCUMENTATION.md <- This file
```

### Features

- ✅ GPS-based attendance dengan geofencing radius 50m
- ✅ Real-time location tracking
- ✅ Interactive maps (OpenStreetMap)
- ✅ Persistent authentication
- ✅ Attendance history
- ✅ Formal design dengan light/dark mode

---

## 🚀 Quick Start

### Prerequisites

- **Backend**: PHP 8.1+, Composer, MySQL
- **Frontend**: Flutter SDK 3.6.1+, Android Studio
- **Tools**: Git, Postman (optional)

### 1. Backend Setup

```bash
cd backend

# Install dependencies
composer install

# Setup environment
cp .env.example .env
php artisan key:generate

# Configure database di .env
DB_DATABASE=presensi_app
DB_USERNAME=root
DB_PASSWORD=your_password

# Run migration & seeder
php artisan migrate:fresh --seed

# Start server
php artisan serve
# Access: http://localhost:8000
```

### 2. Frontend Setup

```bash
cd frontend

# Get dependencies
flutter pub get

# Setup API configuration
# Edit: lib/service/API_config.dart
# Set: _baseUrl = 'http://localhost:8000/api'

# Run app
flutter run

# Build APK
flutter build apk
```

---

## ⚙️ Setup & Configuration

### Backend Configuration

**File: `backend/.env`**

```env
APP_NAME="Presensi App"
APP_ENV=local
APP_KEY=base64:...
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=presensi_app
DB_USERNAME=root
DB_PASSWORD=

# School Location (GANTI dengan lokasi sekolah Anda)
SCHOOL_LAT=-7.32787262808773
SCHOOL_LNG=112.79426795133186
SCHOOL_RADIUS=50
```

### Frontend Configuration

**1. API Configuration**

**File: `frontend/lib/service/API_config.dart`**

```dart
static const String _baseUrl = 'http://localhost:8000/api';
```

**2. School Location**

**File: `frontend/lib/screens/home_screen.dart`**

```dart
final LatLng _targetLocation = const LatLng(
  -7.32787262808773,  // GANTI dengan latitude sekolah Anda
  112.79426795133186,  // GANTI dengan longitude sekolah Anda
); // Nama sekolah dan alamat
```

**3. Google Maps API Key**

**File: `frontend/android/local.properties`** (TIDAK di-commit ke git)

```properties
# Copy dari template
cp android/local.properties.template android/local.properties

# Edit dan isi dengan API key Anda
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE
```

#### Mendapatkan Google Maps API Key:

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat project baru atau pilih existing
3. Enable "Maps SDK for Android"
4. Create API key dengan restrictions:
   - **Application restrictions**: Android apps
   - **Package name**: `com.example.flutter_absensi` (atau package name app Anda)
   - **SHA-1 fingerprint**: Dari signing certificate
5. Copy API key ke `local.properties`

---

## 🔒 Security Guidelines

### 🚨 CRITICAL: API Keys & Secrets

**NEVER commit sensitive data ke git!**

### Gitignore Configuration

File berikut TIDAK di-commit ke git:

```gitignore
# API Keys & Secrets
/android/local.properties
android/local.properties
*.properties
!gradle.properties

# Environment files
.env
.env.production
.env.staging
```

### Security Checklist

- [x] API keys di `local.properties` (gitignored)
- [x] `AndroidManifest.xml` menggunakan placeholder
- [x] `build.gradle` membaca dari `local.properties`
- [x] `.env` file tidak di-commit
- [x] Password tidak di-hardcode

### 🔒 Best Practices

1. **Environment Variables**:
   ```bash
   # Jangan hardcode credentials
   # Gunakan environment variables
   DB_PASSWORD=${DB_PASSWORD}
   ```

2. **API Key Rotation**:
   - Rotate API keys secara berkala (3-6 bulan)
   - Revoke API key yang ter-expose
   - Monitor API usage di Google Cloud Console

3. **Before Committing**:
   ```bash
   # Check untuk secrets
   git diff --cached | grep -i "api.*key\|secret\|password"

   # Verify gitignore
   git status android/local.properties
   ```

### 🚨 Incident Response

**Jika API Key Ter-Expose:**

1. **Immediately**: Revoke API key di Google Cloud Console
2. **Remove from git history**:
   ```bash
   # Install BFG Repo-Cleaner
   scoop install bfg

   # Remove API key dari history
   cd c:\laragon\www\presensi-app
   echo AIzaSyBCABn2os7bOxALu4Rf0k5I4WpcwiRYnGU > apikeys.txt
   bfg --replace-text apikeys.txt
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   git push origin --force --all
   ```
3. **Notify team members** untuk update local copies
4. **Monitor** untuk unauthorized access

---

## 🌐 API Endpoints

### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/register` | Register siswa baru | Public |
| POST | `/api/login` | Login & dapat token | Public |
| POST | `/api/logout` | Logout user | Sanctum |
| GET | `/api/profile` | Get profile user | Sanctum |

### Attendance

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/absen` | Submit absensi | Sanctum |
| GET | `/api/history` | Get riwayat absensi | Sanctum |

### Request/Response Examples

#### Register

```json
POST /api/register
Content-Type: application/json

{
  "fullname": "John Doe",
  "nisn": "1234567890",
  "kelas": "XII-IPA-1",
  "email": "john@example.com",
  "password": "password123"
}

Response 201:
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "user": { ... },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

#### Login

```json
POST /api/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response 200:
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": { ... },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

#### Submit Attendance

```json
POST /api/absen
Authorization: Bearer {token}
Content-Type: application/json

{
  "latitude": -7.32787262808773,
  "longitude": 112.79426795133186,
  "status": "hadir"
}

Response 200:
{
  "success": true,
  "message": "Absensi berhasil",
  "data": {
    "id": 1,
    "waktu_absen": "2026-06-21 07:00:00",
    "status": "hadir"
  }
}
```

---

## 🗄️ Database Structure

### Tables

**users**
```
- id (bigint, primary key)
- fullname (string, 255)
- nisn (string, 20, unique)
- kelas (string, 50)
- email (string, 255, unique)
- password (string, 255, hashed)
- created_at (timestamp)
- updated_at (timestamp)
```

**absens**
```
- id (bigint, primary key)
- user_id (bigint, foreign key → users.id)
- status (enum: 'hadir', 'izin', 'sakit')
- latitude (decimal, 10,7)
- longitude (decimal, 10,7)
- waktu_absen (timestamp)
- created_at (timestamp)
- updated_at (timestamp)
```

---

## 👨‍💻 Development Guidelines

### Commit Convention

```
type(scope): subject

[optional body]

[optional footer]
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation change
- `style` - Code style change
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance
- `security` - Security fix

**Example:**
```
feat(frontend): add dark mode support

Implement theme toggle with persistent storage using SharedStorage.

Closes #123
```

### Git Workflow

```bash
# Development branch
git checkout -b feature/your-feature-name

# Make changes & commit
git add .
git commit -m "feat: description"

# Push & create PR
git push origin feature/your-feature-name
```

### Code Style

**Frontend (Flutter/Dart):**
- Use `flutter analyze` sebelum commit
- Follow effective Dart guidelines
- Add comments untuk complex logic

**Backend (Laravel/PHP):**
- Use PSR-12 coding standard
- Run `php artisan code:analyze` 
- Add type hints
- Write API documentation

---

## 🚢 Deployment

### Backend Deployment

**1. Server Requirements:**
- Ubuntu 20.04+ / CentOS 7+
- PHP 8.1+
- MySQL 8.0+
- Composer
- Nginx/Apache

**2. Deployment Steps:**

```bash
# Clone repository
git clone <repo-url>
cd presensi-app/backend

# Install dependencies
composer install --optimize-autoloader --no-dev

# Setup environment
cp .env.example .env
nano .env  # Edit production values

# Generate key
php artisan key:generate

# Run migration
php artisan migrate --force

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

**3. Nginx Configuration:**

```nginx
server {
    listen 80;
    server_name api.presensi-app.com;
    root /var/www/presensi-app/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### Frontend Deployment

**1. Build APK:**

```bash
cd frontend

# Build release APK
flutter build apk --release

# Output: frontend/build/app/outputs/flutter-apk/app-release.apk
```

**2. Build App Bundle (untuk Google Play):**

```bash
flutter build appbundle --release

# Output: frontend/build/app/outputs/bundle/release/app-release.aab
```

**3. Update ke Google Play:**

1. Upload APK/AAB ke Google Play Console
2. Fill in release notes
3. Review & publish

---

## 🐛 Troubleshooting

### Common Issues

**1. Laravel Server Not Starting**
```bash
# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Check port conflicts
php artisan serve --port=8001
```

**2. Flutter GPS Permission Denied**

**Android:** Add ke `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS:** Add ke `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location for attendance verification</string>
```

**3. API Connection Refused**
```bash
# Ensure Laravel server running
php artisan serve

# Check API URL
# Edit: lib/service/API_config.dart
# Verify: _baseUrl = 'http://localhost:8000/api'

# Test with Postman
GET http://localhost:8000/api/profile
Authorization: Bearer {token}
```

**4. Google Maps Not Showing**
```bash
# Check API key di local.properties
cat android/local.properties | grep MAPS_API_KEY

# Verify build.gradle configuration
cat android/app/build.gradle | grep manifestPlaceholders

# Verify placeholder di AndroidManifest.xml
cat android/app/src/main/AndroidManifest.xml | grep MAPS_API_KEY
```

---

## 📞 Support

For issues, questions, or contributions:
- 🐛 Issues: [GitHub Issues](https://github.com/Alfiansyahp2/presensi-app/issues)
- 📧 Email: support@presensi-app.com

---

## 📜 License

This project is for educational purposes (Ujikom).

---

**Version:** 1.0.0
**Last Updated:** 2026-06-21
**Status:** ✅ Production Ready
