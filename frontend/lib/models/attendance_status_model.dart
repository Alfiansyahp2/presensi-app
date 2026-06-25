/// Model untuk response /api/absensi/today
///
/// Response structure:
/// {
///   "success": true,
///   "data": {
///     "status": "BELUM_ABSEN" | "HADIR" | "TERLAMBAT" | "PULANG",
///     "active_button": "checkin" | "checkout" | "none",
///     "can_checkin": true | false,
///     "can_checkout": true | false,
///     "message": "Silakan absen masuk",
///     "attendance": { ... },
///     "school": {
///       "nama_sekolah": "MA-2 Surabaya",
///       "jam_masuk": "07:00:00",
///       "jam_pulang": "15:00:00",
///       "radius_presensi": 50
///     }
///   }
/// }

class AttendanceStatus {
  final String status;
  final String activeButton;
  final bool canCheckIn;
  final bool canCheckOut;
  final String message;
  final AttendanceData? attendance;
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
    final data = json['data'] ?? {};

    return AttendanceStatus(
      status: data['status']?.toString() ?? 'BELUM_ABSEN',
      activeButton: data['active_button']?.toString() ?? 'none',
      canCheckIn: data['can_checkin'] == true,
      canCheckOut: data['can_checkout'] == true,
      message: data['message']?.toString() ?? '',
      attendance: data['attendance'] != null
          ? AttendanceData.fromJson(data['attendance'])
          : null,
      school: data['school'] != null
          ? SchoolInfo.fromJson(data['school'])
          : null,
    );
  }

  /// Helper untuk cek apakah user sudah absen hari ini
  bool get hasAbsenHariIni => status != 'BELUM_ABSEN';

  /// Helper untuk cek apakah sudah selesai (sudah pulang)
  bool get isSelesai => status == 'PULANG';
}

/// Data absensi jika sudah ada
class AttendanceData {
  final int? id;
  final int? schoolId;
  final int? userId;
  final String? status;
  final String? jamMasuk;
  final String? jamPulang;
  final double? latitude;
  final double? longitude;
  final int? jarakMeter;
  final String? alasan;
  final String? fotoAbsenMasuk;
  final String? fotoAbsenPulang;
  final DateTime? createdAt;

  AttendanceData({
    this.id,
    this.schoolId,
    this.userId,
    this.status,
    this.jamMasuk,
    this.jamPulang,
    this.latitude,
    this.longitude,
    this.jarakMeter,
    this.alasan,
    this.fotoAbsenMasuk,
    this.fotoAbsenPulang,
    this.createdAt,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'] as int?,
      schoolId: json['school_id'] as int?,
      userId: json['user_id'] as int?,
      status: json['status']?.toString(),
      jamMasuk: json['jam_masuk']?.toString(),
      jamPulang: json['jam_pulang']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      jarakMeter: json['jarak_meter'] as int?,
      alasan: json['alasan']?.toString(),
      fotoAbsenMasuk: json['foto_absen_masuk']?.toString(),
      fotoAbsenPulang: json['foto_absen_pulang']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

/// Info sekolah dari backend
class SchoolInfo {
  final String namaSekolah;
  final String jamMasuk;
  final String jamPulang;
  final int radiusPresensi;
  final double latitude;
  final double longitude;

  SchoolInfo({
    required this.namaSekolah,
    required this.jamMasuk,
    required this.jamPulang,
    required this.radiusPresensi,
    required this.latitude,
    required this.longitude,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      namaSekolah: json['nama_sekolah']?.toString() ?? '',
      jamMasuk: json['jam_masuk']?.toString() ?? '07:00:00',
      jamPulang: json['jam_pulang']?.toString() ?? '15:00:00',
      radiusPresensi: json['radius_presensi'] as int? ?? 50,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  /// Helper untuk parse double dengan aman (handle string to double conversion)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper untuk format jam agar lebih readable
  String get formattedJamMasuk => _formatJam(jamMasuk);
  String get formattedJamPulang => _formatJam(jamPulang);

  String _formatJam(String jam) {
    try {
      final parts = jam.split(':');
      // Return jam:menit:detik jika ada 3 parts
      if (parts.length >= 3) {
        return '${parts[0]}:${parts[1]}:${parts[2]}';
      }
      // Fallback: jam:menit jika ada 2 parts
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return jam;
    } catch (e) {
      return jam;
    }
  }
}
