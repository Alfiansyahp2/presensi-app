import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_absensi/service/API_config.dart';
import 'package:flutter_absensi/models/absensi_model.dart';

class AbsensiApi {
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
}
