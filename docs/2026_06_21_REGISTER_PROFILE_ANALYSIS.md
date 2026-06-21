# 📊 ANALISIS: Register & Profile Screen untuk Multi-Tenant

## 🔍 CURRENT STATE (SAAT INI)

### **REGISTER SCREEN**

**Form Fields yang Ada:**
```dart
- Fullname ✅
- NISN ✅
- Kelas ✅
- Email ✅
- Password ✅
- Confirm Password ✅
```

**API Call (line 562-568):**
```dart
await AuthService.register(
  fullname: _fullnameController.text.trim(),
  nisn: _nisnController.text.trim(),
  kelas: _kelasController.text.trim(),
  email: _emailController.text.trim(),
  password: _passwordController.text.trim(),
);
```

**Yang KURANG untuk Multi-Tenant:**
❌ Tidak ada field `school_id` atau `sekolah`
❌ User tidak bisa memilih/terhubung ke sekolah saat daftar

---

### **PROFILE SCREEN**

**Yang Ditampilkan (line 92-130):**
```dart
// GET /api/profile
// Response hanya user data dasar
_userProfile = responseData['data'];
```

**Yang DITAMPILKAN:**
- Fullname, NISN, Kelas, Email (basic info)

**Yang KURANG untuk Multi-Tenant:**
❌ Tidak menampilkan info sekolah
❌ Tidak ada school_id di response
❌ Backend `/api/profile` belum include school relation

---

## 🏗️ BACKEND MULTI-TENANT (SUDAH ADA)

### **Database:**
✅ Table `users` sudah punya `school_id` (FK ke schools)
✅ Table `schools` dengan konfigurasi lengkap

### **Data yang Perlu:**
```sql
SELECT 
  u.id, u.fullname, u.nisn, u.kelas, u.email, u.school_id,
  s.nama_sekolah, s.kode_sekolah, 
  s.jam_masuk, s.jam_pulang, s.radius_presensi
FROM users u
LEFT JOIN schools s ON u.school_id = s.id
WHERE u.id = ?
```

---

## 🎯 OPSI IMPLEMENTASI REGISTER

### **OPSI A: Dropdown Sekolah (RECOMMENDED untuk Multi-School)**
**Use Case:** Ada banyak sekolah, user bisa pilih

**UI:**
```dart
// Dropdown School
DropdownButtonFormField<String>(
  value: _selectedSchoolId,
  items: _schoolItems,
  onChanged: (value) {
    setState(() {
      _selectedSchoolId = value;
    });
  },
  decoration: InputDecoration(
    labelText: 'Pilih Sekolah',
    prefixIcon: Icons.school,
    helperText: 'Pilih sekolah Anda',
  ),
)
```

**Flow:**
1. User buka register screen
2. Fetch list sekolah: `GET /api/schools`
3. Populate dropdown dengan nama sekolah
4. User pilih sekolah
5. Register dengan `school_id`

**Kelebihan:**
- ✅ User bisa pilih sekolah sendiri
- ✅ Transparent - user tahu masuk sekolah mana

**Kekurangan:**
- Perlu fetch sekolah list dulu
- Perlu handle case: list kosong

---

### **OPSI B: Kode Sekolah (Manual Entry)**
**Use Case:** User input kode sekolah, admin verify

**UI:**
```dart
// Kode Sekolah Input
InteractiveInputField(
  label: 'Kode Sekolah',
  hintText: 'Contoh: MA02-SBY',
  prefixIcon: Icons.code,
  controller: _kodeSekolahController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Kode sekolah harus diisi';
    }
    // Validate kode
    return null;
  },
),
```

**Backend Logic:**
```php
// RegisterController.php
$kodeSekolah = $request->kode_sekolah;
$school = School::where('kode_sekolah', $kodeSekolah)->first();

if (!$school) {
    return response()->json([
        'message' => 'Kode sekolah tidak valid',
    ], 400);
}

$user = User::create([
    'fullname' => $request->fullname,
    'school_id' => $school->id,
    // ...
]);
```

**Kelebihan:**
- ✅ Backend validate kode
- ✅ Tidak perlu fetch list

**Kekurangan:**
- User harus tahu kode dulu
- Perlu edukasi cara dapet kode

---

### **OPSI C: Auto-Assign ke Default School (SIMPLEST)**
**Use Case:** Hanya 1 sekolah, atau user di-assign oleh admin

