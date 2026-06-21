# Flutter Implementation Guide: 2 Tombol Absensi

## 🎯 FLOW ABSENSI

Backend sekarang support 2 tombol terpisah:
- **Tombol ABSEN MASUK** - hanya muncul jika belum absen hari ini
- **Tombol ABSEN PULANG** - hanya muncul setelah absen masuk

---

## 📡 API ENDPOINTS

### 1. Cek Status Hari Ini (Untuk Tentukan Tombol Aktif)
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
    "attendance": { ... },
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

### 3. Absen Pulang
```http
POST /api/absensi/checkout
Authorization: Bearer {token}
Content-Type: multipart/form-data

foto: [file image]
```

---

## 📱 FLUTTER IMPLEMENTATION

### Model Response

```dart
// models/attendance_status.dart
class AttendanceStatus {
  final String status;
  final String activeButton;
  final bool canCheckIn;
  final bool canCheckOut;
  final String message;
  final Attendance? attendance;
  final SchoolInfo? school;

  AttendanceStatus({
    required this.status,
    required this.activeButton,
    required this.canCheckIn,
    required this.canCheckOut,
    required this.message,
    this.attendance,
    this.school,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      status: json['status'] ?? 'BELUM_ABSEN',
      activeButton: json['active_button'] ?? 'none',
      canCheckIn: json['can_checkin'] ?? false,
      canCheckOut: json['can_checkout'] ?? false,
      message: json['message'] ?? '',
      attendance: json['attendance'] != null
          ? Attendance.fromJson(json['attendance'])
          : null,
      school: json['school'] != null
          ? SchoolInfo.fromJson(json['school'])
          : null,
    );
  }
}

class SchoolInfo {
  final String namaSekolah;
  final String jamMasuk;
  final String jamPulang;
  final int radiusPresensi;

  SchoolInfo({
    required this.namaSekolah,
    required this.jamMasuk,
    required this.jamPulang,
    required this.radiusPresensi,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      namaSekolah: json['nama_sekolah'] ?? '',
      jamMasuk: json['jam_masuk'] ?? '',
      jamPulang: json['jam_pulang'] ?? '',
      radiusPresensi: json['radius_presensi'] ?? 50,
    );
  }
}
```

### API Service

```dart
// services/attendance_service.dart
class AttendanceService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Untuk emulator
  final String token;

  AttendanceService({required this.token});

  Future<AttendanceStatus> getTodayStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/absensi/today'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AttendanceStatus.fromJson(data['data']);
    } else {
      throw Exception('Failed to load status');
    }
  }

  Future<void> checkIn({
    required double latitude,
    required double longitude,
    required File foto,
    String? alasan,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/absensi/checkin'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    if (alasan != null) {
      request.fields['alasan'] = alasan;
    }
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to check in');
    }
  }

  Future<void> checkOut({required File foto}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/absensi/checkout'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to check out');
    }
  }
}
```

### UI Screen dengan 2 Tombol

```dart
// screens/attendance_screen.dart
class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late AttendanceService _attendanceService;
  AttendanceStatus? _status;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Ambil token dari storage (shared_preferences/secure_storage)
    final token = 'your_token_here';
    _attendanceService = AttendanceService(token: token);
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    setState(() => _loading = true);
    try {
      final status = await _attendanceService.getTodayStatus();
      setState(() {
        _status = status;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleCheckIn() async {
    // Ambil lokasi current
    final position = await _getCurrentLocation();

    // Pilih foto dari camera
    final image = await _pickImage();

    try {
      await _attendanceService.checkIn(
        latitude: position.latitude,
        longitude: position.longitude,
        foto: image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absen masuk berhasil!')),
      );

      // Refresh status
      _refreshStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal absen: $e')),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    // Pilih foto dari camera
    final image = await _pickImage();

    try {
      await _attendanceService.checkOut(foto: image);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absen pulang berhasil!')),
      );

      // Refresh status
      _refreshStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal absen pulang: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _status == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Sekolah
            if (_status!.school != null) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _status!.school!.namaSekolah,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Jam Masuk: ${_status!.school!.jamMasuk}'),
                      Text('Jam Pulang: ${_status!.school!.jamPulang}'),
                      Text('Radius: ${_status!.school!.radiusPresensi} meter'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            // Status Hari Ini
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(_status!.message),
                    if (_status!.attendance != null) ...[
                      SizedBox(height: 8),
                      Text('Jam Masuk: ${_status!.attendance!.jamMasuk}'),
                      if (_status!.attendance!.jamPulang != null)
                        Text('Jam Pulang: ${_status!.attendance!.jamPulang}'),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // 2 TOMBOL - HANYA SATU YANG AKTIF
            if (_status!.canCheckIn)
              ElevatedButton.icon(
                onPressed: _handleCheckIn,
                icon: Icon(Icons.login),
                label: Text('ABSEN MASUK'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),

            if (_status!.canCheckOut)
              ElevatedButton.icon(
                onPressed: _handleCheckOut,
                icon: Icon(Icons.logout),
                label: Text('ABSEN PULANG'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                ),
              ),

            if (!_status!.canCheckIn && !_status!.canCheckOut)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Tidak ada absen yang perlu dilakukan',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    // Implementasi get location
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<File> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile == null) {
      throw Exception('No image selected');
    }

    return File(pickedFile.path);
  }
}
```

---

## 🎯 FLOW LOGIC

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

---

## ✅ KEUNGGULAN DESAIN INI

✅ **Hanya 1 tombol aktif** - Tidak bingung user
✅ **Warna berbeda** - Hijau (masuk), Orange (pulang)
✅ **Server decide** - Frontend cuma follow instruksi server
✅ **Status otomatis** - HADIR/TERLAMBAT dihitung server
✅ **Multi-tenant ready** - Setiap sekolah punya konfigurasi berbeda

---

Generated: 2026-06-21
