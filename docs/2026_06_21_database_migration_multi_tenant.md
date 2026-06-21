# 2026-06-21: Database Migration for Multi-Tenant Support

## 📋 Overview
Complete database migration to transform the attendance system from single-school to multi-tenant architecture.

## 🎯 Goals
- ✅ Create schools table with configuration
- ✅ Add school_id foreign key to existing tables
- ✅ Enhance absens table with new fields
- ✅ Maintain data integrity with proper constraints
- ✅ Support migration of existing data

## 🗄️ Migrations Created

### 1. Create Schools Table
**File:** `backend/database/migrations/2026_06_21_115116_create_schools_table.php`

**Schema:**
```php
Schema::create('schools', function (Blueprint $table) {
    $table->id();
    $table->string('nama_sekolah');
    $table->string('kode_sekolah')->unique();
    $table->text('alamat')->nullable();
    $table->decimal('latitude', 10, 7);
    $table->decimal('longitude', 10, 7);
    $table->integer('radius_presensi')->default(50); // meter
    $table->time('jam_masuk')->default('07:00:00');
    $table->time('jam_pulang')->default('15:00:00');
    $table->integer('toleransi_terlambat')->default(10); // menit
    $table->boolean('status_aktif')->default(true);
    $table->timestamps();
    $table->softDeletes();
});
```

**Fields:**
- `nama_sekolah` - School name
- `kode_sekolah` - Unique school code
- `alamat` - Address (optional)
- `latitude` - Location latitude (decimal precision)
- `longitude` - Location longitude (decimal precision)
- `radius_presensi` - Attendance radius in meters
- `jam_masuk` - Default check-in time
- `jam_pulang` - Default check-out time
- `toleransi_terlambat` - Late tolerance in minutes
- `status_aktif` - Active status
- `softDeletes()` - Soft delete support

---

### 2. Add School ID to Users
**File:** `backend/database/migrations/2026_06_21_115225_add_school_id_to_users_table.php`

**Schema:**
```php
Schema::table('users', function (Blueprint $table) {
    $table->foreignId('school_id')
          ->nullable()
          ->after('id')
          ->constrained('schools')
          ->nullOnDelete();
});
```

**Features:**
- Foreign key to schools table
- Nullable (for backward compatibility)
- Null on delete (user tidak dihapus jika school dihapus)
- Index for performance

---

### 3. Update Absens Table for Multi-Tenant
**File:** `backend/database/migrations/2026_06_21_115245_update_absens_table_for_multi_tenant.php`

**Schema:**
```php
Schema::table('absens', function (Blueprint $table) {
    // Foreign key ke schools
    $table->foreignId('school_id')
          ->after('id')
          ->constrained('schools')
          ->cascadeOnDelete();

    // Jam masuk & pulang
    $table->time('jam_masuk')->nullable()->after('status');
    $table->time('jam_pulang')->nullable()->after('jam_masuk');

    // Foto absensi
    $table->string('foto_absen_masuk')->nullable()->after('jam_pulang');
    $table->string('foto_absen_pulang')->nullable()->after('foto_absen_masuk');

    // Jarak & alasan
    $table->integer('jarak_meter')->nullable()->after('longitude');
    $table->text('alasan')->nullable()->after('jarak_meter');

    // Update status enum
    $table->enum('status', ['BELUM_ABSEN', 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'PULANG'])
          ->default('BELUM_ABSEN')
          ->change();
});
```

**New Fields:**
- `school_id` - FK to schools (cascade delete)
- `jam_masuk` - Actual check-in time
- `jam_pulang` - Actual check-out time
- `foto_absen_masuk` - Check-in photo path
- `foto_absen_pulang` - Check-out photo path
- `jarak_meter` - Distance from school
- `alasan` - Attendance reason

**Status Enum Updated:**
- Old: (HADIR, IZIN, SAKIT)
- New: BELUM_ABSEN, HADIR, TERLAMBAT, IZIN, SAKIT, PULANG

---

### 4. Fix Absens Table Constraint & Enum
**File:** `backend/database/migrations/2026_06_21_115647_fix_absens_table_constraint_and_enum.php`

**Purpose:**
- Fix any migration issues
- Ensure constraints are properly set
- Verify enum values
- Add missing indexes if needed

---

## 🌱 Seeders

### School Seeder
**File:** `backend/database/seeders/SchoolSeeder.php`

**Data Seeded:**

#### 1. MA-2 Surabaya (Existing/Default)
```php
[
    'nama_sekolah' => 'MA-2 Surabaya',
    'kode_sekolah' => 'MA02-SBY',
    'latitude' => -7.3278726,
    'longitude' => 112.7942679,
    'radius_presensi' => 50,
    'jam_masuk' => '07:00:00',
    'jam_pulang' => '15:00:00',
    'toleransi_terlambat' => 10,
]
```

#### 2. SMA Negeri 1 Jakarta (Example)
```php
[
    'nama_sekolah' => 'SMA Negeri 1 Jakarta',
    'kode_sekolah' => 'SMAN1-JKT',
    'latitude' => -6.2088,
    'longitude' => 106.8456,
    'radius_presensi' => 100,
    'jam_masuk' => '06:30:00',
    'jam_pulang' => '14:00:00',
    'toleransi_terlambat' => 15,
]
```

#### 3. SMA Negeri 1 Bandung (Example)
```php
[
    'nama_sekolah' => 'SMA Negeri 1 Bandung',
    'kode_sekolah' => 'SMAN1-BDG',
    'latitude' => -6.9215,
    'longitude' => 107.6108,
    'radius_presensi' => 75,
    'jam_masuk' => '07:30:00',
    'jam_pulang' => '16:00:00',
    'toleransi_terlambat' => 5,
]
```

