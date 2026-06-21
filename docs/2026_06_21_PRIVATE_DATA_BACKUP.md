# 🔒 PRIVATE DATA BACKUP

**Created:** 2026-06-21
**Purpose:** Backup data pribadi sebelum diganti dengan data generik untuk public repository

---

## ⚠️ DATA PRIBADI YANG DI-EXTRACT DARI CODEBASE

### **1. User Data (Dari UserSeeder.php & SQL Dump)**

| Field | Value | Location |
|-------|-------|----------|
| **Fullname** | arlen | UserSeeder.php:26 |
| **Email** | arlen@gmail.com | UserSeeder.php:24, 29 |
| **NISN** | 1234567890 | UserSeeder.php:27 |
| **Kelas** | 12 | UserSeeder.php:28 |
| **Password (Seeder)** | password123 | UserSeeder.php:30 |
| **Password (Hash)** | $2y$12$h0mcuhh6Y/n52XDY9CYD7O0S6PjbR2ZqF/xdaKB/bac4WdsVgxNmK | SQL dump |

**Source:** Database `presensis (2).sql` line 160-161

### **2. Absensi Data (Dari AbsensiSeeder.php)**

User `arlen@gmail.com` (user_id = 1) memiliki 5 record absensi:

| ID | Status | Latitude | Longitude | Waktu Absen |
|----|--------|----------|-----------|--------------|
| 1 | hadir | -7.3280711 | 112.7943562 | 2026-05-12 04:02:43 |
| 2 | hadir | -7.3280711 | 112.7943562 | 2026-05-12 04:02:54 |
| 3 | hadir | -7.3280711 | 112.7943562 | 2026-05-12 04:06:25 |
| 4 | hadir | -7.3280715 | 112.7943504 | 2026-05-12 04:06:44 |
| 5 | hadir | -7.3280644 | 112.7943562 | 2026-05-12 04:23:13 |

**Source:** Database `presensis (2).sql` line 45-50

### **3. Sekolah Location Data (Dari AbsensiController.php)**

| Field | Value | Location |
|-------|-------|----------|
| **Nama Sekolah** | MA-2 Medokan Asri Tengah | AbsensiController.php:22 |
| **Alamat Lengkap** | Jl. Medokan Asri Tengah No.12 Blok Q, Medokan Ayu, Kec. Rungkut, Surabaya | AbsensiController.php:22 |
| **Latitude** | -7.32787262808773 | AbsensiController.php:23 |
| **Longitude** | 112.79426795133186 | AbsensiController.php:24 |
| **Radius Absen** | 50 meter (0.05 km) | AbsensiController.php:33 |

**Source:** Code asli di backend/app/Http/Controllers/AbsensiController.php

### **4. Auth Tokens (Dari SQL Dump - HARI TINYA!)**

User `arlen@gmail.com` memiliki 11 tokens aktif di database:

| Token ID | Last Used | Created |
|----------|-----------|---------|
| 1 | - | 2026-05-04 19:55:39 |
| 2 | 2026-05-04 20:04:24 | 2026-05-04 19:55:54 |
| 3 | 2026-05-04 21:05:49 | 2026-05-04 20:17:23 |
| 4 | 2026-05-04 21:17:43 | 2026-05-04 21:07:08 |
| 5 | 2026-05-04 21:19:25 | 2026-05-04 21:19:09 |
| 6 | 2026-05-11 20:40:55 | 2026-05-11 20:28:36 |
| 7 | 2026-05-11 20:52:10 | 2026-05-11 20:41:08 |
| 8 | - | 2026-05-11 20:57:28 |
| 9 | 2026-05-11 21:06:45 | 2026-05-11 21:02:35 |
| 10 | 2026-05-11 21:15:59 | 2026-05-11 21:07:32 |
| 11 | 2026-05-11 21:33:06 | 2026-05-11 21:23:05 |

⚠️ **Rekomendasi:** Token-token ini lama dan sebaiknya di-revoke setelah migration!

---

## 📋 FILES YANG MENGANDUNG DATA PRIBADI

### **Sudah di-push ke GitHub:**

| File | Data Pribadi | Status |
|------|--------------|--------|
| `backend/database/seeders/UserSeeder.php` | arlen@gmail.com, 1234567890 | ⚠️ Exposed |
| `backend/database/seeders/AbsensiSeeder.php` | arlen@gmail.com reference | ⚠️ Exposed |
| `backend/app/Http/Controllers/AbsensiController.php` | Koordinat sekolah (Public info) | ✅ Safe |
| `docs/MIGRATION_GUIDE.md` | arlen@gmail.com, password123 | ⚠️ Exposed |
| `README.md` | MA-2, Koordinat sekolah (Public) | ✅ Safe |

### **Belum di-push (Local only):**

| File | Data | Status |
|------|------|--------|
| `PRIVATE_DATA_BACKUP.md` | Semua data pribadi | ✅ Safe (local) |
| `backend/.env` | APP_KEY | ✅ Safe (not in repo) |

---

## 🔒 RECOMMENDATION

### **Untuk Repository PUBLIC:**
1. ❌ **JANGAN** push email asli ke public repo
2. ❌ **JANGAN** push NISN asli ke public repo
3. ❌ **JANGAN** push nama lengkap asli ke public repo
4. ✅ **BOLEH** push nama sekolah publik
5. ✅ **BOLEH** push koordinat lokasi publik

### **Data yang HARUS diganti:**
- `arlen@gmail.com` → `siswa@example.com`
- `1234567890` → `1234567890` (boleh sama, ini test data)
- `arlen` → `Siswa Contoh` atau `Siswa Test`
- `password123` → Tetap `password123` (ini default untuk development)

---

## 💾 CARA RESTORE DATA INI

Jika butuh restore data asli:

```bash
# 1. Ganti UserSeeder.php dengan data asli
# 2. Ganti AbsensiSeeder.php dengan data asli
# 3. Run: php artisan db:seed --class=UserSeeder
# 4. Run: php artisan db:seed --class=AbsensiSeeder
```

Atau restore dari backup SQL:
```bash
mysql -u root presensis < C:\backup\presensi-app-migration\presensis (2).sql
```

---

**Created by:** Privacy Protection Script
**Date:** 2026-06-21
**Purpose:** Backup sebelum replace dengan data generik

⚠️ **HAPUS FILE INI SETELAH DATA DIGANTI JAN LUPA!**
