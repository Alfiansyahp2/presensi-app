import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// DashboardWelcomeCard - Welcome card untuk dashboard
///
/// Features:
/// - Gradient background
/// - Different styles per role
/// - Theme support
class DashboardWelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String greeting;
  final IconData? icon;
  final bool isDarkMode;
  final List<Color>? gradientColors;

  const DashboardWelcomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.greeting,
    this.icon,
    this.isDarkMode = false,
    this.gradientColors,
  });

  /// Preset gradients untuk berbagai roles
  factory DashboardWelcomeCard.forRole({
    required String role,
    required String userName,
    bool isDarkMode = false,
  }) {
    switch (role) {
      case 'SUPER_ADMIN':
        return DashboardWelcomeCard(
          title: 'Super Admin',
          subtitle: 'Kelola seluruh sistem dan pantau semua sekolah',
          greeting: 'Selamat Datang, Administrator! 👑',
          icon: Icons.admin_panel_settings,
          isDarkMode: isDarkMode,
          gradientColors: isDarkMode
              ? [Colors.deepPurple, Colors.deepPurple.withValues(alpha: 0.7)]
              : [Colors.deepPurple, Colors.purple],
        );

      case 'SCHOOL_ADMIN':
        return DashboardWelcomeCard(
          title: 'Admin Sekolah',
          subtitle: 'Kelola sekolah dan pantau absensi siswa',
          greeting: 'Selamat Datang, Admin! 👋',
          icon: Icons.school,
          isDarkMode: isDarkMode,
          gradientColors: isDarkMode
              ? [
                  AppColors.darkAccent,
                  AppColors.darkAccent.withValues(alpha: 0.7),
                ]
              : [AppColors.formalNavy, AppColors.formalNavyLight],
        );

      case 'TEACHER':
        return DashboardWelcomeCard(
          title: 'Guru',
          subtitle: 'Pantau kehadiran siswa dan kelola kelas',
          greeting: 'Selamat Datang, Guru! 👨‍🏫',
          icon: Icons.person,
          isDarkMode: isDarkMode,
          gradientColors: isDarkMode
              ? [Colors.teal, Colors.teal.withValues(alpha: 0.7)]
              : [Colors.teal, Colors.teal.shade300],
        );

      case 'STUDENT':
      default:
        return DashboardWelcomeCard(
          title: 'Siswa',
          subtitle: 'Selamat belajar dan jangan lupa absen!',
          greeting: 'Selamat Datang! 👋',
          icon: Icons.school,
          isDarkMode: isDarkMode,
          gradientColors: isDarkMode
              ? [
                  AppColors.darkAccent,
                  AppColors.darkAccent.withValues(alpha: 0.7),
                ]
              : [AppColors.formalNavy, AppColors.formalNavyLight],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        (isDarkMode
            ? [
                AppColors.darkAccent,
                AppColors.darkAccent.withValues(alpha: 0.7),
              ]
            : [
                AppColors.formalNavy,
                AppColors.formalNavyLight,
              ]);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
