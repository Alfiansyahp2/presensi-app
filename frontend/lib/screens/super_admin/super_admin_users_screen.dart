import 'package:flutter/material.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layouts/dashboard_layout.dart';
import '../../providers/theme_provider.dart';

/// Super Admin - Global Users Management Screen
///
/// Placeholder screen untuk manajemen users global
class SuperAdminUsersScreen extends StatefulWidget {
  const SuperAdminUsersScreen({super.key});

  @override
  State<SuperAdminUsersScreen> createState() =>
      _SuperAdminUsersScreenState();
}

class _SuperAdminUsersScreenState extends State<SuperAdminUsersScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
      child: DashboardLayout(
        title: 'Manajemen Users',
        userRole: 'SUPER_ADMIN',
        isDarkMode: _themeProvider.isDarkMode,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              Text(
                'Manajemen Users Global',
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
                'Fitur manajemen users akan segera tersedia',
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
