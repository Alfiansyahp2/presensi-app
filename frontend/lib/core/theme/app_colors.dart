import 'package:flutter/material.dart';

/// 🎨 Professional School Color System
///
/// Color palette terinspirasi dari:
/// - Google Classroom
/// - Ruangguru
/// - Samsung One UI
/// - Material Design 3
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class AppColors {
  // =============================================
  // PRIMARY COLORS - Brand Identity (Formal School Colors)
  // =============================================

  /// Primary brand color - Professional Navy Blue
  /// Usage: Main buttons, active states, brand elements
  static const Color primary = Color(0xFF1E40AF); // Navy Blue 800

  /// Primary light variant
  /// Usage: Hover states, subtle highlights
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500

  /// Primary dark variant
  /// Usage: Pressed states, dark mode
  static const Color primaryDark = Color(0xFF1E3A8A); // Blue 900

  /// Primary container for backgrounds
  /// Usage: Container backgrounds, card headers
  static const Color primaryContainer = Color(0xFFDBEAFE); // Blue 100

  // =============================================
  // FORMAL SCHOOL COLORS - Professional & Clean
  // =============================================

  /// Formal navy blue - Primary brand color
  /// Usage: Login background, headers, primary elements
  static const Color formalNavy = Color(0xFF1E40AF);

  /// Formal navy light - Lighter variant
  /// Usage: Gradients, highlights
  static const Color formalNavyLight = Color(0xFF3B82F6);

  /// Formal navy dark - Darker variant
  /// Usage: Dark backgrounds, pressed states
  static const Color formalNavyDark = Color(0xFF1E3A8A);

  /// Formal accent gold - Excellence & achievement
  /// Usage: Accents, highlights, achievements
  static const Color formalGold = Color(0xFFD97706);

  /// Formal accent green - Growth & success
  /// Usage: Success states, growth indicators
  static const Color formalGreen = Color(0xFF059669);

  // =============================================
  // LIGHT MODE COLORS
  // =============================================

  /// Light mode background
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// Light mode surface
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light mode text primary
  static const Color lightTextPrimary = Color(0xFF0F172A);

  /// Light mode text secondary
  static const Color lightTextSecondary = Color(0xFF475569);

  // =============================================
  // DARK MODE COLORS
  // =============================================

  /// Dark mode background
  static const Color darkBackground = Color(0xFF0F172A);

  /// Dark mode surface
  static const Color darkSurface = Color(0xFF1E293B);

  /// Dark mode text primary
  static const Color darkTextPrimary = Color(0xFFF8FAFC);

  /// Dark mode text secondary
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// Dark mode accent
  static const Color darkAccent = Color(0xFF60A5FA);

  // =============================================
  // SECONDARY COLORS - Supporting Elements
  // =============================================

  /// Secondary accent color
  /// Usage: Secondary buttons, highlights
  static const Color secondary = Color(0xFF64748B); // Slate 500

  /// Secondary light variant
  static const Color secondaryLight = Color(0xFF94A3B8); // Slate 400

  /// Secondary dark variant
  static const Color secondaryDark = Color(0xFF475569); // Slate 600

  // =============================================
  // SEMANTIC COLORS - Status & Feedback
  // =============================================

  /// Success color - Completed, present, positive
  /// Usage: Success messages, present status, completed actions
  static const Color success = Color(0xFF10B981); // Emerald 500

  /// Success light variant
  static const Color successLight = Color(0xFF34D399); // Emerald 400

  /// Success dark variant
  static const Color successDark = Color(0xFF059669); // Emerald 600

  /// Success container
  static const Color successContainer = Color(0xFFD1FAE5); // Emerald 100

  /// Warning color - Attention needed
  /// Usage: Warning messages, pending status
  static const Color warning = Color(0xFFF59E0B); // Amber 500

  /// Warning light variant
  static const Color warningLight = Color(0xFFFBBF24); // Amber 400

  /// Warning dark variant
  static const Color warningDark = Color(0xFFD97706); // Amber 600

  /// Warning container
  static const Color warningContainer = Color(0xFFFEF3C7); // Amber 100

  /// Error/Danger color - Failed, absent, critical
  /// Usage: Error messages, absent status, destructive actions
  static const Color error = Color(0xFFEF4444); // Red 500

  /// Error light variant
  static const Color errorLight = Color(0xFFF87171); // Red 400

  /// Error dark variant
  static const Color errorDark = Color(0xFFDC2626); // Red 600

  /// Error container
  static const Color errorContainer = Color(0xFFFEE2E2); // Red 100

  /// Info color - Neutral information
  /// Usage: Info messages, neutral status
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // =============================================
  // NEUTRAL COLORS - Text & Backgrounds
  // =============================================

  /// Background colors - Canvas & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900

  /// Surface colors - Cards, containers
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  /// Surface variant - Elevated surfaces
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceVariantDark = Color(0xFF334155); // Slate 700

  // =============================================
  // TEXT COLORS - Typography Hierarchy
  // =============================================

  /// Text primary - Headlines, important text
  /// Usage: Headlines, titles, important information
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50

  /// Text secondary - Body text, descriptions
  /// Usage: Body text, descriptions, subtitles
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300

  /// Text tertiary - Captions, hints
  /// Usage: Captions, helper text, placeholders
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500

  /// Text disabled - Disabled text
  /// Usage: Disabled text, inactive states
  static const Color textDisabled = Color(0xFFCBD5E1); // Slate 300
  static const Color textDisabledDark = Color(0xFF475569); // Slate 600

  /// Text on primary - For text on primary backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White
  static const Color textOnPrimaryDark = Color(0xFF000000); // Black

  // =============================================
  // BORDER & DIVIDER COLORS
  // =============================================

  /// Border color - Outlines, dividers
  /// Usage: Input borders, card borders, dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFF475569); // Slate 600

  /// Divider color - Subtle dividers
  /// Usage: Separators, subtle borders
  static const Color divider = Color(0xFFF1F5F9); // Slate 100
  static const Color dividerDark = Color(0xFF334155); // Slate 700

  // =============================================
  // SHADOW COLORS
  // =============================================

  /// Shadow color - Drop shadows
  /// Usage: Card shadows, button shadows
  static const Color shadow = Color(0x0F000000); // Black with 6% opacity
  static const Color shadowMedium = Color(0x15000000); // Black with 8% opacity
  static const Color shadowStrong = Color(0x1A000000); // Black with 10% opacity

  // =============================================
  // OVERLAY & SCrim COLORS
  // =============================================

  /// Overlay color - Modal backdrops
  /// Usage: Modal backgrounds, overlays
  static const Color overlay = Color(0x80000000); // Black with 50% opacity

  /// Scrim color - Dialog backdrops
  /// Usage: Dialog backdrops, bottom sheet backdrops
  static const Color scrim = Color(0x60000000); // Black with 38% opacity

  // =============================================
  // SPECIAL PURPOSE COLORS
  // =============================================

  /// Accent highlight - For highlights, badges
  /// Usage: Badges, notifications, highlights
  static const Color accent = Color(0xFF06B6D4); // Cyan 500

  /// Gradient start color
  /// Usage: Primary gradients
  static const Color gradientStart = Color(0xFF2563EB); // Blue 600

  /// Gradient end color
  /// Usage: Primary gradients
  static const Color gradientEnd = Color(0xFF3B82F6); // Blue 500

  /// Attendance status colors
  static const Color attendancePresent = success; // Hadir
  static const Color attendanceLate = warning; // Terlambat
  static const Color attendanceAbsent = error; // Tidak Hadir
  static const Color attendancePermission = info; // Izin
  static const Color attendanceSick = Color(0xFF8B5CF6); // Sakit

  // =============================================
  // SEMANTIC COLOR GETTERS
  // =============================================

  /// Get color based on attendance status
  static Color getAttendanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return attendancePresent;
      case 'terlambat':
        return attendanceLate;
      case 'tidak_hadir':
      case 'absen':
        return attendanceAbsent;
      case 'izin':
        return attendancePermission;
      case 'sakit':
        return attendanceSick;
      default:
        return textSecondary;
    }
  }

  /// Get attendance status container color
  static Color getAttendanceStatusContainerColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return successContainer;
      case 'terlambat':
        return warningContainer;
      case 'tidak_hadir':
      case 'absen':
        return errorContainer;
      case 'izin':
        return primaryContainer;
      case 'sakit':
        return secondary.withValues(alpha: 0.1);
      default:
        return surfaceVariant;
    }
  }

  // =============================================
  // UTILITY METHODS
  // =============================================

  /// Create custom opacity variant
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Lighten a color
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Darken a color
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  // =============================================
  // DEPRECATED - Legacy support (akan dihapus)
  // =============================================

  @Deprecated('Use primary instead')
  static const Color primaryBackground = Color(0xFFEFF6FF);

  @Deprecated('Use surface instead')
  static const Color cardBackground = Color(0xFFFFFFFF);

  @Deprecated('Use textPrimary instead')
  static const Color textLight = Color(0xFFFFFFFF);
}
