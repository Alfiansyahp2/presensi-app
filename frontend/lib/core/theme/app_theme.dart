import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_text_theme.dart';
import 'app_spacing.dart';

/// 🎨 Complete Theme Configuration
///
/// Material Design 3 theme data dengan custom design system
/// Mendukung light & dark mode
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class AppTheme {
  // =============================================
  // LIGHT THEME
  // =============================================

  static ThemeData get lightTheme {
    return ThemeData(
      // Material Design 3
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: _lightColorScheme,

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: _lightAppBarTheme,

      // Card
      cardTheme: _lightCardTheme,

      // Elevated Button
      elevatedButtonTheme: _lightElevatedButtonTheme,

      // Text Button
      textButtonTheme: _lightTextButtonTheme,

      // Outlined Button
      outlinedButtonTheme: _lightOutlinedButtonTheme,

      // Input Decoration
      inputDecorationTheme: _lightInputDecorationTheme,

      // Text Theme
      textTheme: AppTextTheme.lightTheme,

      // Icon Theme
      iconTheme: _lightIconTheme,

      // Divider
      dividerTheme: _lightDividerTheme,

      // Floating Action Button
      floatingActionButtonTheme: _lightFabTheme,

      // Bottom Navigation Bar
      bottomNavigationBarTheme: _lightBottomNavTheme,

      // Chip
      chipTheme: _lightChipTheme,

      // Dialog
      dialogTheme: _lightDialogTheme,

      // Snackbar
      snackBarTheme: _lightSnackBarTheme,

      // Bottom Sheet
      bottomSheetTheme: _lightBottomSheetTheme,

      // Navigation Rail
      navigationRailTheme: _lightNavigationRailTheme,

      // Tab
      tabBarTheme: _lightTabBarTheme,

      // List Tile
      listTileTheme: _lightListTileTheme,

      // Switch
      switchTheme: _lightSwitchTheme,

      // Checkbox
      checkboxTheme: _lightCheckboxTheme,

      // Radio
      radioTheme: _lightRadioTheme,

      // Slider
      sliderTheme: _lightSliderTheme,

      // Progress Indicator
      progressIndicatorTheme: _lightProgressIndicatorTheme,
    );
  }

  // =============================================
  // DARK THEME
  // =============================================

  static ThemeData get darkTheme {
    return ThemeData(
      // Material Design 3
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: _darkColorScheme,

      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar
      appBarTheme: _darkAppBarTheme,

      // Card
      cardTheme: _darkCardTheme,

      // Elevated Button
      elevatedButtonTheme: _darkElevatedButtonTheme,

      // Text Button
      textButtonTheme: _darkTextButtonTheme,

      // Outlined Button
      outlinedButtonTheme: _darkOutlinedButtonTheme,

      // Input Decoration
      inputDecorationTheme: _darkInputDecorationTheme,

      // Text Theme
      textTheme: AppTextTheme.darkTheme,

      // Icon Theme
      iconTheme: _darkIconTheme,

      // Divider
      dividerTheme: _darkDividerTheme,

      // Floating Action Button
      floatingActionButtonTheme: _darkFabTheme,

      // Bottom Navigation Bar
      bottomNavigationBarTheme: _darkBottomNavTheme,

      // Chip
      chipTheme: _darkChipTheme,

      // Dialog
      dialogTheme: _darkDialogTheme,

      // Snackbar
      snackBarTheme: _darkSnackBarTheme,

      // Bottom Sheet
      bottomSheetTheme: _darkBottomSheetTheme,

      // Navigation Rail
      navigationRailTheme: _darkNavigationRailTheme,

      // Tab
      tabBarTheme: _darkTabBarTheme,

      // List Tile
      listTileTheme: _darkListTileTheme,

      // Switch
      switchTheme: _darkSwitchTheme,

      // Checkbox
      checkboxTheme: _darkCheckboxTheme,

      // Radio
      radioTheme: _darkRadioTheme,

      // Slider
      sliderTheme: _darkSliderTheme,

      // Progress Indicator
      progressIndicatorTheme: _darkProgressIndicatorTheme,
    );
  }

  // =============================================
  // LIGHT COLOR SCHEME
  // =============================================

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.primaryContainer,
    onSecondaryContainer: AppColors.secondary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textOnPrimary,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.error,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    shadow: AppColors.shadow,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.primaryLight,
  );

  // =============================================
  // DARK COLOR SCHEME
  // =============================================

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.textOnPrimaryDark,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.textOnPrimaryDark,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textOnPrimaryDark,
    error: AppColors.errorLight,
    onError: AppColors.textOnPrimaryDark,
    errorContainer: AppColors.errorDark,
    onErrorContainer: AppColors.errorLight,
    background: AppColors.backgroundDark,
    onBackground: AppColors.textPrimaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderDark,
    shadow: AppColors.shadow,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.textPrimaryDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary: AppColors.primary,
  );

  // =============================================
  // LIGHT SUB-THEMES
  // =============================================

  static AppBarTheme get _lightAppBarTheme => AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColors.surface,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );

  static CardThemeData get _lightCardTheme => CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        color: AppColors.surface,
        margin: AppSpacing.cardMargin,
        clipBehavior: Clip.antiAlias,
      );

  static ElevatedButtonThemeData get _lightElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          textStyle: AppTypography.button,
        ),
      );

  static TextButtonThemeData get _lightTextButtonTheme =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          textStyle: AppTypography.button,
        ),
      );

  static OutlinedButtonThemeData get _lightOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          textStyle: AppTypography.button,
        ),
      );

  static InputDecorationTheme get _lightInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        errorStyle: AppTypography.error.copyWith(
          color: AppColors.error,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );

  static IconThemeData get _lightIconTheme => const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      );

  static DividerThemeData get _lightDividerTheme => const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      );

  static FloatingActionButtonThemeData get _lightFabTheme =>
      FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        iconSize: 24,
      );

  static BottomNavigationBarThemeData get _lightBottomNavTheme =>
      BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiary,
        ),
        type: BottomNavigationBarType.fixed,
      );

  static ChipThemeData get _lightChipTheme => ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        deleteIconColor: AppColors.textSecondary,
        disabledColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryContainer,
        secondarySelectedColor: AppColors.primaryContainer,
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
      );

  static DialogThemeData get _lightDialogTheme => DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );

  static SnackBarThemeData get _lightSnackBarTheme => SnackBarThemeData(
        elevation: 4,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      );

  static BottomSheetThemeData get _lightBottomSheetTheme =>
      BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
      );

  static NavigationRailThemeData get _lightNavigationRailTheme =>
      NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        elevation: 2,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.textTertiary),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      );

  static TabBarThemeData get _lightTabBarTheme => TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      );

  static ListTileThemeData get _lightListTileTheme => ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        tileColor: AppColors.surface,
        selectedColor: AppColors.primaryContainer,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      );

  static SwitchThemeData get _lightSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiary;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.border;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer;
          }
          return AppColors.surfaceVariant;
        }),
      );

  static CheckboxThemeData get _lightCheckboxTheme => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiary;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surface;
        }),
      );

  static RadioThemeData get _lightRadioTheme => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiary;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surface;
        }),
      );

  static SliderThemeData get _lightSliderTheme => SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceVariant,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
      );

  static ProgressIndicatorThemeData get _lightProgressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant,
      );

  // =============================================
  // DARK SUB-THEMES
  // =============================================

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: 24,
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: AppColors.surfaceDark,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );

  static CardThemeData get _darkCardTheme => CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        color: AppColors.surfaceDark,
        margin: AppSpacing.cardMargin,
        clipBehavior: Clip.antiAlias,
      );

  static ElevatedButtonThemeData get _darkElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimaryDark,
          elevation: 2,
          shadowColor: AppColors.shadow,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          textStyle: AppTypography.button,
        ),
      );

  static TextButtonThemeData get _darkTextButtonTheme =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          textStyle: AppTypography.button,
        ),
      );

  static OutlinedButtonThemeData get _darkOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          textStyle: AppTypography.button,
        ),
      );

  static InputDecorationTheme get _darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        errorStyle: AppTypography.error.copyWith(
          color: AppColors.errorLight,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      );

  static IconThemeData get _darkIconTheme => const IconThemeData(
        color: AppColors.textSecondaryDark,
        size: 24,
      );

  static DividerThemeData get _darkDividerTheme => const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      );

  static FloatingActionButtonThemeData get _darkFabTheme =>
      FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimaryDark,
        iconSize: 24,
      );

  static BottomNavigationBarThemeData get _darkBottomNavTheme =>
      BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textTertiaryDark,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        type: BottomNavigationBarType.fixed,
      );

  static ChipThemeData get _darkChipTheme => ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        deleteIconColor: AppColors.textSecondaryDark,
        disabledColor: AppColors.surfaceVariantDark,
        selectedColor: AppColors.primaryDark,
        secondarySelectedColor: AppColors.primaryDark,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
      );

  static DialogThemeData get _darkDialogTheme => DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      );

  static SnackBarThemeData get _darkSnackBarTheme => SnackBarThemeData(
        elevation: 4,
        backgroundColor: AppColors.textPrimaryDark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.surfaceDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      );

  static BottomSheetThemeData get _darkBottomSheetTheme =>
      BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
      );

  static NavigationRailThemeData get _darkNavigationRailTheme =>
      NavigationRailThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 2,
        selectedIconTheme: const IconThemeData(color: AppColors.primaryLight),
        unselectedIconTheme: const IconThemeData(color: AppColors.textTertiaryDark),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.primaryLight,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiaryDark,
        ),
      );

  static TabBarThemeData get _darkTabBarTheme => TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.textTertiaryDark,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
      );

  static ListTileThemeData get _darkListTileTheme => ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        tileColor: AppColors.surfaceDark,
        selectedColor: AppColors.primaryDark,
        iconColor: AppColors.textSecondaryDark,
        textColor: AppColors.textPrimaryDark,
      );

  static SwitchThemeData get _darkSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiaryDark;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.borderDark;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.surfaceVariantDark;
        }),
      );

  static CheckboxThemeData get _darkCheckboxTheme => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiaryDark;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceDark;
        }),
      );

  static RadioThemeData get _darkRadioTheme => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textTertiaryDark;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceDark;
        }),
      );

  static SliderThemeData get _darkSliderTheme => SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.surfaceVariantDark,
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.12),
      );

  static ProgressIndicatorThemeData get _darkProgressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.surfaceVariantDark,
      );

  // =============================================
  // UTILITIES
  // =============================================

  /// Get theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get current theme
  static ThemeData getCurrentTheme(BuildContext context) {
    return Theme.of(context);
  }

  /// Toggle theme
  static ThemeData toggleTheme(BuildContext context) {
    return isDarkMode(context) ? lightTheme : darkTheme;
  }
}
