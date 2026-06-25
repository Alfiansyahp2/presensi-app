import 'package:flutter/material.dart';
import '../../core/widgets/animated_background.dart';
import '../../api/school_api.dart';
import '../../utils/shared_storage.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/layouts/dashboard_layout.dart';
import '../../widgets/dashboard/dashboard_stat_card.dart';
import '../../widgets/dashboard/dashboard_welcome_card.dart';
import '../../widgets/dashboard/dashboard_user_item.dart';
import '../../widgets/dashboard/dashboard_section_card.dart';
import '../../core/theme/app_colors.dart';

/// School Admin Dashboard Screen - Refactored with new layout
///
/// Fitur:
/// - Statistik kehadiran sekolah (real-time)
/// - Quick access ke user management
/// - School settings shortcut
/// - Recent attendance overview
class SchoolAdminDashboardScreen extends StatefulWidget {
  const SchoolAdminDashboardScreen({super.key});

  @override
  State<SchoolAdminDashboardScreen> createState() =>
      _SchoolAdminDashboardScreenState();
}

class _SchoolAdminDashboardScreenState
    extends State<SchoolAdminDashboardScreen> {
  // Theme provider - global state
  final ThemeProvider _themeProvider = ThemeProvider();

  // 🆕 State untuk real data dari API
  bool _isLoading = true;
  Map<String, dynamic>? _schoolStats;
  Map<String, dynamic>? _userStats;
  List<dynamic>? _recentAttendance;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// 🔄 Load dashboard data dari API
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final token = await SharedStorage.getToken();
      final userData = await SharedStorage.getUserData();

      if (token == null || userData == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final user = userData;
      final schoolId = user['school_id'] as int?;

      if (schoolId == null) {
        _handleError('School ID tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      // Load school statistics
      final statsResult = await SchoolApiService.getSchoolStatistics(
        token: token,
        schoolId: schoolId,
      );

      // Load school users
      final usersResult = await SchoolApiService.getSchoolUsers(
        token: token,
        schoolId: schoolId,
      );

      // Load today's attendance
      final today = DateTime.now().toIso8601String().split('T')[0];
      final attendanceResult = await SchoolApiService.getSchoolAttendance(
        token: token,
        schoolId: schoolId,
        date: today,
      );

      if (mounted) {
        setState(() {
          if (statsResult['success'] == true) {
            _schoolStats = statsResult['data'];
          }

          if (usersResult['success'] == true) {
            final users = usersResult['users'] as List?;
            if (users != null) {
              _userStats = {
                'total_students': users.where((u) => u['role'] == 'STUDENT').length,
                'total_teachers': users.where((u) => u['role'] == 'TEACHER').length,
                'total_admins': users.where((u) => u['role'] == 'SCHOOL_ADMIN').length,
                'pending': users.where((u) => u['status'] == 'PENDING').length,
              };
            }
          }

          if (attendanceResult['success'] == true) {
            _recentAttendance = attendanceResult['attendance'];
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      _handleError('Terjadi kesalahan: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  /// 🚨 Handle error
  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
      child: DashboardLayout(
        title: 'Dashboard Admin',
        userRole: 'SCHOOL_ADMIN',
        isDarkMode: _themeProvider.isDarkMode,
        onRefresh: _loadDashboardData,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 80, // ✅ Increased space for bottom navigation
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Welcome message
              DashboardWelcomeCard.forRole(
                role: 'SCHOOL_ADMIN',
                userName: 'Admin',
                isDarkMode: _themeProvider.isDarkMode,
              ),
              const SizedBox(height: 20),

              // 📊 Statistics Cards
              _buildStatisticsGrid(),
              const SizedBox(height: 20),

              // 👥 User Management Quick Access
              _buildUserManagementCard(),
              const SizedBox(height: 20),

              // ⚙️ School Settings Quick Access
              _buildSchoolSettingsCard(),
              const SizedBox(height: 20),

              // 📑 Recent Attendance
              _buildRecentAttendanceCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    // 🆕 Tampilkan loading indicator jika sedang load
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 🆕 Gunakan real data dari API
    final totalSiswa = _userStats?['total_students'] ?? 0;
    final totalGuru = _userStats?['total_teachers'] ?? 0;
    final hadirHariIni = _schoolStats?['present'] ?? 0;
    final kehadiran = _schoolStats?['attendance_rate']?.toStringAsFixed(1) ?? '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Sekolah',
          style: TextStyle(
            color: _themeProvider.isDarkMode
                ? AppColors.darkTextSecondary
                : Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            DashboardStatCard(
              icon: Icons.people,
              label: 'Total Siswa',
              value: totalSiswa.toString(),
              color: AppColors.formalNavy,
              isDarkMode: _themeProvider.isDarkMode,
            ),
            DashboardStatCard(
              icon: Icons.check_circle,
              label: 'Hadir Hari Ini',
              value: hadirHariIni.toString(),
              color: AppColors.formalGreen,
              isDarkMode: _themeProvider.isDarkMode,
            ),
            DashboardStatCard(
              icon: Icons.school,
              label: 'Total Guru',
              value: totalGuru.toString(),
              color: Colors.purple,
              isDarkMode: _themeProvider.isDarkMode,
            ),
            DashboardStatCard(
              icon: Icons.show_chart,
              label: 'Kehadiran',
              value: '$kehadiran%',
              color: Colors.orange,
              isDarkMode: _themeProvider.isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserManagementCard() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manajemen Users',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DashboardUserItem(
            icon: Icons.school,
            label: 'Students',
            count: '${_userStats?['total_students'] ?? 0}',
            color: AppColors.formalNavy,
            isDarkMode: _themeProvider.isDarkMode,
          ),
          DashboardUserItem(
            icon: Icons.person,
            label: 'Teachers',
            count: '${_userStats?['total_teachers'] ?? 0}',
            color: Colors.purple,
            isDarkMode: _themeProvider.isDarkMode,
          ),
          DashboardUserItem(
            icon: Icons.pending,
            label: 'Pending',
            count: '${_userStats?['pending'] ?? 0}',
            color: Colors.orange,
            isDarkMode: _themeProvider.isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolSettingsCard() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengaturan Sekolah',
                style: TextStyle(
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: _themeProvider.isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSettingItem(
                  icon: Icons.access_time,
                  label: 'Jam Masuk',
                  value: '07:00',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSettingItem(
                  icon: Icons.outbound,
                  label: 'Jam Pulang',
                  value: '16:00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.location_on,
            label: 'Radius Presensi',
            value: '100 meter',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (_themeProvider.isDarkMode
                ? AppColors.darkAccent
                : AppColors.formalNavy)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _themeProvider.isDarkMode
                ? AppColors.darkAccent
                : AppColors.formalNavy,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAttendanceCard() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Absensi Terbaru',
                style: TextStyle(
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.history,
                color: _themeProvider.isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 🆕 Tampilkan data real absensi terbaru
          ...(_recentAttendance ?? []).take(3).map((attendance) {
            final user = attendance['user'] as Map? ?? {};
            final status = attendance['status']?.toString() ?? 'HADIR';

            // Tentukan warna berdasarkan status
            Color statusColor;
            switch (status) {
              case 'HADIR':
                statusColor = AppColors.formalGreen;
                break;
              case 'TERLAMBAT':
                statusColor = Colors.orange;
                break;
              case 'IZIN':
                statusColor = Colors.blue;
                break;
              case 'SAKIT':
                statusColor = Colors.purple;
                break;
              default:
                statusColor = Colors.grey;
            }

            return _buildAttendanceItem(
              name: user['fullname']?.toString() ?? 'Unknown',
              kelas: user['kelas']?.toString() ?? '-',
              status: status == 'HADIR' ? 'Hadir' : status,
              time: attendance['jam_masuk']?.toString().substring(0, 5) ?? '-',
              statusColor: statusColor,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem({
    required String name,
    required String kelas,
    required String status,
    required String time,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              status == 'Hadir'
                  ? Icons.check_circle
                  : status == 'Terlambat'
                      ? Icons.access_time
                      : Icons.event_note,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$kelas • $time',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
