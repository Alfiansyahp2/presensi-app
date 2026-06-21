import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 🎨 Modern iOS-Style Custom Button
///
/// Smooth, professional button with iOS design language
/// Not "norak" - uses professional colors and animations
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData? icon;
  final bool isElevated;
  final bool isOutlined;
  final ButtonType? buttonType;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 14,
    this.icon,
    this.isElevated = false,
    this.isOutlined = false,
    this.buttonType,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.buttonType != null) {
      switch (widget.buttonType!) {
        case ButtonType.primary:
          return AppColors.primary;
        case ButtonType.success:
          return AppColors.success;
        case ButtonType.accent:
          return AppColors.accent;
        case ButtonType.error:
          return AppColors.error;
      }
    }
    return widget.backgroundColor ?? AppColors.primary;
  }

  Color _getTextColor() {
    if (widget.isOutlined) {
      return widget.textColor ?? AppColors.primary;
    }
    return widget.textColor ?? AppColors.textLight;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();

    return GestureDetector(
      onTapDown: widget.isLoading || widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = true);
              _scaleController.forward();
            },
      onTapUp: widget.isLoading || widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              _scaleController.reverse();
              widget.onPressed!();
            },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: !widget.isOutlined
                ? LinearGradient(
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: widget.isOutlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: backgroundColor,
              width: widget.isOutlined ? 2 : 0,
            ),
            boxShadow: widget.isElevated && !widget.isOutlined && !_isPressed
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                  ]
                : _isPressed
                    ? [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.isLoading || widget.onPressed == null
                  ? null
                  : () {
                      // Handled by GestureDetector
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: widget.isLoading
                    ? _buildLoadingIndicator(textColor)
                    : _buildButtonContent(textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Color textColor) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: AppTextStyles.buttonLarge.copyWith(
              color: textColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Button type preset untuk consistent styling
enum ButtonType {
  primary,
  success,
  accent,
  error,
}
