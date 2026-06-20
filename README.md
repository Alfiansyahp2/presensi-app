# 🎓 Presensi App - Sistem Absensi Siswa

Sistem absensi siswa berbasis **GPS dengan Geofencing** untuk MA-2 Medokan Asri Tengah, Surabaya.

## 📋 Overview

**Presensi App** adalah sistem absensi yang memvalidasi kehadiran siswa berdasarkan lokasi GPS. Siswa hanya bisa melakukan absensi jika berada dalam radius **50 meter** dari lokasi sekolah menggunakan formula **Haversine** untuk perhitungan jarak.

## 🏗️ Architecture

Monorepo yang terdiri dari:

```
presensi-app/
├── backend/         <- Laravel 10 API
├── frontend/        <- Flutter Mobile App
├── docs/           <- Documentation
└── scripts/        <- Helper Scripts
```

## 🚀 Quick Start

### Prerequisites

- **Laravel:** PHP 8.1+, Composer, MySQL
- **Flutter:** Flutter SDK 3.6.1+, Dart
- **Tools:** Git, Android Studio / VS Code

### 1. Clone Repository

```bash
git clone <repository-url>
cd presensi-app
```

### 2. Backend Setup (Laravel)

```bash
cd backend

# Install dependencies
composer install

# Setup environment
cp .env.example .env
php artisan key:generate

# Configure database di .env
# DB_DATABASE=presensis
# DB_USERNAME=root
# DB_PASSWORD=

# Run migration & seeder
php artisan migrate:fresh --seed

# Start server
php artisan serve
# Access: http://localhost:8000
```

### 3. Frontend Setup (Flutter)

```bash
cd frontend

# Get dependencies
flutter pub get

# Run app (connected device/emulator)
flutter run

# Atau build APK
flutter build apk
```

## 📱 Features

### Backend (Laravel API)
- ✅ RESTful API dengan Laravel Sanctum
- ✅ User authentication (Register, Login, Logout)
- ✅ GPS-based attendance validation
- ✅ Geofencing radius 50 meter
- ✅ Attendance history
- ✅ Student profile management

### Frontend (Flutter Mobile)
- ✅ User registration & login
- ✅ Real-time GPS location tracking
- ✅ Interactive map (OpenStreetMap)
- ✅ Attendance submission
- ✅ Attendance history
- ✅ Profile management
- ✅ Persistent login (token storage)

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [API Documentation](docs/API.md) | API endpoints, request/response format |
| [Migration Guide](docs/MIGRATION_GUIDE.md) | Database migration & seeder guide |
| [Code Review Summary](docs/CODE_REVIEW_SUMMARY.md) | Models & Controllers analysis |
| [Deployment Guide](docs/DEPLOYMENT.md) | Production deployment guide |

## 🔧 Configuration

### Backend Configuration

**File:** `backend/.env`

```env
APP_NAME="Presensi App"
APP_ENV=local
APP_KEY=base64:...
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=presensis
DB_USERNAME=root
DB_PASSWORD=

# School Location (MA-2, Surabaya)
SCHOOL_LAT=-7.32787262808773
SCHOOL_LNG=112.79426795133186
SCHOOL_RADIUS=0.05
```

### Frontend Configuration

**File:** `frontend/lib/service/API_config.dart`

```dart
static const String _baseUrl = 'http://localhost:8000/api';
```

## 🗄️ Database Structure

### Tables

**users**
- `id`, `fullname`, `nisn` (unique), `kelas`, `email` (unique), `password`
- Timestamps: `created_at`, `updated_at`

**absens**
- `id`, `user_id` (FK), `status` (enum: hadir/izin/sakit)
- `latitude` (decimal 10,7), `longitude` (decimal 10,7)
- `waktu_absen` (timestamp)
- Timestamps: `created_at`, `updated_at`

## 🌐 API Endpoints

### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/register` | Register new student | Public |
| POST | `/api/login` | Login & get token | Public |
| POST | `/api/logout` | Logout user | Sanctum |
| GET | `/api/profile` | Get user profile | Sanctum |

### Attendance

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/absen` | Submit attendance | Sanctum |
| GET | `/api/history` | Get attendance history | Sanctum |

## 🧪 Testing

### Backend Tests

```bash
cd backend
php artisan test
```

### Frontend Tests

```bash
cd frontend
flutter test
```

## 📦 Tech Stack

### Backend
- **Framework:** Laravel 10
- **Language:** PHP 8.1+
- **Database:** MySQL 8.0
- **Authentication:** Laravel Sanctum
- **API:** RESTful

### Frontend
- **Framework:** Flutter 3.6.1
- **Language:** Dart
- **Maps:** Flutter Map (OpenStreetMap)
- **Location:** Geolocator
- **Storage:** Shared Preferences
- **HTTP:** http package

## 🔒 Security

- ✅ Password hashing (bcrypt)
- ✅ Token-based authentication (Sanctum)
- ✅ Input validation
- ✅ SQL injection protection (Eloquent ORM)
- ✅ CORS configuration
- ⚠️ Rate limiting (recommended to add)
- ⚠️ HTTPS enforcement (production)

## 🚢 Deployment

### Backend Deployment

See [Deployment Guide](docs/DEPLOYMENT.md) for detailed instructions.

### Frontend Deployment

```bash
cd frontend

# Build APK untuk Android
flutter build apk --release

# Build IPA untuk iOS
flutter build ios --release
```

## 📝 Development Guidelines

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

**Example:**
```
feat(backend): add daily attendance check

Prevent users from submitting attendance multiple times per day.

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

## 🐛 Troubleshooting

### Common Issues

**1. Laravel Server Not Starting**
```bash
# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Check port conflicts
# Use different port: php artisan serve --port=8001
```

**2. Flutter GPS Permission Denied**
- Add location permissions in:
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Info.plist`

**3. API Connection Refused**
- Ensure Laravel server is running
- Check API URL in `API_config.dart`
- Verify network permissions

## 📞 Support

For issues, questions, or contributions:
- 📧 Email: support@presensi-app.com
- 📱 WhatsApp: +62 xxx xxxx xxxx
- 🐛 Issues: [GitHub Issues](<repository-url>/issues)

## 📜 License

This project is for educational purposes (Ujikom).

## 👥 Credits

- **Backend Developer:** [Your Name]
- **Frontend Developer:** [Your Name]
- **Institution:** MA-2 Medokan Asri Tengah, Surabaya

---

**Version:** 1.0.0
**Last Updated:** 2026-06-21
**Status:** ✅ Production Ready
