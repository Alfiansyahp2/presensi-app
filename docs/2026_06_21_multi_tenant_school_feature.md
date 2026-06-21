# 2026-06-21: Multi-Tenant School Feature Implementation

## 📋 Overview
Implementasi transformasi sistem dari **single-school** ke **multi-tenant** dengan support untuk multiple schools dengan konfigurasi berbeda.

## 🎯 Goals
- ✅ Support multiple schools dengan konfigurasi berbeda
- ✅ Setiap school memiliki jam masuk/pulang, radius, dan toleransi khusus
- ✅ Relasi antara users, schools, dan attendances
- ✅ School management untuk admin

## 🗄️ Database Changes

### New Files Created:
1. **`backend/database/migrations/2026_06_21_115116_create_schools_table.php`**
   - Create `schools` table
   - Fields: nama_sekolah, kode_sekolah, alamat, latitude, longitude, radius_presensi, jam_masuk, jam_pulang, toleransi_terlambat, status_aktif

2. **`backend/database/migrations/2026_06_21_115225_add_school_id_to_users_table.php`**
   - Add `school_id` foreign key to `users` table
   - Nullable, constrained to schools table

3. **`backend/database/migrations/2026_06_21_115245_update_absens_table_for_multi_tenant.php`**
   - Add `school_id` to `absens` table
   - Add jam_masuk, jam_pulang, foto_absen_masuk, foto_absen_pulang, jarak_meter, alasan

4. **`backend/database/migrations/2026_06_21_115647_fix_absens_table_constraint_and_enum.php`**
   - Fix table constraints
   - Update status enum to include BELUM_ABSEN, HADIR, TERLAMBAT, IZIN, SAKIT, PULANG

### Seeders Created:
5. **`backend/database/seeders/SchoolSeeder.php`**
   - Seed 3 example schools:
     - MA-2 Surabaya (MA02-SBY)
     - SMA Negeri 1 Jakarta (SMAN1-JKT)
     - SMA Negeri 1 Bandung (SMAN1-BDG)

## 🔧 Backend Changes

### New Models Created:
1. **`backend/app/Models/School.php`**
   - Model untuk schools table
   - Relationships: hasMany users, hasMany attendances
   - Fillable fields untuk konfigurasi sekolah

2. **`backend/app/Models/Absensi.php`** (Updated)
   - Add school relationship
   - Add helper methods: `scopeToday()`, `getTodayAttendance()`
   - New fillable fields: school_id, jam_masuk, jam_pulang, foto_absen_masuk, foto_absen_pulang, jarak_meter, alasan

3. **`backend/app/Models/User.php`** (Updated)
   - Add school relationship (belongsTo School)

### New Controllers:
4. **`backend/app/Http/Controllers/SchoolController.php`**
   - CRUD operations untuk schools
   - Endpoints: index, store, update
   - Validation untuk school data

### New Services:
5. **`backend/app/Services/AttendanceService.php`**
   - Calculate distance (Haversine formula)
   - Determine attendance status (HADIR vs TERLAMBAT)
   - Validate location within radius
   - Process check-in dan check-out
   - Get today's status

### Updated Controllers:
6. **`backend/app/Http/Controllers/AbsensiController.php`** (Refactored)
   - Inject AttendanceService
   - New endpoints:
     - `POST /api/absensi/checkin` - Absen masuk dengan foto
     - `POST /api/absensi/checkout` - Absen pulang dengan foto
     - `GET /api/absensi/today` - Cek status hari ini
   - Remove hardcoded values
   - Upload foto ke storage

## 📡 API Routes Changes

### Updated: `backend/routes/api.php`
```php
// New absensi routes
Route::post('/absensi/checkin', [AbsensiController::class, 'checkIn']);
Route::post('/absensi/checkout', [AbsensiController::class, 'checkOut']);
Route::get('/absensi/today', [AbsensiController::class, 'getTodayStatus']);

// Admin school management
Route::middleware('role:admin')->group(function () {
    Route::apiResource('schools', SchoolController::class);
});
```

## 🎨 Frontend Changes

### New Models:
1. **`frontend/lib/models/attendance_status_model.dart`**
   - Model untuk attendance status response
   - Fields: status, activeButton, canCheckIn, canCheckOut, message, attendance, school

