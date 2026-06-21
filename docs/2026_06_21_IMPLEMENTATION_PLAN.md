# Implementation Plan: Multi-Tenant School Attendance System

## 📋 OVERVIEW
Transformasi sistem absensi dari **single-school** ke **multi-tenant** dengan fitur lengkap:
- Multi-school configuration
- Foto absensi
- Auto status calculation (HADIR/TERLAMBAT)
- Auto-checkout (absen pulang)

---

## 🎯 GOALS
1. ✅ Support multiple schools dengan konfigurasi berbeda
2. ✅ Foto absensi untuk verifikasi kehadiran
3. ✅ Status otomatis berdasarkan jam & toleransi
4. ✅ Flow lengkap: BELUM_ABSEN → HADIR/TERLAMBAT → PULANG
5. ✅ Tanpa hardcoded values (semua dinamis dari database)

---

## 📊 PHASE 1: DATABASE SCHEMA

### Step 1.1: Create Schools Table
**File**: `database/migrations/YYYY_MM_DD_HHMMSS_create_schools_table.php`

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

### Step 1.2: Add school_id to Users Table
**File**: `database/migrations/YYYY_MM_DD_HHMMSS_add_school_id_to_users_table.php`

```php
Schema::table('users', function (Blueprint $table) {
    $table->foreignId('school_id')
          ->nullable()
          ->after('id')
          ->constrained('schools')
          ->nullOnDelete();
});
```

### Step 1.3: Update Absens Table
**File**: `database/migrations/YYYY_MM_DD_HHMMSS_update_absens_table.php`

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

### Step 1.4: Create School Seeder
**File**: `database/seeders/SchoolSeeder.php`

```php
// Sekolah A - MA-2 Surabaya (existing)
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

// Sekolah B - Contoh
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

// Sekolah C - Contoh
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

## 🔧 PHASE 2: BACKEND LOGIC

### Step 2.1: Create School Model
**File**: `app/Models/School.php`

```php
class School extends Model
{
    protected $fillable = [
        'nama_sekolah',
        'kode_sekolah',
        'alamat',
        'latitude',
        'longitude',
        'radius_presensi',
        'jam_masuk',
        'jam_pulang',
        'toleransi_terlambat',
        'status_aktif',
    ];

    protected $casts = [
        'status_aktif' => 'boolean',
        'jam_masuk' => 'datetime:H:i:s',
        'jam_pulang' => 'datetime:H:i:s',
    ];

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function attendances()
    {
        return $this->hasMany(Absensi::class, 'school_id');
    }
}
```

### Step 2.2: Update User Model
**File**: `app/Models/User.php`

```php
class User extends Authenticatable
{
    // Add school relationship
    public function school()
    {
        return $this->belongsTo(School::class);
    }
}
```

### Step 2.3: Update Absensi Model
**File**: `app/Models/Absensi.php`

```php
class Absensi extends Model
{
    protected $table = 'absens';

    protected $fillable = [
        'school_id',
        'user_id',
        'status',
        'jam_masuk',
        'jam_pulang',
        'latitude',
        'longitude',
        'jarak_meter',
        'alasan',
        'foto_absen_masuk',
        'foto_absen_pulang',
    ];

    protected $casts = [
        'jam_masuk' => 'datetime:H:i:s',
        'jam_pulang' => 'datetime:H:i:s',
    ];

