# 2026-06-21: Absensi Flow Improvements & 2-Button System

## 📋 Overview
Implementasi sistem absensi dengan 2 tombol terpisah (ABSEN MASUK dan ABSEN PULANG) yang dinamis berdasarkan status hari ini, lengkap dengan foto attendance dan auto status calculation.

## 🎯 Goals
- ✅ Tombol ABSEN MASUK hanya muncul jika belum absen hari ini
- ✅ Tombol ABSEN PULANG hanya muncul setelah absen masuk
- ✅ Foto wajib saat check-in dan check-out
- ✅ Auto status calculation (HADIR/TERLAMBAT) berdasarkan waktu dan toleransi
- ✅ Server-driven button state

## 🔄 Flow Logic

### Attendance Status Lifecycle:
```
BELUM_ABSEN → HADIR/TERLAMBAT → PULANG
```

### Button Display Logic:
```
1. Buka Screen → GET /api/absensi/today
   ↓
2. Cek active_button:
   - "checkin" → Tampilkan tombol ABSEN MASUK saja (hijau)
   - "checkout" → Tampilkan tombol ABSEN PULANG saja (orange)
   - "none" → Tidak ada tombol aktif
   ↓
3. User klik tombol:
   - ABSEN MASUK → POST /api/absensi/checkin + upload foto
   - ABSEN PULANG → POST /api/absensi/checkout + upload foto
   ↓
4. Setelah berhasil → Refresh status (GET /api/absensi/today lagi)
   ↓
5. Update UI sesuai status baru
```

## 📡 API Endpoints

### 1. Cek Status Hari Ini
```http
GET /api/absensi/today
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "BELUM_ABSEN" | "HADIR" | "TERLAMBAT" | "PULANG",
    "active_button": "checkin" | "checkout" | "none",
    "can_checkin": true | false,
    "can_checkout": true | false,
    "message": "Silakan absen masuk",
    "attendance": {
      "id": 1,
      "jam_masuk": "07:05:00",
      "jam_pulang": null,
      "status": "HADIR",
      "jarak_meter": 25.5
    },
    "school": {
      "nama_sekolah": "MA-2 Surabaya",
      "jam_masuk": "07:00:00",
      "jam_pulang": "15:00:00",
      "radius_presensi": 50
    }
  }
}
```

### 2. Absen Masuk
```http
POST /api/absensi/checkin
Authorization: Bearer {token}
Content-Type: multipart/form-data

latitude: -7.3278726
longitude: 112.7942679
foto: [file image]
alasan: "Masuk normal" (optional)
```

**Response (201 Created):**
```json
{
  "message": "Absen masuk berhasil",
  "data": {
    "id": 1,
    "school_id": 1,
    "user_id": 5,
    "status": "HADIR",
    "jam_masuk": "07:05:00",
    "jam_pulang": null,
    "latitude": -7.3278726,
    "longitude": 112.7942679,
    "jarak_meter": 25.5,
    "foto_absen_masuk": "absensi-masuk/filename.jpg",
    "created_at": "2026-06-21T07:05:00.000000Z"
  },
  "status_info": {
    "status": "HADIR",
    "jam_masuk": "07:05:00",
    "jarak": "25.5m"
  }
}
```

### 3. Absen Pulang
```http
POST /api/absensi/checkout
Authorization: Bearer {token}
Content-Type: multipart/form-data

foto: [file image]
```

**Response (200 OK):**
```json
{
  "message": "Absen pulang berhasil",
  "data": {
    "id": 1,
    "status": "PULANG",
    "jam_masuk": "07:05:00",
    "jam_pulang": "15:05:00",
    "foto_absen_masuk": "absensi-masuk/filename.jpg",
    "foto_absen_pulang": "absensi-pulang/filename2.jpg"
  },
  "status_info": {
    "status": "PULANG",
    "jam_masuk": "07:05:00",
    "jam_pulang": "15:05:00"
  }
}
```

## 🎨 Frontend Implementation

### Model Created:
**File:** `frontend/lib/models/attendance_status_model.dart`

```dart
class AttendanceStatus {
  final String status;
  final String activeButton;
  final bool canCheckIn;
  final bool canCheckOut;
  final String message;
  final Attendance? attendance;
  final SchoolInfo? school;

  // Constructor, fromJson, etc.
}

class SchoolInfo {
  final String namaSekolah;
  final String jamMasuk;
  final String jamPulang;
  final int radiusPresensi;

  // Constructor, fromJson, etc.
}
```