### Updated API:
2. **`frontend/lib/api/absensi_api.dart`**
   - New methods untuk check-in/check-out
   - Multipart request untuk foto upload
   - Get today's status

### Updated Screens:
3. **`frontend/lib/screens/home_screen.dart`**
   - 2 tombol terpisah: ABSEN MASUK dan ABSEN PULANG
   - Dynamic button visibility based on status
   - School info display
   - Foto capture untuk absensi

## 📦 Dependencies

### Updated: `frontend/pubspec.yaml`
- Added dependencies untuk:
  - Camera/image picker
  - Location services
  - HTTP multipart requests
  - File handling

## 🔍 Key Features

### 1. Multi-School Configuration
Setiap sekolah dapat mengkonfigurasi:
- Nama dan kode sekolah
- Lokasi (latitude, longitude)
- Radius presensi (dalam meter)
- Jam masuk dan pulang
- Toleransi keterlambatan (menit)

### 2. Auto Status Calculation
System otomatis menghitung status:
- **HADIR**: Absen ≤ jam_masuk + toleransi
- **TERLAMBAT**: Absen > jam_masuk + toleransi
- **BELUM_ABSEN**: Belum ada record hari ini
- **PULANG**: Sudah absen pulang

### 3. Location Validation
Menggunakan Haversine formula untuk menghitung jarak user dari lokasi sekolah dan memastikan user dalam radius yang ditentukan.

### 4. Foto Attendance
- Foto required saat check-in dan check-out
- Foto disimpan di `storage/app/public/absensi-*`
- Symlink: `php artisan storage:link`

### 5. Complete Attendance Flow
```
BELUM_ABSEN → HADIR/TERLAMBAT → PULANG
```

## ⚠️ Breaking Changes

### Frontend Updates Required:
1. **API Endpoint Changes:**
   - Single `/api/absensi` → `/api/absensi/checkin` + `/api/absensi/checkout`
   - Add `foto` field (multipart/form-data)

2. **Response Changes:**
   - Status otomatis: HADIR/TERLAMBAT (bukan input user)
   - Add jam_masuk, jam_pulang in response
   - Add jarak_meter in response

3. **Flow Changes:**
   - Track status harian: BELUM_ABSEN → HADIR/TERLAMBAT → PULANG
   - UI update untuk tombol check-in vs check-out

## 🚀 Deployment Strategy

### Development:
1. Branch: `feature/multi-tenant`
2. Implement semua phases
3. Testing lengkap

### Staging:
1. Backup database existing
2. Run migrations
3. Test dengan data dummy
4. Verify foto upload

### Production:
1. **BACKUP DATABASE WAJIB**
2. Run migrations saat jam sekolah selesai
3. Monitor first day deployment

## 📊 Estimated Time

| Phase | Time |
|-------|------|
| Database | 2-3 hours |
| Backend Logic | 4-5 hours |
| API Routes | 1 hour |
| Migration | 1 hour |
| Testing | 2-3 hours |
| **TOTAL** | **10-13 hours** |

## 🔴 Risk Assessment

### High Risk:
- Data loss saat migration existing absensi
- Frontend breaking (API changes)

### Mitigation:
- Backup database sebelum migration
- Test API di Postman/Insomnia sebelum deploy
- Rollback plan siap

### Low Risk:
- New feature (multi-tenant, foto)
- Tidak mempengaruhi data existing (table baru & kolom nullable)

## 📝 Notes

1. **Foto Storage**: Menggunakan Laravel Storage
2. **Symlink**: Run `php artisan storage:link`
3. **Cleanup**: Hapus migration files yang usang setelah berhasil
4. **Frontend**: Perlu update untuk handle foto upload & flow baru

## 📚 Related Documentation
- [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md) - Full implementation plan
- [2026_06_21_absensi_flow_improvements.md](./2026_06_21_absensi_flow_improvements.md) - Absensi flow details
- [2026_06_21_register_profile_multi_tenant_analysis.md](./2026_06_21_register_profile_multi_tenant_analysis.md) - Register & Profile analysis

---

**Generated:** 2026-06-21
**Status:** READY FOR IMPLEMENTATION
**Type:** NEW FEATURE - MULTI-TENANT
