# 🎓 Presensi App - Sistem Absensi Siswa

Sistem absensi siswa berbasis **GPS dengan Geofencing** untuk validasi kehadiran berdasarkan lokasi.

[![Flutter](https://img.shields.io/badge/Flutter-3.6.1-blue)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-10-red)](https://laravel.com)
[![License](https://img.shields.io/badge/License-Education-green)](LICENSE)

## 📋 Overview

**Presensi App** adalah sistem absensi yang memvalidasi kehadiran siswa berdasarkan lokasi GPS. Siswa hanya bisa melakukan absensi jika berada dalam radius **50 meter** dari lokasi sekolah menggunakan formula **Haversine** untuk perhitungan jarak yang akurat.

### ✨ Key Features

- 📍 **GPS-based Attendance** - Validasi lokasi real-time dengan geofencing
- 🗺️ **Interactive Maps** - Peta interaktif dengan OpenStreetMap
- 🌓 **Dark Mode** - Theme gelap/terang dengan persistent storage
- 🎨 **Formal Design** - UI professional dan modern
- 🔐 **Secure Authentication** - Token-based auth dengan Laravel Sanctum
- 📜 **Attendance History** - Riwayat absensi lengkap

## 🏗️ Architecture

Monorepo structure:

```
presensi-app/
├── backend/         <- Laravel 10 API
├── frontend/        <- Flutter Mobile App
└── DOCUMENTATION.md <- Complete documentation
```

## 🚀 Quick Start

### Prerequisites

- **Backend**: PHP 8.1+, Composer, MySQL
- **Frontend**: Flutter SDK 3.6.1+, Android Studio / VS Code
- **Tools**: Git, Postman (optional)

### Installation

```bash
# 1. Clone repository
git clone https://github.com/Alfiansyahp2/presensi-app.git
cd presensi-app

# 2. Backend Setup
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve

# 3. Frontend Setup
cd frontend
flutter pub get
flutter run
```

📖 **For detailed setup instructions, see [DOCUMENTATION.md](DOCUMENTATION.md)**

## 📱 Screenshots

| Home Screen | History Screen | Profile Screen |
|-------------|----------------|----------------|
| 🗺️ Interactive GPS Map | 📜 Attendance History | 👤 User Profile |
| Real-time location tracking | Complete attendance records | Profile management |
| Radius validation (50m) | Status indicators | Dark mode support |

## 🛠️ Tech Stack

### Backend
- **Framework**: Laravel 10
- **Language**: PHP 8.1+
- **Database**: MySQL 8.0
- **Authentication**: Laravel Sanctum
- **API**: RESTful

### Frontend
- **Framework**: Flutter 3.6.1
- **Language**: Dart
- **Maps**: Flutter Map (OpenStreetMap)
- **Location**: Geolocator
- **Storage**: Shared Preferences
- **State Management**: setState + SharedStorage

## 🔒 Security

- ✅ Password hashing (bcrypt)
- ✅ Token-based authentication (Sanctum)
- ✅ Input validation
- ✅ SQL injection protection (Eloquent ORM)
- ✅ CORS configuration
- ✅ API keys in `.gitignore` (local.properties)

🔐 **Security guidelines in [DOCUMENTATION.md](DOCUMENTATION.md#security-guidelines)**

## 📚 Documentation

Complete documentation available in [DOCUMENTATION.md](DOCUMENTATION.md):

- ⚙️ [Setup & Configuration](DOCUMENTATION.md#setup--configuration)
- 🔒 [Security Guidelines](DOCUMENTATION.md#security-guidelines)
- 🌐 [API Endpoints](DOCUMENTATION.md#api-endpoints)
- 🗄️ [Database Structure](DOCUMENTATION.md#database-structure)
- 👨‍💻 [Development Guidelines](DOCUMENTATION.md#development-guidelines)
- 🚢 [Deployment Guide](DOCUMENTATION.md#deployment)
- 🐛 [Troubleshooting](DOCUMENTATION.md#troubleshooting)

## 🌐 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | Register new student |
| POST | `/api/login` | Login & get token |
| POST | `/api/logout` | Logout user |
| GET | `/api/profile` | Get user profile |

### Attendance
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/absen` | Submit attendance |
| GET | `/api/history` | Get attendance history |

📖 **Full API documentation in [DOCUMENTATION.md](DOCUMENTATION.md#api-endpoints)**

## 🧪 Testing

```bash
# Backend Tests
cd backend
php artisan test

# Frontend Tests
cd frontend
flutter test
```

## 📦 Build & Release

```bash
# Build APK
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'feat: Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

📖 **See [Development Guidelines](DOCUMENTATION.md#development-guidelines)**

## 📝 Development Guidelines

- Follow [commit convention](DOCUMENTATION.md#commit-convention)
- Write clear commit messages
- Add tests for new features
- Update documentation

## 🐛 Troubleshooting

**Common Issues:**

- ❌ **GPS Permission Denied** → Check permissions in AndroidManifest.xml/Info.plist
- ❌ **API Connection Refused** → Ensure Laravel server running on port 8000
- ❌ **Maps Not Showing** → Verify Google Maps API key in local.properties

📖 **Full troubleshooting guide in [DOCUMENTATION.md](DOCUMENTATION.md#troubleshooting)**

## 📞 Support

For issues, questions, or contributions:
- 🐛 [GitHub Issues](https://github.com/Alfiansyahp2/presensi-app/issues)
- 📧 Email: support@presensi-app.com

## 📜 License

This project is for educational purposes (Ujikom).

## 👥 Credits

- **Backend Developer**: Alfiansyah
- **Frontend Developer**: Alfiansyah
- **Institution**: MA-2 Medokan Asri Tengah, Surabaya

---

**Version**: 1.0.0
**Last Updated**: 2026-06-21
**Status**: ✅ Production Ready

⭐ **Star this repo if it helped you!**
