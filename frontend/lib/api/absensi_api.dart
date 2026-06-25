import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_absensi/service/API_config.dart';
import 'package:flutter_absensi/models/absensi_model.dart';
import 'package:flutter_absensi/models/attendance_status_model.dart';

class AbsensiApi {
  /// ✅ GET TODAY STATUS - Cek status hari ini
  /// Gunakan ini untuk menentukan tombol mana yang aktif (masuk/pulang)
  static Future<Map<String, dynamic>> getTodayStatus({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/absensi/today'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': AttendanceStatus.fromJson(responseData),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat status',
        };
      }
    } catch (e) {
      debugPrint('Error fetching today status: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  /// ✅ CHECK-IN - Absen masuk dengan foto
  static Future<Map<String, dynamic>> checkIn({
    required String token,
    required double latitude,
    required double longitude,
    required File foto,
    String? alasan,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/absensi/checkin'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      if (alasan != null && alasan.isNotEmpty) {
        request.fields['alasan'] = alasan;
      }

      // Add foto file
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Absen masuk berhasil',
          'data': responseData['data'] != null
              ? AttendanceData.fromJson(responseData['data'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Absen masuk gagal',
        };
      }
    } catch (e) {
      debugPrint('Error during check-in: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  /// ✅ CHECK-OUT - Absen pulang dengan foto
  static Future<Map<String, dynamic>> checkOut({
    required String token,
    required File foto,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/absensi/checkout'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add foto file
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Absen pulang berhasil',
          'data': responseData['data'] != null
              ? AttendanceData.fromJson(responseData['data'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Absen pulang gagal',
        };
      }
    } catch (e) {
      debugPrint('Error during check-out: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  /// 🔰 LEGACY - Untuk backward compatibility dengan frontend lama
  /// Akan di-deprecate setelah frontend semua menggunakan checkIn/checkOut
  static Future<Map<String, dynamic>> submitAbsensi({
    required String token,
    required double latitude,
    required double longitude,
    String status = 'hadir',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/absen'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'status': status,
        }),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Absensi berhasil',
          'data': responseData['data'] != null
              ? AbsensiModel.fromJson(responseData['data'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Absensi gagal',
        };
      }
    } catch (e) {
      debugPrint('Error during absensi: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  static Future<Map<String, dynamic>> getHistory({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        List<dynamic> dataList = responseData['data'] ?? [];
        List<AbsensiModel> historyList =
            dataList.map((e) => AbsensiModel.fromJson(e)).toList();

        return {
          'success': true,
          'data': historyList,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat riwayat',
        };
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  /// 🆕 GET ADMIN ATTENDANCE - Untuk Teacher/School Admin Dashboard
  /// GET /api/absensi/admin
  ///
  /// Mengambil semua data absensi dengan filter (untuk dashboard teacher)
  static Future<Map<String, dynamic>> getAdminAttendance({
    required String token,
    String? date,
    String? status,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        if (date != null) 'date': date,
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/absensi/admin')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengambil data absensi',
        };
      }
    } catch (e) {
      debugPrint('Error fetching admin attendance: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }
}
