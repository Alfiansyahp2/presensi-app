import 'dart:convert';
import 'package:flutter_absensi/service/API_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String fullname,
    required String nisn,
    required String kelas,
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/register');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fullname': fullname,
          'nisn': nisn,
          'kelas': kelas,
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
          'token': responseData['token'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registrasi gagal',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // API sekarang mengembalikan: { token, data: { user: {...} } }
        if (responseData['token'] == null ||
            responseData['data'] == null ||
            responseData['data']['user'] == null) {
          debugPrint('Missing required fields in response');
          debugPrint('Response: $responseData');
          return {
            'success': false,
            'message': 'Format response tidak valid',
            'errors': {'server': 'Data tidak lengkap dari server'}
          };
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login berhasil',
          'token': responseData['token'],
          'user': responseData['data']['user'], // Ambil user object dari data
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }
}
