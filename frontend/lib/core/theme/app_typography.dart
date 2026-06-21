import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 📝 Professional School Typography System
///
/// Typography hierarchy untuk aplikasi Presensi Sekolah Premium
/// Menggunakan font: Poppins & Inter
///
/// Hierarchy:
/// - Display (Hero text, splash screens)
/// - Headline (Page titles, section headers)
/// - Title (Card titles, important labels)
/// - Body (Content, descriptions)
/// - Label (Buttons, tags, captions)
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class AppTypography {
  // =============================================
  // FONT FAMILIES
  // =============================================

  /// Primary font family - Poppins
  /// Usage: Headlines, titles, important text
  static const String fontFamilyPrimary = 'Poppins';

  /// Secondary font family - Inter
  /// Usage: Body text, descriptions, UI elements
  static const String fontFamilySecondary = 'Inter';

  /// Monospace font family
  /// Usage: Numbers, codes, timestamps
  static const String fontFamilyMonospace = 'JetBrainsMono';

  // =============================================
  // DISPLAY STYLES - Hero & Splash Screens
  // =============================================

  /// Display Large - Hero text, splash screens
  /// Size: 57sp, Weight: 400, Line Height: 64
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    color: Color(0xFF0F172A),
  );

  /// Display Medium - Large hero text
  /// Size: 45sp, Weight: 400, Line Height: 52
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    color: Color(0xFF0F172A),
  );

  /// Display Small - Medium hero text
  /// Size: 36sp, Weight: 400, Line Height: 44
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: Color(0xFF0F172A),
  );

  // =============================================
  // HEADLINE STYLES - Page Titles & Section Headers
  // =============================================

  /// Headline Large - Page titles
  /// Size: 32sp, Weight: 400, Line Height: 40
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
    color: Color(0xFF0F172A),
  );

  /// Headline Medium - Section headers
  /// Size: 28sp, Weight: 400, Line Height: 36
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
    color: Color(0xFF0F172A),
  );

  /// Headline Small - Card titles, important labels
  /// Size: 24sp, Weight: 400, Line Height: 32
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
    color: Color(0xFF0F172A),
  );

  // =============================================
  // TITLE STYLES - Card Titles & Important Labels
  // =============================================

  /// Title Large - Card titles
  /// Size: 22sp, Weight: 500, Line Height: 28
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
    color: Color(0xFF0F172A),
  );

  /// Title Medium - Section titles, emphasis
  /// Size: 16sp, Weight: 500, Line Height: 24
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
    color: Color(0xFF0F172A),
  );

  /// Title Small - Subsection titles
  /// Size: 14sp, Weight: 500, Line Height: 20
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: Color(0xFF0F172A),
  );

  // =============================================
  // BODY STYLES - Content & Descriptions
  // =============================================

  /// Body Large - Emphasized body text
  /// Size: 16sp, Weight: 400, Line Height: 24
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
    color: Color(0xFF475569),
  );

  /// Body Medium - Standard body text
  /// Size: 14sp, Weight: 400, Line Height: 20
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: Color(0xFF475569),
  );

  /// Body Small - Secondary body text
  /// Size: 12sp, Weight: 400, Line Height: 16
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: Color(0xFF64748B),
  );

  // =============================================
  // LABEL STYLES - Buttons, Tags, Captions
  // =============================================

  /// Label Large - Buttons, tabs
  /// Size: 14sp, Weight: 500, Line Height: 20
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: Color(0xFF0F172A),
  );

  /// Label Medium - Tags, badges
  /// Size: 12sp, Weight: 500, Line Height: 16
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: Color(0xFF0F172A),
  );

  /// Label Small - Captions, helper text
  /// Size: 11sp, Weight: 500, Line Height: 16
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: Color(0xFF64748B),
  );

  // =============================================
  // SPECIALIZED STYLES - Custom Use Cases
  // =============================================

  /// Button text style - Primary buttons
  static const TextStyle button = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.25,
    color: Color(0xFFFFFFFF),
  );

  /// Caption style - Image captions, timestamps
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: Color(0xFF94A3B8),
  );

  /// Overline style - Overhead labels
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.60,
    color: Color(0xFF64748B),
  );

  /// Monospace style - Numbers, codes, timestamps
  static const TextStyle monospace = TextStyle(
    fontFamily: fontFamilyMonospace,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.43,
    color: Color(0xFF0F172A),
  );

  /// Error text style - Error messages
  static const TextStyle error = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: Color(0xFFEF4444),
  );

  /// Success text style - Success messages
  static const TextStyle success = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: Color(0xFF10B981),
  );

  // =============================================
  // THEMED STYLES - With Color Variants
  // =============================================

  /// Title primary - With primary color
  static TextStyle titlePrimary(Color color) => titleLarge.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      );

  /// Body primary - With primary color
  static TextStyle bodyPrimary(Color color) => bodyLarge.copyWith(
        color: color,
      );

  /// Label with custom color
  static TextStyle labelWithColor(Color color) => labelLarge.copyWith(
        color: color,
      );

  // =============================================
  // UTILITY METHODS
  // =============================================

  /// Get text style by size
  static TextStyle bySize(double size, {FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamilySecondary,
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      height: 1.5,
    );
  }

  /// Apply custom color to style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply custom weight to style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return small;
    } else if (width < 900) {
      return medium;
    } else {
      return large;
    }
  }
}
