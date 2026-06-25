import 'package:flutter/material.dart';
import '../utils/shared_storage.dart';

/// ThemeProvider - Global theme state management
///
/// Fitur:
/// - Sync theme mode di semua screen
/// - Persist ke shared preferences
/// - Notify listeners saat theme berubah
class ThemeProvider with ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();

  factory ThemeProvider() => _instance;

  ThemeProvider._internal() {
    _loadThemePreference();
  }

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  /// Load theme preference dari storage
  Future<void> _loadThemePreference() async {
    try {
      final isDarkMode = await SharedStorage.getThemeMode();
      _isDarkMode = isDarkMode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// Toggle theme mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    // Save ke storage
    SharedStorage.saveThemeMode(_isDarkMode);
  }

  /// Set theme mode secara manual
  void setTheme(bool isDarkMode) {
    if (_isDarkMode != isDarkMode) {
      _isDarkMode = isDarkMode;
      notifyListeners();

      // Save ke storage
      SharedStorage.saveThemeMode(_isDarkMode);
    }
  }
}
