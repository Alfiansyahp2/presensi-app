import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 🎨 Interactive Input Field dengan Focus Animations & Theme Support
///
/// Features:
/// - Animated focus states
/// - Glowing shadow effects
/// - Color transitions
/// - Light & Dark mode support
/// - Customizable colors & icons
///
/// Usage:
/// ```dart
/// InteractiveInputField(
///   label: 'Email',
///   hintText: 'Masukkan email Anda',
///   prefixIcon: Icons.email,
///   focusColor: AppColors.formalNavy,
///   controller: _emailController,
///   isDarkMode: false,
/// )
/// ```
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class InteractiveInputField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Color focusColor;
  final int maxLines;
  final bool isDarkMode;

  const InteractiveInputField({
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.focusColor = AppColors.formalNavy,
    this.maxLines = 1,
    this.isDarkMode = false,
  });

  @override
  State<InteractiveInputField> createState() => _InteractiveInputFieldState();
}

class _InteractiveInputFieldState extends State<InteractiveInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // Get theme-based colors
    final labelColor = widget.isDarkMode
        ? AppColors.darkTextPrimary
        : Colors.white;
    final inputBackgroundColor = widget.isDarkMode
        ? AppColors.darkSurface.withValues(alpha: _isFocused ? 1.0 : 0.95)
        : Colors.white.withValues(alpha: _isFocused ? 1.0 : 0.95);
    final inputTextColor = widget.isDarkMode
        ? AppColors.darkTextPrimary
        : Colors.black87;
    final hintColor = widget.isDarkMode
        ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
        : Colors.grey.shade400;
    final iconColor = _isFocused
        ? widget.focusColor
        : (widget.isDarkMode
            ? AppColors.darkTextSecondary
            : Colors.grey.shade400);
    final borderColor = _isFocused
        ? widget.focusColor
        : (widget.isDarkMode
            ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
            : Colors.grey.shade300);
    final shadowColor = _isFocused
        ? widget.focusColor.withValues(alpha: 0.3)
        : (widget.isDarkMode
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.1));

    return FocusScope(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Interactive Input Field
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: inputBackgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.focusColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                      ),
                    ],
              border: Border.all(
                color: borderColor,
                width: _isFocused ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              style: TextStyle(
                fontSize: 16,
                color: inputTextColor,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: 16,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: iconColor,
                      )
                    : null,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: widget.onChanged,
              validator: widget.validator,
            ),
          ),
        ],
      ),
    );
  }
}
