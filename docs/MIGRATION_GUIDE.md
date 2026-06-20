# 📋 Migration Guide - Database Structure Fix

**Created:** 2026-06-21
**Purpose:** Sync migration files dengan database aktual `presensis (2).sql`

---

## 🚨 Current Situation

### ❌ PROBLEM:
Migration files **TIDAK SESUAI** dengan database aktual

| File | Problem |
|------|---------|
| `2014_10_12_000000_create_users_table.php` | Membuat `name`, `role` (salah) |
| `2025_07_19_033859_create_absensis_table.php` | Membuat tabel `absensis`, kolom `tanggal`,`jam` (salah) |

### ✅ SOLUTION:
Migration baru yang **100% match** dengan database aktual:

| File | Description |
|------|-------------|
| `2024_06_21_000001_create_users_table_correct.php` | Tabel `users` dengan `fullname`, `nisn`, `kelas` |
| `2024_06_21_000002_create_absens_table_correct.php` | Tabel `absens` dengan `waktu_absen`, status yang benar |

---

## 🎯 STRUKTUR DATABASE YANG BENAR

### Tabel `users`
```sql
CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `fullname` varchar(255) NOT NULL,
  `nisn` varchar(255) NOT NULL UNIQUE,
  `kelas` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL UNIQUE,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) NULL,
  `created_at` timestamp NULL,
  `updated_at` timestamp NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_nisn_unique` (`nisn`)
);
```

### Tabel `absens`
```sql
CREATE TABLE `absens` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `status` enum('hadir','izin','sakit') NOT NULL DEFAULT 'hadir',
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `waktu_absen` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL,
  `updated_at` timestamp NULL,
  PRIMARY KEY (`id`),
  KEY `absens_user_id_foreign` (`user_id`),
  CONSTRAINT `absens_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);
```

---

## 📝 CARA MENJALANKAN MIGRATION

### Scenario A: Fresh Install (Development/Staging Baru)

Jika ini adalah setup environment baru:

```bash
# 1. Masuk ke directory project
cd C:\laragon\www\presensiweb

# 2. Install dependencies
composer install

# 3. Setup environment
cp .env.example .env
php artisan key:generate

# 4. Configure database di .env
# DB_DATABASE=presensis
# DB_USERNAME=root

# 5. Jalankan migration BARU
php artisan migrate

# 6. Jalankan seeder
php artisan db:seed
# Atau seeder specific:
# php artisan db:seed --class=UserSeeder
# php artisan db:seed --class=AbsensiSeeder
```

### Scenario B: Existing Database (Production/Sedang Development)

⚠️ **WARNING:** Hanya lakukan ini jika Anda yakin!

```bash
# 1. BACKUP DATABASE DULU (WAJIB!)
mysqldump -u root presensis > presensis_backup_$(date +%Y%m%d_%H%M%S).sql

# 2. Hapus semua tabel dan migrasi ulang
php artisan migrate:fresh

# 3. Seed data
php artisan db:seed

# 4. Verifikasi
php artisan migrate:status
```

### Scenario C: Keep Data, Add Migration Only

Untuk menambahkan migration baru tanpa menghapus data:

```bash
# 1. Backup tetap disarankan
mysqldump -u root presensis > presensis_backup.sql

# 2. Jalankan migration saja (tanpa fresh)
php artisan migrate

# Catatan: Karena database sudah ada dengan struktur yang benar,
# migration ini hanya akan tercatat di tabel 'migrations'
# tanpa mengubah struktur database
```

---

## 📦 DATA HASIL SEEDING

### Default Users

| Email | Password | Fullname | NISN | Kelas | Role |
|-------|----------|----------|------|------|------|
| `arlen@gmail.com` | `password123` | arlen | 1234567890 | 12 | Siswa |
| `admin@presensi.sch.id` | `admin123` | Administrator | ADMIN001 | ADMIN | Admin |
| `siswa1@test.com` | `password123` | Siswa Test 1 | 1234567891 | 10 | Siswa (local only) |
| `siswa2@test.com` | `password123` | Siswa Test 2 | 1234567892 | 11 | Siswa (local only) |
| `siswa3@test.com` | `password123` | Siswa Test 3 | 1234567893 | 12 | Siswa (local only) |

### Absensi Data
- 5 record absensi untuk user `arlen@gmail.com` dari May 12, 2026
- Tambahan data test untuk development (local environment only)

---

## 🔧 KONFIGURASI ENVIRONMENT

