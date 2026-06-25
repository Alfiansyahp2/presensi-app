import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/theme_provider.dart';

/// ThemeToggleButton - Tombol toggle theme tanpa background
///
/// Fitur:
/// - Icon berubah sesuai mode (sun/moon)
/// - Tanpa background container (transparent)
/// - Position di pojok kiri atas AppBar
/// - Sync global theme via ThemeProvider
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    // Listen ke theme changes
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _themeProvider.isDarkMode;

    return IconButton(
      key: ValueKey('theme_toggle_$isDarkMode'),
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Colors.white,
        size: 20,
      ),
      onPressed: () {
        // Haptic feedback
        HapticFeedback.lightImpact();
        // Toggle theme global - ini akan sync ke semua screen
        _themeProvider.toggleTheme();
      },
      tooltip: isDarkMode
          ? 'Switch to Light Mode'
          : 'Switch to Dark Mode',
      splashRadius: 20, // ✅ Tap feedback, tapi tanpa background container
    );
  }
}
