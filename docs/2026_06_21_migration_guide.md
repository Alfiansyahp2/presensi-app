# 2026-06-21: Migration Guide - Single-School to Multi-Tenant

## 📋 Overview
Panduan lengkap untuk migrasi sistem absensi dari single-school ke multi-tenant architecture.

## ⚠️ Prerequisites

### Before Starting Migration:
1. ✅ **Backup Database** (MANDATORY)
2. ✅ Backup codebase
3. ✅ Test di staging environment
4. ✅ Prepare rollback plan
5. ✅ Schedule maintenance window

---

## 🚀 Migration Steps

### Phase 1: Preparation

#### 1.1 Database Backup
```bash
# MySQL/MariaDB
mysqldump -u username -p database_name > backup_$(date +%Y%m%d_%H%M%S).sql

# Atau use Laravel
php artisan db:backup

# Verify backup
ls -lh backup_*.sql
```

#### 1.2 Code Backup
```bash
# Create backup branch
git checkout -b backup/pre-multi-tenant
git push origin backup/pre-multi-tenant

# Create working branch
git checkout main
git checkout -b feature/multi-tenant-migration
```

---

### Phase 2: Database Migration

#### 2.1 Run Migrations in Order

**Execute via Laravel:**
```bash
cd backend

# Check migrations status
php artisan migrate:status

# Run all new migrations
php artisan migrate

# Verify tables
php artisan db:show
```

**Manual Order (if needed):**
```bash
# 1. Create schools table
php artisan migrate --path=database/migrations/2026_06_21_115116_create_schools_table.php

# 2. Add school_id to users
php artisan migrate --path=database/migrations/2026_06_21_115225_add_school_id_to_users_table.php

# 3. Update absens table
php artisan migrate --path=database/migrations/2026_06_21_115245_update_absens_table_for_multi_tenant.php

# 4. Fix constraints
php artisan migrate --path=database/migrations/2026_06_21_115647_fix_absens_table_constraint_and_enum.php
```

#### 2.2 Seed Schools Data
```bash
php artisan db:seed --class=SchoolSeeder

# Verify schools
php artisan tinker
>>> School::all();
```

#### 2.3 Migrate Existing Users
```bash
# Create migration script
php artisan make:migration update_existing_users_with_school_id
```

**Content:**
```php
public function up()
{
    // Get default school
    $ma2Surabaya = School::where('kode_sekolah', 'MA02-SBY')->first();

    if (!$ma2Surabaya) {
        throw new Exception('MA-2 Surabaya school not found!');
    }

    // Update existing users
    DB::statement('UPDATE users SET school_id = ? WHERE school_id IS NULL', [$ma2Surabaya->id]);

    // Verify
    $orphanedUsers = DB::table('users')->whereNull('school_id')->count();
    Log::info("Migration complete. Orphaned users: {$orphanedUsers}");
}

public function down()
{
    DB::statement('UPDATE users SET school_id = NULL');
}
```

**Run migration:**
```bash
php artisan migrate
```

---

### Phase 3: Backend Updates

#### 3.1 Deploy New Code

**Copy files:**
```bash
# Models
cp app/Models/School.php backend/app/Models/
cp app/Models/User.php backend/app/Models/  # Updated
cp app/Models/Absensi.php backend/app/Models/  # Updated

# Controllers
cp app/Http/Controllers/SchoolController.php backend/app/Http/Controllers/
cp app/Http/Controllers/AbsensiController.php backend/app/Http/Controllers/  # Updated

# Services
mkdir -p backend/app/Services
cp app/Services/AttendanceService.php backend/app/Services/
```

#### 3.2 Update Routes
```bash
# Backup old routes
cp routes/api.php routes/api.php.backup

# Add new routes to routes/api.php
# See implementation guide
```

#### 3.3 Clear Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

### Phase 4: Frontend Updates

#### 4.1 Update Flutter Dependencies
```bash
cd frontend

# Add new dependencies to pubspec.yaml
flutter pub get

# Verify
flutter doctor
```

#### 4.2 Copy New Files
```bash
# Models
cp lib/models/attendance_status_model.dart frontend/lib/models/

# Update API
cp lib/api/absensi_api.dart frontend/lib/api/

# Update screens
cp lib/screens/home_screen.dart frontend/lib/screens/
```

#### 4.3 Build & Test
```bash
# Clean build
flutter clean
flutter pub get

# Run app
flutter run

# Test all features
```

---

### Phase 5: Storage Setup

#### 5.1 Create Storage Link
```bash
cd backend

# Create symbolic link
php artisan storage:link

# Verify
ls -la public/storage
```

#### 5.2 Set Permissions
```bash
# Linux/Mac
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Windows (IIS)
icacls "storage" /grant Users:(OI)(CI)F
icacls "bootstrap/cache" /grant Users:(OI)(CI)F
```

---

## ✅ Verification Steps

### Database Verification

```sql
-- 1. Check schools table
SELECT * FROM schools;

-- 2. Check users with school_id
SELECT COUNT(*) as total_users,
       COUNT(school_id) as users_with_school,
       COUNT(*) - COUNT(school_id) as orphaned_users
FROM users;

-- 3. Check absens table structure
DESCRIBE absens;

-- 4. Verify foreign keys
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'schools';

-- 5. Check for orphaned records
SELECT COUNT(*) FROM absens WHERE school_id NOT IN (SELECT id FROM schools);
```

**Expected Results:**
- ✅ 3 schools inserted
- ✅ All users have school_id
- ✅ No orphaned absens records
- ✅ Foreign keys properly set

