import 'package:flutter/material.dart';

/// 🎨 Modern iOS-Style Color System
///
/// Professional color palette inspired by iOS design language
/// Clean, smooth, and elegant - not "norak"
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY COLORS - iOS Blue inspired
  // ============================================

  /// Main primary color - Professional blue
  static const Color primary = Color(0xFF007AFF); // iOS System Blue

  /// Primary color with light opacity
  static const Color primaryLight = Color(0xFF5AC8FA);

  /// Primary color with dark opacity
  static const Color primaryDark = Color(0xFF0051D5);

  /// Primary color with very low opacity (for backgrounds)
  static const Color primaryBackground = Color(0x1A007AFF); // 10% opacity

  // ============================================
  // SECONDARY COLORS - iOS Green inspired
  // ============================================

  /// Success color - Soft green
  static const Color success = Color(0xFF34C759); // iOS System Green

  /// Success color with light opacity
  static const Color successLight = Color(0xFF30D158);

  /// Success color with dark opacity
  static const Color successDark = Color(0xFF248A3D);

  // ============================================
  // ACCENT COLORS - Modern accent shades
  // ============================================

  /// Accent color - Professional indigo
  static const Color accent = Color(0xFF5856D6); // iOS System Indigo

  /// Accent color with light opacity
  static const Color accentLight = Color(0xFF7D78F9);

  /// Accent color with dark opacity
  static const Color accentDark = Color(0xFF3A38A0);

  // ============================================
  // NEUTRAL COLORS - iOS Gray inspired
  // ============================================

  /// Background colors
  static const Color background = Color(0xFFFAFAFA); // Almost white
  static const Color backgroundDark = Color(0xFFF5F5F5); // Light gray
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white

  /// Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  /// Text colors - iOS typography colors
  static const Color textPrimary = Color(0xFF000000); // Pure black
  static const Color textSecondary = Color(0xFF8E8E93); // iOS System Gray
  static const Color textTertiary = Color(0xFFC7C7CC); // iOS Light Gray
  static const Color textLight = Color(0xFFFFFFFF); // White text

  /// Border colors
  static const Color border = Color(0xFFE5E5EA); // iOS Separator color
  static const Color borderLight = Color(0xF0E5E5EA); // 94% opacity
  static const Color borderDark = Color(0xFFD1D1D6); // iOS Dark Gray

  // ============================================
  // STATUS COLORS - Professional status colors
  // ============================================

  /// Hadir (Present) - Green
  static const Color statusHadir = Color(0xFF34C759);

  /// Izin (Permission) - Soft orange
  static const Color statusIzin = Color(0xFFFF9500); // iOS System Orange

  /// Sakit (Sick) - Soft red
  static const Color statusSakit = Color(0xFFFF3B30); // iOS System Red

  /// Warning - Yellow
  static const Color warning = Color(0xFFFFCC00); // iOS System Yellow

  /// Error - Red
  static const Color error = Color(0xFFFF3B30);

  /// Info - Blue
  static const Color info = Color(0xFF007AFF);

  // ============================================
  // GRADIENT COLORS - Smooth gradient combinations
  // ============================================

  /// Primary gradient - Blue to indigo
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient - Green shades
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient - Indigo to purple
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // SHADOW COLORS - Soft elevation shadows
  // ============================================

  /// Soft shadow for cards and buttons
  static const Color shadowColor = Color(0x1A000000); // 10% black

  /// Medium shadow
  static const Color shadowMedium = Color(0x33000000); // 20% black

  /// Dark shadow
  static const Color shadowDark = Color(0x4D000000); // 30% black

  // ============================================
  // OVERLAY COLORS - Modal and dialog overlays
  // ============================================

  /// Scrim overlay - For modals and dialogs
  static const Color scrim = Color(0x80000000); // 50% black

  /// Light overlay
  static const Color overlayLight = Color(0x40000000); // 25% black

  /// Dark overlay
  static const Color overlayDark = Color(0xB2000000); // 70% black

  // ============================================
  // SPECIAL COLORS - Attendance status colors
  // ============================================

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return statusHadir;
      case 'izin':
        return statusIzin;
      case 'sakit':
        return statusSakit;
      default:
        return textSecondary;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      default:
        return status;
    }
  }
}

/// ============================================
/// TEXT STYLES - iOS Typography System
/// ============================================
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // HEADLINES - Large, bold text
  // ============================================

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // ============================================
  // TITLE STYLES - Section headers
  // ============================================

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  // ============================================
  // BODY STYLES - Regular text
  // ============================================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  // ============================================
  // LABEL STYLES - Form labels and captions
  // ============================================

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.5,
  );

  // ============================================
  // BUTTON STYLES - CTA buttons
  // ============================================

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );
}

/// ============================================
/// BOX DECORATIONS - Modern container styles
/// ============================================
class AppDecorations {
  AppDecorations._();

  /// Card decoration - Elevated with soft shadow
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Input decoration - Modern text field style
  static InputDecoration inputDecoration({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.textSecondary,
                size: 20,
              )
            : null,
        suffixIcon: suffixIcon,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      );

  /// Status badge decoration - For attendance status
  static BoxDecoration statusBadgeDecoration(Color color) => BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: 1,
        ),
      );
}
