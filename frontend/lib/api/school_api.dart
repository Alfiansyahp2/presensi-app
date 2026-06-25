import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/API_config.dart';
import '../models/school_model.dart';

/// SchoolApiService - API calls untuk school data
///
/// Mengambil data sekolah, statistik, dan konfigurasi
class SchoolApiService {
  /// Get all schools (untuk SUPER_ADMIN)
  static Future<Map<String, dynamic>> getAllSchools({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/schools'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'schools': (data['data'] as List)
              .map((school) => SchoolModel.fromJson(school))
              .toList(),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data sekolah',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get school statistics
  static Future<Map<String, dynamic>> getSchoolStatistics({
    required String token,
    required int schoolId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/schools/$schoolId/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil statistik',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get school by ID
  static Future<Map<String, dynamic>> getSchoolById({
    required String token,
    required int schoolId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/schools/$schoolId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'school': SchoolModel.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data sekolah',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get users in a school
  static Future<Map<String, dynamic>> getSchoolUsers({
    required String token,
    required int schoolId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/schools/$schoolId/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'users': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data users',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get attendance in a school
  static Future<Map<String, dynamic>> getSchoolAttendance({
    required String token,
    required int schoolId,
    String? date,
  }) async {
    try {
      final uri = date != null
          ? Uri.parse('${ApiConfig.baseUrl}/schools/$schoolId/attendance?date=$date')
          : Uri.parse('${ApiConfig.baseUrl}/schools/$schoolId/attendance');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'attendance': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data absensi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
