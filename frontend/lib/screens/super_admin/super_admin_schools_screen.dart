import 'package:flutter/material.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layouts/dashboard_layout.dart';
import '../../providers/theme_provider.dart';

/// Super Admin - Schools Management Screen
///
/// Placeholder screen untuk manajemen sekolah
class SuperAdminSchoolsScreen extends StatefulWidget {
  const SuperAdminSchoolsScreen({super.key});

  @override
  State<SuperAdminSchoolsScreen> createState() =>
      _SuperAdminSchoolsScreenState();
}

class _SuperAdminSchoolsScreenState extends State<SuperAdminSchoolsScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
      child: DashboardLayout(
        title: 'Manajemen Sekolah',
        userRole: 'SUPER_ADMIN',
        isDarkMode: _themeProvider.isDarkMode,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              Text(
                'Manajemen Sekolah',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fitur manajemen sekolah akan segera tersedia',
                style: TextStyle(
                  fontSize: 16,
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '🚧 Under Development',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
