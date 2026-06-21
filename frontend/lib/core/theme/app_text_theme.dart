import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// 🎨 Text Theme Configuration
///
/// Mengintegrasikan typography dengan color system
/// Membuat text theme yang konsisten untuk dark & light mode
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class AppTextTheme {
  // =============================================
  // LIGHT THEME
  // =============================================

  static TextTheme get lightTheme {
    return TextTheme(
      // Display styles
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      displaySmall: AppTypography.displaySmall.copyWith(
        color: AppColors.textPrimary,
      ),

      // Headline styles
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.textPrimary,
      ),

      // Title styles
      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.textPrimary,
      ),

      // Body styles
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: AppColors.textSecondary,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.textTertiary,
      ),

      // Label styles
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }

  // =============================================
  // DARK THEME
  // =============================================

  static TextTheme get darkTheme {
    return TextTheme(
      // Display styles
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: AppTypography.displaySmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),

      // Headline styles
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),

      // Title styles
      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.textSecondaryDark,
      ),

      // Body styles
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.textTertiaryDark,
      ),

      // Label styles
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.textTertiaryDark,
      ),
    );
  }

  // =============================================
  // SPECIALIZED THEMES
  // =============================================

  /// Theme for error messages
  static TextStyle get errorLight => AppTypography.error.copyWith(
        color: AppColors.error,
      );

  static TextStyle get errorDark => AppTypography.error.copyWith(
        color: AppColors.errorLight,
      );

  /// Theme for success messages
  static TextStyle get successLight => AppTypography.success.copyWith(
        color: AppColors.success,
      );

  static TextStyle get successDark => AppTypography.success.copyWith(
        color: AppColors.successLight,
      );

  /// Theme for buttons
  static TextStyle get buttonLight => AppTypography.button.copyWith(
        color: AppColors.textOnPrimary,
      );

  static TextStyle get buttonDark => AppTypography.button.copyWith(
        color: AppColors.textOnPrimaryDark,
      );

  /// Theme for captions
  static TextStyle get captionLight => AppTypography.caption.copyWith(
        color: AppColors.textTertiary,
      );

  static TextStyle get captionDark => AppTypography.caption.copyWith(
        color: AppColors.textTertiaryDark,
      );

  // =============================================
  // UTILITY METHODS
  // =============================================

  /// Get themed style based on brightness
  static TextStyle getThemedStyle(
    TextStyle baseStyle,
    Brightness brightness, {
    Color? customColor,
  }) {
    return baseStyle.copyWith(
      color: customColor ??
          (brightness == Brightness.dark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimary),
    );
  }

  /// Create custom text style with color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Create custom text style with weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Create custom text style with size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
