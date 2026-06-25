import 'package:flutter/material.dart';
import '../navigation/bottom_nav_handler.dart';
import '../common/app_bar_with_theme_toggle.dart';

/// Dashboard Layout - Reusable layout untuk semua dashboard screens
///
/// Fitur:
/// - AppBar dengan refresh dan notifications
/// - Body dengan scroll support
/// - Bottom navigation yang berfungsi
/// - Theme support (light/dark)
class DashboardLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showRefresh;
  final bool showNotifications;
  final VoidCallback? onRefresh;
  final VoidCallback? onNotification;
  final bool isDarkMode;
  final String userRole;

  const DashboardLayout({
    super.key,
    required this.title,
    required this.body,
    required this.userRole,
    this.actions,
    this.showRefresh = true,
    this.showNotifications = false,
    this.onRefresh,
    this.onNotification,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: BottomNavHandler(
        currentRole: userRole,
        isDarkMode: isDarkMode,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBarWithThemeToggle(
      title: title,
      actions: [
        // Custom actions
        ...?actions,

        // Refresh button
        if (showRefresh)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: onRefresh,
          ),

        // Notifications button
        if (showNotifications)
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: 'Notifications',
            onPressed: onNotification,
          ),
      ],
    );
  }
}