    public function school()
    {
        return $this->belongsTo(School::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Helper: check status hari ini
    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    // Helper: absen hari ini user
    public static function getTodayAttendance($userId)
    {
        return self::where('user_id', $userId)
                   ->today()
                   ->first();
    }
}
```

### Step 2.4: Create AttendanceService
**File**: `app/Services/AttendanceService.php`

```php
class AttendanceService
{
    /**
     * Hitung jarak menggunakan Haversine formula
     */
    public function calculateDistance($lat1, $lon1, $lat2, $lon2): float
    {
        $earthRadius = 6371; // km

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * asin(sqrt($a));
        $distance = $earthRadius * $c; // km

        return $distance * 1000; // meter
    }

    /**
     * Tentukan status berdasarkan waktu & toleransi
     */
    public function determineStatus($waktuAbsen, School $school): string
    {
        $jamMasuk = Carbon::parse($school->jam_masuk);
        $toleransi = $school->toleransi_terlambat; // menit
        $batasTerlambat = $jamMasuk->addMinutes($toleransi);

        if ($waktuAbsen->lte($batasTerlambat)) {
            return 'HADIR';
        } else {
            return 'TERLAMBAT';
        }
    }

    /**
     * Validasi apakah user dalam radius
     */
    public function validateLocation($userLat, $userLon, School $school): array
    {
        $distance = $this->calculateDistance(
            $userLat, $userLon,
            $school->latitude, $school->longitude
        );

        $isValid = $distance <= $school->radius_presensi;

        return [
            'valid' => $isValid,
            'distance' => round($distance, 2),
            'radius' => $school->radius_presensi,
        ];
    }

    /**
     * Proses absen masuk
     */
    public function checkIn(User $user, $data): Absensi
    {
        $school = $user->school;
        $waktuAbsen = now();

        // Validasi lokasi
        $location = $this->validateLocation(
            $data['latitude'],
            $data['longitude'],
            $school
        );

        if (!$location['valid']) {
            throw new \Exception("Di luar radius presensi. Jarak: {$location['distance']}m (Max: {$location['radius']}m)");
        }

        // Tentukan status
        $status = $this->determineStatus($waktuAbsen, $school);

        // Simpan absen
        return Absensi::create([
            'school_id' => $school->id,
            'user_id' => $user->id,
            'status' => $status,
            'jam_masuk' => $waktuAbsen->format('H:i:s'),
            'latitude' => $data['latitude'],
            'longitude' => $data['longitude'],
            'jarak_meter' => $location['distance'],
            'foto_absen_masuk' => $data['foto'] ?? null,
            'alasan' => $data['alasan'] ?? null,
        ]);
    }

    /**
     * Proses absen pulang
     */
    public function checkOut(User $user, $data): Absensi
    {
        $attendance = Absensi::getTodayAttendance($user->id);

        if (!$attendance) {
            throw new \Exception("Belum absen masuk hari ini");
        }

        if (!in_array($attendance->status, ['HADIR', 'TERLAMBAT'])) {
            throw new \Exception("Status tidak valid untuk absen pulang");
        }

        // Validasi jam pulang
        $school = $user->school;
        $jamPulang = Carbon::parse($school->jam_pulang);
        $waktuSekarang = now();

        if ($waktuSekarang->lt($jamPulang)) {
            throw new \Exception("Belum waktunya absen pulang. Jam pulang: {$school->jam_pulang}");
        }

        // Update absen
        $attendance->update([
            'status' => 'PULANG',
            'jam_pulang' => $waktuSekarang->format('H:i:s'),
            'foto_absen_pulang' => $data['foto'] ?? null,
        ]);

        return $attendance->fresh();
    }

    /**
     * Cek status hari ini
     */
    public function getTodayStatus($userId): array
    {
        $attendance = Absensi::getTodayAttendance($userId);

        if (!$attendance) {
            return [
                'status' => 'BELUM_ABSEN',
                'data' => null,
            ];
        }

        return [
            'status' => $attendance->status,
            'data' => $attendance,
        ];
    }
}
```

### Step 2.5: Refactor AbsensiController
**File**: `app/Http/Controllers/AbsensiController.php`

```php
class AbsensiController extends Controller
{
    protected $attendanceService;

    public function __construct(AttendanceService $attendanceService)
    {
        $this->attendanceService = $attendanceService;
    }

    /**
     * Absen masuk
     * POST /api/absensi/checkin
     */
    public function checkIn(Request $request)
    {
        $validated = $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'foto' => 'required|image|max:2048', // max 2MB
            'alasan' => 'nullable|string',
        ]);

        try {
            $user = auth()->user();

            // Check apakah sudah absen hari ini
            $existing = Absensi::getTodayAttendance($user->id);
            if ($existing) {
                return response()->json([
                    'message' => 'Sudah absen hari ini',
                    'data' => $existing,
                ], 400);
            }

            // Upload foto
            if ($request->hasFile('foto')) {
                $fotoPath = $request->file('foto')
                                    ->store('absensi-masuk', 'public');
                $validated['foto'] = $fotoPath;
            }

            // Proses absen
            $attendance = $this->attendanceService->checkIn($user, $validated);

            return response()->json([
                'message' => 'Absen masuk berhasil',
                'data' => $attendance,
                'status_info' => [
                    'status' => $attendance->status,
                    'jam_masuk' => $attendance->jam_masuk,
                    'jarak' => $attendance->jarak_meter . 'm',
                ],
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Absen pulang
     * POST /api/absensi/checkout
     */
    public function checkOut(Request $request)
    {
        $validated = $request->validate([
            'foto' => 'required|image|max:2048',
        ]);

        try {
            $user = auth()->user();

            // Upload foto
            if ($request->hasFile('foto')) {
                $fotoPath = $request->file('foto')
                                    ->store('absensi-pulang', 'public');
                $validated['foto'] = $fotoPath;
            }

            // Proses absen pulang
            $attendance = $this->attendanceService->checkOut($user, $validated);

            return response()->json([
                'message' => 'Absen pulang berhasil',
                'data' => $attendance,
                'status_info' => [
                    'status' => $attendance->status,
                    'jam_masuk' => $attendance->jam_masuk,
                    'jam_pulang' => $attendance->jam_pulang,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Cek status hari ini
     * GET /api/absensi/today
     */
    public function getTodayStatus(Request $request)
    {
        $user = auth()->user();
        $status = $this->attendanceService->getTodayStatus($user->id);

        return response()->json($status);
    }
}
```

### Step 2.6: Create SchoolController
**File**: `app/Http/Controllers/SchoolController.php`

```php
class SchoolController extends Controller
{
    public function index()
    {
        $schools = School::all();
        return response()->json($schools);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_sekolah' => 'required|string',
            'kode_sekolah' => 'required|string|unique:schools,kode_sekolah',
            'alamat' => 'nullable|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius_presensi' => 'required|integer|min:10',
            'jam_masuk' => 'required|date_format:H:i:s',
            'jam_pulang' => 'required|date_format:H:i:s',
            'toleransi_terlambat' => 'required|integer|min:0',
        ]);

        $school = School::create($validated);

        return response()->json($school, 201);
    }

    public function update(Request $request, $id)
    {
        $school = School::findOrFail($id);

        $validated = $request->validate([
            'nama_sekolah' => 'sometimes|string',
            'alamat' => 'sometimes|string',
            'latitude' => 'sometimes|numeric',
            'longitude' => 'sometimes|numeric',
            'radius_presensi' => 'sometimes|integer|min:10',
            'jam_masuk' => 'sometimes|date_format:H:i:s',
            'jam_pulang' => 'sometimes|date_format:H:i:s',
            'toleransi_terlambat' => 'sometimes|integer|min:0',
            'status_aktif' => 'sometimes|boolean',
        ]);

        $school->update($validated);

        return response()->json($school);
    }
}
```

---

## 📱 PHASE 3: API ROUTES

### Step 3.1: Update routes/api.php
**File**: `routes/api.php`

```php
// Absensi routes
Route::middleware('auth:sanctum')->group(function () {
    // Check-in & check-out
    Route::post('/absensi/checkin', [AbsensiController::class, 'checkIn']);
    Route::post('/absensi/checkout', [AbsensiController::class, 'checkOut']);

    // Status hari ini
    Route::get('/absensi/today', [AbsensiController::class, 'getTodayStatus']);

    // Riwayat absensi
    Route::get('/absensi/history', [AbsensiController::class, 'history']);

    // Admin only - school management
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('schools', SchoolController::class);
    });
});
```

---

## 🗄️ PHASE 4: MIGRATION EXISTING DATA

### Step 4.1: Update Existing Users
**File**: `database/migrations/XXXX_XX_XX_XXXXXX_update_existing_users.php`

```php
// Assign existing users ke default school (MA-2 Surabaya)
$ma2Surabaya = School::where('kode_sekolah', 'MA02-SBY')->first();

User::whereNull('school_id')->update([
    'school_id' => $ma2Surabaya->id,
]);
```

---

## 📋 IMPLEMENTATION CHECKLIST

### Database (MUST DO IN ORDER):
- [ ] Create `schools` table migration
- [ ] Add `school_id` to `users` table
- [ ] Update `absens` table structure
- [ ] Run migrations: `php artisan migrate`
- [ ] Create & run `SchoolSeeder`
- [ ] Update existing users with school_id
- [ ] Verify database structure

### Backend Logic:
- [ ] Create `School` model
- [ ] Update `User` model (add school relationship)
- [ ] Update `Absensi` model (add school relationship & helpers)
- [ ] Create `AttendanceService` with all logic
- [ ] Refactor `AbsensiController` (remove hardcoded values)
- [ ] Create `SchoolController`
- [ ] Update API routes
- [ ] Test API endpoints

### Testing:
- [ ] Test check-in dengan foto
- [ ] Test status otomatis (HADIR vs TERLAMBAT)
- [ ] Test check-out flow
- [ ] Test multi-school (user dari sekolah berbeda)
- [ ] Test radius validation
- [ ] Test jam pulang validation

---

## ⚠️ BREAKING CHANGES

### Frontend Updates Required:
1. **Endpoint changes:**
   - Single `/api/absensi` → `/api/absensi/checkin` + `/api/absensi/checkout`
   - Tambahkan field `foto` (multipart/form-data)

2. **Response changes:**
   - Status sekarang otomatis: `HADIR`/`TERLAMBAT` (bukan input user)
   - Tambahkan `jam_masuk`, `jam_pulang` di response
   - Tambahkan `jarak_meter` di response

3. **Flow changes:**
   - Sistem sekarang track status harian: `BELUM_ABSEN` → `HADIR`/`TERLAMBAT` → `PULANG`
   - Perlu UI update untuk tombol check-in vs check-out

---

## 🚀 DEPLOYMENT STRATEGY

### Development:
1. Branch `feature/multi-tenant`
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

---

## 📊 ESTIMATED TIME

| Phase | Estimated Time |
|-------|----------------|
| Phase 1: Database | 2-3 hours |
| Phase 2: Backend Logic | 4-5 hours |
| Phase 3: API Routes | 1 hour |
| Phase 4: Migration | 1 hour |
| Testing | 2-3 hours |
| **TOTAL** | **10-13 hours** |

---

## 🔴 RISK ASSESSMENT

### High Risk:
- Data loss saat migration existing absensi
- Frontend breaking (API changes)

### Mitigation:
- Backup database sebelum migration
- Test API di Postman/Insomnia sebelum deploy
- Rollback plan siap

### Low Risk:
- New feature (multi-tenant, foto)
- Tidak mempengaruhi data existing (karena table baru & kolom nullable)

---

## 📝 NOTES

1. **Foto Storage**: Menggunakan Laravel Storage (`storage/app/public/absensi-*`)
2. **Symlink**: Run `php artisan storage:link` agar foto accessible
3. **Cleanup**: Hapus migration files yang usang setelah berhasil
4. **Frontend**: Perlu update untuk handle foto upload & flow baru

---

Generated: 2026-06-21
Status: READY FOR IMPLEMENTATION