Tambahkan ke file `.env`:

```env
# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=presensis
DB_USERNAME=root
DB_PASSWORD=

# Seeder Passwords (Opsional)
SEEDER_PASSWORD=password123
ADMIN_PASSWORD=admin123

# Environment
APP_ENV=local
APP_DEBUG=true
```

---

## ✅ VERIFICATION

Setelah migration selesai, jalankan perintah ini untuk memverifikasi:

```bash
# Cek status migration
php artisan migrate:status

# Cek struktur tabel via tinker
php artisan tinker

# Di dalam tinker:
>>> Schema::getColumnListing('users')
=> ["id", "fullname", "nisn", "kelas", "email", "password", "remember_token", "created_at", "updated_at"]

>>> Schema::getColumnListing('absens')
=> ["id", "user_id", "status", "latitude", "longitude", "waktu_absen", "created_at", "updated_at"]

>>> \App\Models\User::count()
=> 5  // Jumlah user setelah seeder

>>> \App\Models\Absensi::count()
=> 8  // 5 dari arlen + 3 dari siswa1 (local only)
```

---

## 🚨 TROUBLESHOOTING

### Error: "Base table or view already exists"

**Cause:** Migration lama masih ada dan dijalankan

**Solution:**
```bash
# Hapus migration lama
rm database/migrations/2014_10_12_000000_create_users_table.php
rm database/migrations/2025_07_19_033859_create_absensis_table.php

# Atau rename ke _old
mv database/migrations/2014_10_12_000000_create_users_table.php database/migrations_old/
mv database/migrations/2025_07_19_033859_create_absensis_table.php database/migrations_old/

# Jalankan ulang
php artisan migrate:fresh --seed
```

### Error: "SQLSTATE[23000]: Integrity constraint violation"

**Cause:** Ada foreign key constraint yang conflict

**Solution:**
```bash
# Hapus semua tabel manual
mysql -u root -e "DROP DATABASE presensis; CREATE DATABASE presensis;"

# Jalankan migration ulang
php artisan migrate --seed
```

### Error: "Class 'Database\Seeders\UserSeeder' not found"

**Cause:** Laravel belum meng recognize seeder baru

**Solution:**
```bash
# Clear cache dan regenerate
composer dump-autoload
php artisan optimize:clear
php artisan db:seed
```

---

## 📋 MIGRATION FILES YANG DIBUAT

| File | Purpose | Date |
|------|---------|------|
| `2024_06_21_000001_create_users_table_correct.php` | Users table dengan struktur benar | 2026-06-21 |
| `2024_06_21_000002_create_absens_table_correct.php` | Absens table dengan struktur benar | 2026-06-21 |

## 📋 SEEDERS YANG DIBUAT

| File | Purpose | Date |
|------|---------|------|
| `UserSeeder.php` | Seed users (arlen + admin + test users) | 2026-06-21 |
| `AbsensiSeeder.php` | Seed absensi sesuai SQL dump | 2026-06-21 |
| `DatabaseSeeder.php` | Main seeder coordinator | 2026-06-21 |

---

## 🔗 MODEL & CONTROLLER STATUS

### ✅ SUDAH BENAR (Tidak perlu diubah)

| File | Status | Note |
|------|--------|------|
| `app/Models/User.php` | ✅ Correct | Sudah match dengan database aktual |
| `app/Models/Absensi.php` | ✅ Correct | Sudah menggunakan table='absens' |
| `app/Http/Controllers/AuthController.php` | ✅ Correct | Validasi dan fields sudah benar |
| `app/Http/Controllers/AbsensiController.php` | ✅ Correct | Sudah menggunakan 'waktu_absen' |

**Semua Model dan Controller sudah TIDAK PERLU DIUBAH** karena mereka sudah sesuai dengan database aktual.

---

## 📚 DOCUMENTATION

Untuk referensi lebih lanjut:
- Laravel Migration: https://laravel.com/docs/10.x/migrations
- Laravel Seeding: https://laravel.com/docs/10.x/seeding

---

## ⚡ QUICK COMMANDS

```bash
# Full setup fresh
php artisan migrate:fresh --seed

# Reset dan seed ulang
php artisan migrate:refresh --seed

# Cek migration status
php artisan migrate:status

# Rollback last migration
php artisan migrate:rollback

# Rollback semua migration
php artisan migrate:reset
```

---

**Created by:** Senior Software Architect
**Last updated:** 2026-06-21