**UI:**
```dart
// Tidak ada field tambahan
// Backend auto-assign ke default school
```

**Backend Logic:**
```php
// RegisterController.php
$defaultSchool = School::first(); // Atau where('status_aktif', true)->first()

$user = User::create([
    'fullname' => $request->fullname,
    'school_id' => $defaultSchool->id,
    'nisn' => $request->nisn,
    'kelas' => $request->kelas,
    'email' => $request->email,
    'password' => bcrypt($request->password),
]);
```

**Kelebihan:**
- ✅ Paling simple
- ✅ User tidak perlu pilih
- ✅ Bisa diubah nanti oleh admin

**Kekurangan:**
- ❌ User tidak tahu masuk sekolah mana
- ❌ Tidak transparan

---

## 🎯 REKOMENDASI

### **Untuk SISTEM SEKARANG (1 Sekolah = MA-2 Surabaya):**

**PAKET OPSI C (Auto-Assign)** karena:
- ✅ Paling simple untuk saat ini
- ✅ Nanti bisa diupgrade ketika ada banyak sekolah
- ✅ Admin bisa edit `school_id` user lewat backend

**Implementasi Cepat:**
```php
// RegisterController.php - line ±35
$user = User::create([
    'fullname' => $request->fullname,
    'nisn' => $request->nisn,
    'kelas' => $request->kelas,
    'email' => $request->email,
    'password' => bcrypt($request->password),
    'school_id' => 1, // ← Hardcoded MA-2 Surabaya dulu
]);
```

---

### **Untuk FUTURE (Multi-School):**

**PAKET OPSI A (Dropdown)** karena:
- ✅ User experience lebih baik
- ✅ Transparan - user pilih sendiri
- ✅ Scalable untuk nambah sekolah baru

---

## 📱 PROFILE SCREEN ANALYSIS

### **Yang DITAMPILKAN SAAT INI:**
```dart
// GET /api/profile
User: {
  fullname, nisn, kelas, email
}
```

### **Yang PERLU DITAMBAHKAN (Multi-Tenant):**

```dart
User {
  fullname, nisn, kelas, email,
  // TAMBAHKAN:
  school: {
    nama_sekolah,
    kode_sekolah,
    jam_masuk,
    jam_pulang,
    radius_presensi,
    alamat
  }
}
```

**UI Design:**
```
┌─────────────────────────────────────┐
│  👤 Profil Siswa                    │
├─────────────────────────────────────┤
│  🏫 MA-2 Surabaya                    │  ← School Info
│  📅 Kelas: 12                        │
│  🕒 Masuk: 07:00  Pulang: 15:00    │  ← Jam Sekolah
│  📏 Radius: 50m                      │
└─────────────────────────────────────┘
```

---

## 🔧 IMPLEMENTATION PLAN

### **PHASE 1: REGISTER (Minimal Multi-Tenant)**

#### **Step 1.1: Update Backend RegisterController**
```php
// app/Http/Controllers/AuthController.php or RegisterController.php
public function register(Request $request)
{
    // ... validation
    
    // Auto-assign ke school pertama (MA-2 Surabaya)
    $defaultSchool = School::first();
    $schoolId = $defaultSchool ? $defaultSchool->id : null;
    
    $user = User::create([
        'fullname' => $request->fullname,
        'nisn' => $request->nisn,
        'kelas' => $request->kelas,
        'email' => $request->email,
        'password' => bcrypt($request->password),
        'school_id' => $schoolId, // ← TAMBAHKAN
    ]);
    
    // ... return response
}
```

#### **Step 1.2: Update UserModel (Frontend)**
```dart
// lib/models/user_model.dart
class UserModel {
  final int? id;
  final String fullname;
  final String nisn;
  final String kelas;
  final String email;
  final String? token;
  
  // TAMBAHKAN untuk multi-tenant
  final int? schoolId;
  final String? namaSekolah; // Untuk display saja
  
  UserModel({
    this.id,
    required this.fullname,
    required this.nisn,
    required this.kelas,
    required this.email,
    this.token,
    this.schoolId,
    this.namaSekolah,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullname: json['fullname'] ?? '',
      nisn: json['nisn'] ?? '',
      kelas: json['kelas'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      schoolId: json['school_id'], // ← TAMBAHKAN
      namaSekolah: json['nama_sekolah'], // ← TAMBAHKAN
    );
  }
}
```