### API Service Updated:
**File:** `frontend/lib/api/absensi_api.dart`

**New Methods:**
- `getTodayStatus()` - Get current attendance status
- `checkIn()` - Check-in with photo
- `checkOut()` - Check-out with photo

### UI Implementation:
**File:** `frontend/lib/screens/home_screen.dart`

**Key Features:**
1. **School Info Card** - Display school configuration
2. **Status Card** - Show today's attendance status
3. **Dynamic Buttons** - Only one button active at a time
4. **Photo Capture** - Camera integration for attendance photos

## 🔧 Backend Implementation

### Service Created:
**File:** `backend/app/Services/AttendanceService.php`

**Methods:**
1. `calculateDistance($lat1, $lon1, $lat2, $lon2)` - Haversine formula
2. `determineStatus($waktuAbsen, School $school)` - Auto status calculation
3. `validateLocation($userLat, $userLon, School $school)` - Radius check
4. `checkIn(User $user, $data)` - Process check-in
5. `checkOut(User $user, $data)` - Process check-out
6. `getTodayStatus($userId)` - Get today's attendance

### Controller Refactored:
**File:** `backend/app/Http/Controllers/AbsensiController.php`

**New Methods:**
1. `checkIn(Request $request)` - Handle check-in with photo upload
2. `checkOut(Request $request)` - Handle check-out with photo upload
3. `getTodayStatus(Request $request)` - Return status for button logic

**Removed/Changed:**
- Hardcoded values removed
- Single endpoint split into checkin/checkout
- Photo upload handling added

## 🚀 Auto Status Calculation

### Logic:
```php
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
```

### Examples:
- Jam masuk: 07:00, Toleransi: 10 menit
  - Absen 07:05 → **HADIR** ✅
  - Absen 07:12 → **TERLAMBAT** ⚠️

## 📍 Location Validation

### Distance Calculation:
Uses Haversine formula to calculate distance between user and school.

```php
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
```

### Validation Rules:
- Distance must be ≤ radius_presensi
- Returns distance in meters
- Throws error if outside radius

## 📸 Photo Upload

### Storage Path:
- Check-in: `storage/app/public/absensi-masuk/`
- Check-out: `storage/app/public/absensi-pulang/`

### Access URL:
- After symlink: `/storage/absensi-masuk/filename.jpg`
- Max size: 2MB per photo
- Format: jpg, jpeg, png

## ⚠️ Error Handling

### Common Errors:
1. **Outside Radius**
   ```json
   {
     "message": "Di luar radius presensi. Jarak: 75m (Max: 50m)"
   }
   ```

2. **Already Checked In**
   ```json
   {
     "message": "Sudah absen hari ini",
     "data": { ... }
   }
   ```

3. **Not Checked In Yet**
   ```json
   {
     "message": "Belum absen masuk hari ini"
   }
   ```

4. **Too Early to Check Out**
   ```json
   {
     "message": "Belum waktunya absen pulang. Jam pulang: 15:00:00"
   }
   ```

## ✅ Advantages of This Design

✅ **Hanya 1 tombol aktif** - Tidak bingung user
✅ **Warna berbeda** - Hijau (masuk), Orange (pulang)
✅ **Server decide** - Frontend cuma follow instruksi server
✅ **Status otomatis** - HADIR/TERLAMBAT dihitung server
✅ **Multi-tenant ready** - Setiap sekolah punya konfigurasi berbeda
✅ **Security** - Foto sebagai verifikasi
✅ **Audit trail** - Foto dan location tercatat

## 📊 Testing Checklist

### Unit Tests:
- [ ] Distance calculation accuracy
- [ ] Status determination logic
- [ ] Radius validation

### Integration Tests:
- [ ] Check-in flow end-to-end
- [ ] Check-out flow end-to-end
- [ ] Photo upload success
- [ ] Error handling

### UI Tests:
- [ ] Button visibility correct
- [ ] Photo capture working
- [ ] Status display accurate
- [ ] Error messages shown

## 📚 Related Documentation
- [ABSEN_FLOW.md](../backend/ABSEN_FLOW.md) - Complete flow documentation
- [2026_06_21_multi_tenant_school_feature.md](./2026_06_21_multi_tenant_school_feature.md) - Multi-tenant implementation
- [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md) - Full implementation plan

---

**Generated:** 2026-06-21
**Status:** IMPLEMENTED
**Type:** IMPROVEMENT - ATTENDANCE FLOW
