import 'dart:math';

/// School Model untuk Multi-Tenant System
///
/// Model ini merepresentasikan data sekolah dari backend
/// Digunakan di seluruh aplikasi untuk school-specific settings
class SchoolModel {
  final int id;
  final String namaSekolah;
  final String kodeSekolah;
  final String alamat;
  final double latitude;
  final double longitude;
  final int radiusPresensi;
  final String jamMasuk;
  final String jamPulang;
  final int toleransiTerlambat;
  final bool statusAktif;

  SchoolModel({
    required this.id,
    required this.namaSekolah,
    required this.kodeSekolah,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.radiusPresensi,
    required this.jamMasuk,
    required this.jamPulang,
    required this.toleransiTerlambat,
    required this.statusAktif,
  });

  /// Parse dari JSON response API
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? 0,
      namaSekolah: json['nama_sekolah'] ?? '',
      kodeSekolah: json['kode_sekolah'] ?? '',
      alamat: json['alamat'] ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      radiusPresensi: json['radius_presensi'] ?? 100,
      jamMasuk: json['jam_masuk'] ?? '07:00:00',
      jamPulang: json['jam_pulang'] ?? '16:00:00',
      toleransiTerlambat: json['toleransi_terlambat'] ?? 15,
      statusAktif: json['status_aktif'] ?? true,
    );
  }

  /// Helper untuk parse double dengan aman
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convert ke JSON (untuk request body jika perlu)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_sekolah': namaSekolah,
      'kode_sekolah': kodeSekolah,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'radius_presensi': radiusPresensi,
      'jam_masuk': jamMasuk,
      'jam_pulang': jamPulang,
      'toleransi_terlambat': toleransiTerlambat,
      'status_aktif': statusAktif,
    };
  }

  /// Format jam masuk untuk display (HH:MM)
  String get formattedJamMasuk {
    final parts = jamMasuk.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return jamMasuk;
  }

  /// Format jam pulang untuk display (HH:MM)
  String get formattedJamPulang {
    final parts = jamPulang.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return jamPulang;
  }

  /// Cek apakah sekolah aktif
  bool isActive() {
    return statusAktif;
  }

  /// Hitung jarak dari user location ke sekolah (dalam meter)
  /// Menggunakan Haversine formula
  double calculateDistance(double userLat, double userLong) {
    const earthRadius = 6371000; // Earth's radius in meters

    final dLat = _degToRad(latitude - userLat);
    final dLong = _degToRad(longitude - userLong);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degToRad(userLat)) *
            cos(_degToRad(latitude)) *
            sin(dLong / 2) *
            sin(dLong / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Cek apakah user dalam radius presensi
  bool isWithinRadius(double userLat, double userLong, {int? distanceInMeters}) {
    if (distanceInMeters != null) {
      return distanceInMeters <= radiusPresensi;
    }
    return calculateDistance(userLat, userLong) <= radiusPresensi;
  }

  /// Helper: Convert degree to radian
  double _degToRad(double degree) {
    return degree * pi / 180;
  }

  @override
  String toString() {
    return 'SchoolModel(id: $id, nama: $namaSekolah, kode: $kodeSekolah)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SchoolModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

