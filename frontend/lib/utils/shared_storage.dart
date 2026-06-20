import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedStorage {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    return data != null ? json.decode(data) : null;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save last absen date
  static Future<void> saveLastAbsenDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_absen_date', date);
  }

  // Get last absen date
  static Future<String?> getLastAbsenDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_absen_date');
  }

  // Check if already absen today
  static Future<bool> hasAbsenToday() async {
    final lastDate = await getLastAbsenDate();
    if (lastDate == null) return false;

    final lastAbsenDateTime = DateTime.parse(lastDate);
    final now = DateTime.now();

    // Compare year, month, and day (ignore time)
    return lastAbsenDateTime.year == now.year &&
        lastAbsenDateTime.month == now.month &&
        lastAbsenDateTime.day == now.day;
  }
}
