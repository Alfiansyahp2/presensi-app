import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 🎨 Premium Elevated Button
///
/// Modern elevated button dengan smooth animations
/// Mendukung berbagai sizes dan states
///
/// Usage:
/// ```dart
/// PremiumButton(
///   text: 'Login',
///   onPressed: () {},
///   type: ButtonType.primary,
///   size: ButtonSize.large,
/// )
/// ```
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? loadingText;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _ElevatedButton(
        text: text,
        onPressed: isEnabled ? onPressed : null,
        type: type,
        size: size,
        isLoading: isLoading,
        icon: icon,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        loadingText: loadingText,
      ),
    );
  }
}

class _ElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? loadingText;

  const _ElevatedButton({
    required this.text,
    required this.onPressed,
    required this.type,
    required this.size,
    required this.isLoading,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getButtonColors();
    final sizes = _getButtonSizes();
    final styles = _getButtonTextStyles();

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.foregroundColor,
        disabledBackgroundColor: colors.disabledBackgroundColor,
        disabledForegroundColor: colors.disabledForegroundColor,
        elevation: colors.elevation,
        shadowColor: colors.shadowColor,
        padding: sizes.padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        textStyle: styles.textStyle,
        minimumSize: Size(sizes.minWidth, sizes.minHeight),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.pressedOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.hoveredOverlay;
          }
          return null;
        }),
      ),
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: sizes.loadingSize,
                  height: sizes.loadingSize,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textOnPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  loadingText ?? 'Loading...',
                  style: styles.textStyle.copyWith(
                    color: colors.foregroundColor,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: AppSpacing.xxs),
                ],
                if (icon != null && leadingIcon == null) ...[
                  Icon(icon, size: sizes.iconSize),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                Text(
                  text,
                  style: styles.textStyle,
                  textAlign: TextAlign.center,
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  trailingIcon!,
                ],
                if (icon != null && trailingIcon == null) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(icon, size: sizes.iconSize),
                ],
              ],
            ),
    );
  }

  _ButtonColors _getButtonColors() {
    switch (type) {
      case ButtonType.primary:
        return _ButtonColors(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.12),
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          pressedOverlay: AppColors.primaryDark.withValues(alpha: 0.12),
          hoveredOverlay: AppColors.primaryLight.withValues(alpha: 0.08),
        );
      case ButtonType.secondary:
        return _ButtonColors(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.12),
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          pressedOverlay: AppColors.secondaryDark.withValues(alpha: 0.12),
          hoveredOverlay: AppColors.secondaryLight.withValues(alpha: 0.08),
        );
      case ButtonType.success:
        return _ButtonColors(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.12),
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          pressedOverlay: AppColors.successDark.withValues(alpha: 0.12),
          hoveredOverlay: AppColors.successLight.withValues(alpha: 0.08),
        );
      case ButtonType.warning:
        return _ButtonColors(
          backgroundColor: AppColors.warning,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.12),
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          pressedOverlay: AppColors.warningDark.withValues(alpha: 0.12),
          hoveredOverlay: AppColors.warningLight.withValues(alpha: 0.08),
        );
      case ButtonType.danger:
        return _ButtonColors(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.12),
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          pressedOverlay: AppColors.errorDark.withValues(alpha: 0.12),
          hoveredOverlay: AppColors.errorLight.withValues(alpha: 0.08),
        );
      case ButtonType.ghost:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          pressedOverlay: AppColors.primary.withValues(alpha: 0.08),
          hoveredOverlay: AppColors.primary.withValues(alpha: 0.05),
        );
      case ButtonType.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          pressedOverlay: AppColors.primary.withValues(alpha: 0.08),
          hoveredOverlay: AppColors.primary.withValues(alpha: 0.05),
        );
    }
  }

  _ButtonSizes _getButtonSizes() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonSizes(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          minWidth: 64,
          minHeight: 36,
          loadingSize: 16,
          iconSize: 16.0,
        );
      case ButtonSize.medium:
        return _ButtonSizes(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minWidth: 80,
          minHeight: 44,
          loadingSize: 20,
          iconSize: 20.0,
        );
      case ButtonSize.large:
        return _ButtonSizes(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minWidth: 96,
          minHeight: 52,
          loadingSize: 24,
          iconSize: 24.0,
        );
    }
  }

  _ButtonTextStyles _getButtonTextStyles() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonTextStyles(
          textStyle: AppTypography.labelMedium,
        );
      case ButtonSize.medium:
        return _ButtonTextStyles(
          textStyle: AppTypography.labelLarge,
        );
      case ButtonSize.large:
        return _ButtonTextStyles(
          textStyle: AppTypography.button,
        );
    }
  }
}

// =============================================
// BUTTON TYPES
// =============================================

enum ButtonType {
  /// Primary button - Main actions
  primary,

  /// Secondary button - Alternative actions
  secondary,

  /// Success button - Positive actions
  success,

  /// Warning button - Cautionary actions
  warning,

  /// Danger button - Destructive actions
  danger,

  /// Ghost button - Minimal emphasis
  ghost,

  /// Outline button - Bordered with no background
  outline,
}

// =============================================
// BUTTON SIZES
// =============================================

enum ButtonSize {
  /// Small button - For compact spaces
  small,

  /// Medium button - Default size
  medium,

  /// Large button - For prominent actions
  large,
}

// =============================================
// INTERNAL CLASSES
// =============================================

class _ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;
  final double elevation;
  final Color shadowColor;
  final Color? pressedOverlay;
  final Color? hoveredOverlay;

  const _ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledBackgroundColor,
    required this.disabledForegroundColor,
    required this.elevation,
    required this.shadowColor,
    this.pressedOverlay,
    this.hoveredOverlay,
  });
}

class _ButtonSizes {
  final EdgeInsetsGeometry padding;
  final double minWidth;
  final double minHeight;
  final double loadingSize;
  final double iconSize;

  const _ButtonSizes({
    required this.padding,
    required this.minWidth,
    required this.minHeight,
    required this.loadingSize,
    required this.iconSize,
  });
}

class _ButtonTextStyles {
  final TextStyle textStyle;

  const _ButtonTextStyles({
    required this.textStyle,
  });
}