#### **Step 1.3: Frontend Register (Tidak Ada Perubahan)**
Register screen TIDAK perlu perubahan karena:
- ✅ Backend auto-assign school
- ✅ User tidak perlu input sekolah
- ✅ Simpler UX

---

### **PHASE 2: PROFILE SCREEN (Display School Info)**

#### **Step 2.1: Update Backend /api/profile**
```php
// AuthController.php or ProfileController.php
public function profile(Request $request)
{
    $user = auth()->user();
    
    // Load school relation
    $user->load('school');
    
    return response()->json([
        'success' => true,
        'data' => [
            'id' => $user->id,
            'fullname' => $user->fullname,
            'nisn' => $user->nisn,
            'kelas' => $user->kelas,
            'email' => $user->email,
            'school_id' => $user->school_id,
            'nama_sekolah' => $user->school ? $user->school->nama_sekolah : null,
            'kode_sekolah' => $user->school ? $user->school->kode_sekolah : null,
            'jam_masuk' => $user->school ? $user->school->jam_masuk : null,
            'jam_pulang' => $user->school ? $user->school->jam_pulang : null,
            'radius_presensi' => $user->school ? $user->school->radius_presensi : null,
        ],
    ]);
}
```

#### **Step 2.2: Update Frontend UserModel**
```dart
// Sudah di-update di Phase 1.2
```

#### **Step 2.3: Update Frontend Profile Screen**
```dart
// lib/screens/profile_screen.dart

// Di _buildProfileBody(), tambahkan section:
Widget _buildSchoolInfoCard() {
  final schoolName = _userProfile['nama_sekolah'];
  final jamMasuk = _userProfile['jam_masuk'];
  final jamPulang = _userProfile['jam_pulang'];
  
  if (schoolName == null) {
    return SizedBox.shrink(); // Jangan tampilkan jika null
  }
  
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _isDarkMode ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.formalNavy.withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(Icons.school, color: AppColors.formalNavy, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                schoolName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildSchoolChip(Icons.access_time, jamMasuk ?? '-'),
            SizedBox(width: 8),
            _buildSchoolChip(Icons.exit_to_app, jamPulang ?? '-'),
          ],
        ),
      ],
    ),
  );
}
```

---

## 📋 SUMMARY RECOMMENDATIONS

### **REGISTER SCREEN:**
1. **SEKARANG (1 Sekolah)**: Auto-assign di backend
   - Backend tambahkan `school_id` ke create user
   - Frontend TIDAK perlu ubah
   - Simpel & cepat

2. **FUTURE (Multi-School)**: Dropdown sekolah
   - Fetch list sekolah: `GET /api/schools`
   - Dropdown field di register form
   - Validate & kirim school_id

### **PROFILE SCREEN:**
1. **Update backend `/api/profile`**:
   - Load school relation: `$user->load('school')`
   - Return school fields di response

2. **Update UserModel**:
   - Tambah `schoolId`, `namaSekolah`, dll

3. **Update ProfileScreen UI**:
   - Tampilkan card sekolah info
   - Nama sekolah, jam, radius

---

## 🚀 IMPLEMENTATION PRIORITY

| Priority | Task | Complexity |
|-----------|------|------------|
| 🔴 **HIGH** | Backend: Add school_id to register | Low |
| 🔴 **HIGH** | Backend: Update /api/profile with school | Low |
| 🟡 **MEDIUM** | Frontend: Update UserModel | Low |
| 🟡 **MEDIUM** | Frontend: Update ProfileScreen UI | Medium |
| 🟢 **LOW** | Frontend: Add dropdown sekolah (future) | High |

---

## ❓ QUESTIONS FOR YOU

Sebelum implementasi, tolong putuskan:

1. **Untuk sekarang (1 sekolah)**:
   - Mau pakai auto-assign saja di backend?
   - Atau mau ada field "Kode Sekolah"?

2. **Untuk future (multi-sekolah)**:
   - Mau user pilih sekolah pakai dropdown?
   - Atau tetap pakai kode sekolah?

3. **Profile screen**:
   - Perlu menampilkan info sekolah lengkap?
   - Atau cukup basic saja dulu?

---

Generated: 2026-06-21
Status: AWAITING YOUR DECISION
