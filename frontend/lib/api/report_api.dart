import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/API_config.dart';

/// ReportApiService - API calls untuk laporan dan statistik
///
/// Mengambil data laporan absensi, summary, dan statistik sistem
class ReportApiService {
  /// Get attendance report
  static Future<Map<String, dynamic>> getAttendanceReport({
    required String token,
    required String startDate,
    required String endDate,
    int? schoolId,
    String? status,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'start_date': startDate,
        'end_date': endDate,
        if (schoolId != null) 'school_id': schoolId.toString(),
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/reports/attendance')
          .replace(queryParameters: queryParams);

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
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil laporan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get summary report (untuk dashboard)
  static Future<Map<String, dynamic>> getSummary({
    required String token,
    int? schoolId,
    int? month,
    int? year,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        if (schoolId != null) 'school_id': schoolId.toString(),
        if (month != null) 'month': month.toString(),
        if (year != null) 'year': year.toString(),
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/reports/summary')
          .replace(queryParameters: queryParams);

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
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil summary',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get today's attendance summary (untuk dashboard cards)
  static Future<Map<String, dynamic>> getTodaySummary({
    required String token,
  }) async {
    try {
      // Gunakan summary API dengan tanggal hari ini
      final now = DateTime.now();
      final result = await getSummary(
        token: token,
        month: now.month,
        year: now.year,
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