---

### Backend Verification

```bash
# Test API endpoints
curl -X GET http://localhost:8000/api/schools \
  -H "Authorization: Bearer {admin_token}"

# Test check-in
curl -X POST http://localhost:8000/api/absensi/checkin \
  -H "Authorization: Bearer {user_token}" \
  -F "latitude=-7.3278726" \
  -F "longitude=112.7942679" \
  -F "foto=@/path/to/photo.jpg"

# Test today's status
curl -X GET http://localhost:8000/api/absensi/today \
  -H "Authorization: Bearer {user_token}"
```

**Expected Results:**
- ✅ Schools endpoint returns 3 schools
- ✅ Check-in creates record with school_id
- ✅ Today status shows correct button state

---

### Frontend Verification

**Manual Testing Checklist:**

1. **Login:**
   - [ ] Can login with existing user
   - [ ] Profile shows school info
   - [ ] Token works correctly

2. **Attendance:**
   - [ ] School info displayed
   - [ ] Correct button shown based on status
   - [ ] Check-in works with photo
   - [ ] Check-out works with photo
   - [ ] Status updates correctly

3. **History:**
   - [ ] Can view attendance history
   - [ ] School info shown in history
   - [ ] Photos displayed correctly

---

## 🔄 Rollback Plan

### If Migration Fails:

#### Step 1: Database Rollback
```bash
cd backend

# Rollback last migration
php artisan migrate:rollback

# Rollback all migrations
php artisan migrate:reset

# Restore from backup
mysql -u username -p database_name < backup_YYYYMMDD_HHMMSS.sql
```

#### Step 2: Code Rollback
```bash
# Switch to backup branch
git checkout backup/pre-multi-tenant

# Or revert commits
git revert <commit-hash>

# Deploy old code
```

#### Step 3: Frontend Rollback
```bash
cd frontend

# Revert to previous commit
git checkout <previous-commit-hash>

# Rebuild
flutter clean
flutter pub get
flutter build apk
```

---

## 🐛 Troubleshooting

### Issue 1: Migration Fails
**Error:** `SQLSTATE[HY000]: General error: 1215 Cannot add foreign key constraint`

**Solution:**
```sql
-- Check storage engine
SHOW ENGINE;
-- Should be InnoDB

-- Check table types
SELECT TABLE_NAME, ENGINE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'presensi_app';
```

---

### Issue 2: Orphaned Users
**Error:** Users with `school_id = NULL`

**Solution:**
```bash
php artisan tinker
>>> $school = School::first();
>>> DB::table('users')->whereNull('school_id')->update(['school_id' => $school->id]);
```

---

### Issue 3: Photo Upload Fails
**Error:** `The photo field is required`

**Solution:**
```bash
# Check storage link
php artisan storage:link

# Check permissions
ls -la storage/app/public

# Check .env
# APP_URL must be correct
php artisan config:clear
```

---

### Issue 4: API Returns 404
**Error:** New endpoints not found

**Solution:**
```bash
# Clear route cache
php artisan route:clear
php artisan route:cache

# Verify routes
php artisan route:list | grep absensi
```

---

## 📊 Post-Migration Tasks

### Immediate (Day 1):
1. ✅ Monitor error logs
2. ✅ Check API response times
3. ✅ Verify data integrity
4. ✅ Test with real users
5. ✅ Monitor photo uploads

### Short Term (Week 1):
1. ✅ Add monitoring (Sentry, Bugsnag)
2. ✅ Implement caching
3. ✅ Performance optimization
4. ✅ User training
5. ✅ Documentation updates

### Long Term (Month 1):
1. ✅ Load testing
2. ✅ Security audit
3. ✅ Feature enhancements
4. ✅ User feedback collection
5. ✅ Next phase planning

---

## 📞 Support

### If Issues Arise:

1. **Check Logs:**
   ```bash
   # Laravel logs
   tail -f backend/storage/logs/laravel.log

   # Web server logs
   tail -f /var/log/nginx/error.log
   ```

2. **Verify Database:**
   ```sql
   -- Check for corruption
   CHECK TABLE users, absens, schools;
   ```

3. **Contact Support:**
   - 📧 Email: support@presensi-app.com
   - 🐛 Issues: [GitHub Issues](https://github.com/Alfiansyahp2/presensi-app/issues)

---

## 📝 Checklist

### Pre-Migration:
- [ ] Database backed up
- [ ] Code backed up
- [ ] Migration plan reviewed
- [ ] Stakeholders notified
- [ ] Maintenance window scheduled

### During Migration:
- [ ] Migrations run successfully
- [ ] Seeders executed
- [ ] Existing data migrated
- [ ] Code deployed
- [ ] Cache cleared
- [ ] Storage linked

### Post-Migration:
- [ ] Database verified
- [ ] API endpoints tested
- [ ] Frontend tested
- [ ] Photos uploaded successfully
- [ ] User acceptance testing
- [ ] Monitoring enabled

---

## 📚 Related Documentation
- [2026_06_21_database_migration_multi_tenant.md](./2026_06_21_database_migration_multi_tenant.md)
- [2026_06_21_multi_tenant_school_feature.md](./2026_06_21_multi_tenant_school_feature.md)
- [2026_06_21_code_review_summary.md](./2026_06_21_code_review_summary.md)

---

**Created:** 2026-06-21
**Status:** READY FOR PRODUCTION
**Type:** MIGRATION GUIDE
**Priority:** HIGH - Follow in order
