import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// DashboardSectionCard - Container untuk dashboard sections
///
/// Features:
/// - Consistent styling
/// - Theme support
/// - Rounded corners with shadow
class DashboardSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool isDarkMode;

  const DashboardSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
