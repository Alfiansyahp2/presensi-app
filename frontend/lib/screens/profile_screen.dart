import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/shared_storage.dart';
import '../core/widgets/animated_background.dart';
import '../core/theme/app_colors.dart';
import '../providers/theme_provider.dart';
import '../widgets/layouts/dashboard_layout.dart';
import '../widgets/dashboard/dashboard_section_card.dart';
import 'login_screen.dart';

/// 🎨 Profile Screen dengan Bottom Navigation
///
/// Features:
/// - Bottom navigation untuk navigasi balik ke dashboard
/// - Theme support
/// - Profile information
/// - Logout functionality
class ProfileScreen extends StatefulWidget {
  final String? userRole;

  const ProfileScreen({
    super.key,
    this.userRole,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final token = await SharedStorage.getToken();
      if (token == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              _userProfile = responseData['data'];
              _isLoading = false;
            });
          }
          return;
        }
      }
      _handleError('Gagal memuat profil');
    } catch (e) {
      _handleError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar',
          style: TextStyle(
            color: _themeProvider.isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(
            color: _themeProvider.isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        backgroundColor: _themeProvider.isDarkMode
            ? AppColors.darkSurface
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: _themeProvider.isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await SharedStorage.clearAll();
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final role = _userProfile?['role'] ?? 'STUDENT';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _themeProvider.isDarkMode
              ? [
                  AppColors.darkAccent,
                  AppColors.darkAccent.withValues(alpha: 0.7),
                ]
              : [
                  AppColors.formalNavy,
                  AppColors.formalNavyLight,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_themeProvider.isDarkMode
                    ? AppColors.darkAccent
                    : AppColors.formalNavy)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture
            Hero(
              tag: 'profile_picture',
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Name
            Text(
              _userProfile?['fullname'] ?? 'Nama Pengguna',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Role/Class
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                role == 'STUDENT'
                    ? (_userProfile?['kelas'] ?? 'Kelas')
                    : role,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _themeProvider.isDarkMode
            ? AppColors.darkSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (_themeProvider.isDarkMode
                    ? AppColors.darkAccent
                    : AppColors.formalNavy)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: _themeProvider.isDarkMode
                ? AppColors.darkAccent
                : AppColors.formalNavy,
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: _themeProvider.isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: _themeProvider.isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine user role for navigation
    final userRole = widget.userRole ??
                     (_userProfile?['role'] as String? ?? 'STUDENT');

    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
      child: DashboardLayout(
        title: 'Profil Saya',
        userRole: userRole,
        isDarkMode: _themeProvider.isDarkMode,
        actions: [
          // Theme toggle button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _themeProvider.isDarkMode
                  ? AppColors.darkSurface.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: _themeProvider.isDarkMode
                    ? AppColors.darkTextPrimary
                    : Colors.black87,
              ),
              onPressed: () => _themeProvider.toggleTheme(),
              tooltip: _themeProvider.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ),
        ],
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Profile Header with Gradient
                    _buildProfileHeader(),

                    const SizedBox(height: 16),

                    // Info Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                          color: _themeProvider.isDarkMode
                              ? AppColors.darkTextSecondary
                              : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Profile Information Items
                    _buildProfileItem(
                      icon: Icons.badge,
                      label: 'NISN',
                      value: _userProfile?['nisn'] ?? '-',
                    ),
                    if (userRole == 'STUDENT')
                      _buildProfileItem(
                        icon: Icons.school,
                        label: 'Kelas',
                        value: _userProfile?['kelas'] ?? '-',
                      ),
                    _buildProfileItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: _userProfile?['email'] ?? '-',
                    ),
                    _buildProfileItem(
                      icon: Icons.work,
                      label: 'Role',
                      value: _userProfile?['role'] ?? '-',
                    ),
                    _buildProfileItem(
                      icon: Icons.check_circle,
                      label: 'Status',
                      value: _userProfile?['status'] ?? '-',
                    ),

                    const SizedBox(height: 16),

                    // School Info (if available)
                    if (_userProfile?['school'] != null)
                      DashboardSectionCard(
                        isDarkMode: _themeProvider.isDarkMode,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Sekolah',
                              style: TextStyle(
                                color: _themeProvider.isDarkMode
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              icon: Icons.school,
                              label: 'Nama Sekolah',
                              value: _userProfile?['school']?['nama_sekolah'] ?? '-',
                            ),
                            _buildProfileItem(
                              icon: Icons.code,
                              label: 'Kode Sekolah',
                              value: _userProfile?['school']?['kode_sekolah'] ?? '-',
                            ),
                            _buildProfileItem(
                              icon: Icons.location_on,
                              label: 'Alamat',
                              value: _userProfile?['school']?['alamat'] ?? '-',
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showLogoutDialog,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }
}