---

## 🔄 Migration Order

### Execute in Order:
```bash
# 1. Create schools table first
php artisan migrate --path=database/migrations/2026_06_21_115116_create_schools_table.php

# 2. Add school_id to users
php artisan migrate --path=database/migrations/2026_06_21_115225_add_school_id_to_users_table.php

# 3. Update absens table
php artisan migrate --path=database/migrations/2026_06_21_115245_update_absens_table_for_multi_tenant.php

# 4. Fix constraints
php artisan migrate --path=database/migrations/2026_06_21_115647_fix_absens_table_constraint_and_enum.php

# 5. Seed schools
php artisan db:seed --class=SchoolSeeder
```

### All at Once:
```bash
php artisan migrate
php artisan db:seed --class=SchoolSeeder
```

---

## 📊 Schema Changes Summary

### Before (Single-School):
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY,
    fullname VARCHAR(255),
    nisn VARCHAR(255),
    kelas VARCHAR(50),
    email VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE absens (
    id BIGINT UNSIGNED PRIMARY KEY,
    user_id BIGINT UNSIGNED,
    status ENUM('HADIR', 'IZIN', 'SAKIT'),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### After (Multi-Tenant):
```sql
CREATE TABLE schools (
    id BIGINT UNSIGNED PRIMARY KEY,
    nama_sekolah VARCHAR(255),
    kode_sekolah VARCHAR(255) UNIQUE,
    alamat TEXT,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    radius_presensi INTEGER DEFAULT 50,
    jam_masuk TIME DEFAULT '07:00:00',
    jam_pulang TIME DEFAULT '15:00:00',
    toleransi_terlambat INTEGER DEFAULT 10,
    status_aktif BOOLEAN DEFAULT 1,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY,
    school_id BIGINT UNSIGNED NULL,
    fullname VARCHAR(255),
    nisn VARCHAR(255),
    kelas VARCHAR(50),
    email VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE SET NULL
);

CREATE TABLE absens (
    id BIGINT UNSIGNED PRIMARY KEY,
    school_id BIGINT UNSIGNED,
    user_id BIGINT UNSIGNED,
    status ENUM('BELUM_ABSEN', 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'PULANG') DEFAULT 'BELUM_ABSEN',
    jam_masuk TIME NULL,
    jam_pulang TIME NULL,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    jarak_meter INTEGER NULL,
    alasan TEXT NULL,
    foto_absen_masuk VARCHAR(255) NULL,
    foto_absen_pulang VARCHAR(255) NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## 🔄 Data Migration Strategy

### Existing Users Migration:
```php
// In a seeder or migration
$ma2Surabaya = School::where('kode_sekolah', 'MA02-SBY')->first();

User::whereNull('school_id')->update([
    'school_id' => $ma2Surabaya->id,
]);
```

### Existing Attendance Records:
- Will stay as-is (no school_id initially)
- New records will have school_id
- Old records can be updated manually if needed

---

## ⚠️ Rollback Plan

### If Migration Fails:
```bash
# Rollback last migration
php artisan migrate:rollback

# Rollback all migrations
php artisan migrate:reset

# Fresh start (WARNING: deletes all data)
php artisan migrate:fresh
```

### Manual Rollback:
```sql
-- Remove foreign keys
ALTER TABLE absens DROP FOREIGN KEY absens_school_id_foreign;
ALTER TABLE users DROP FOREIGN KEY users_school_id_foreign;

-- Drop columns
ALTER TABLE absens DROP COLUMN school_id;
ALTER TABLE users DROP COLUMN school_id;

-- Drop table
DROP TABLE schools;
```

---

## 🔍 Verification Queries

### Check Tables:
```sql
-- Check schools table
DESCRIBE schools;
SELECT * FROM schools;

-- Check users table
DESCRIBE users;
SELECT id, fullname, school_id FROM users LIMIT 5;

-- Check absens table
DESCRIBE absens;
SELECT * FROM absens ORDER BY created_at DESC LIMIT 5;

-- Check foreign keys
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'schools';
```

### Check Data Integrity:
```sql
-- Orphaned users (school_id not in schools)
SELECT COUNT(*) FROM users
WHERE school_id IS NOT NULL
AND school_id NOT IN (SELECT id FROM schools);

-- Orphaned attendances (school_id not in schools)
SELECT COUNT(*) FROM absens
WHERE school_id NOT IN (SELECT id FROM schools);
```

---

## 📝 Notes

### Storage Requirements:
- Schools table: ~1KB per row
- Users table: +8 bytes per row (school_id)
- Absens table: ~200 bytes per row (new fields)

### Performance Impact:
- Foreign keys add slight overhead
- Indexes on school_id improve JOIN performance
- Enum values optimized internally

### Backup Before Migration:
```bash
# MySQL/MariaDB
mysqldump -u username -p database_name > backup_2026_06_21.sql

# Or use Laravel
php artisan db:backup
```

---

## 📚 Related Documentation
- [2026_06_21_multi_tenant_school_feature.md](./2026_06_21_multi_tenant_school_feature.md) - Feature overview
- [2026_06_21_absensi_flow_improvements.md](./2026_06_21_absensi_flow_improvements.md) - Flow changes
- [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md) - Full plan

---

**Generated:** 2026-06-21
**Status:** READY TO RUN
**Type:** DATABASE MIGRATION
**Impact:** HIGH - Run during low-traffic hours
