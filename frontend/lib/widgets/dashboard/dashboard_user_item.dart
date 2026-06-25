import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// DashboardUserItem - Reusable user item untuk list
///
/// Features:
/// - Icon dengan background
/// - Label dan count
/// - Customizable color
/// - Theme support
class DashboardUserItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const DashboardUserItem({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    this.isDarkMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
