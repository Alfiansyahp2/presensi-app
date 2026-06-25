import 'package:flutter/material.dart';
import '../../core/widgets/animated_background.dart';
import '../../api/school_api.dart';
import '../../api/report_api.dart';
import '../../utils/shared_storage.dart';
import '../../widgets/layouts/dashboard_layout.dart';
import '../../widgets/dashboard/dashboard_stat_card.dart';
import '../../widgets/dashboard/dashboard_welcome_card.dart';
import '../../widgets/dashboard/dashboard_section_card.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';

/// Super Admin Dashboard Screen - Refactored with new layout
///
/// Fitur:
/// - Statistik sistem-wide (total sekolah, users, absensi)
/// - Quick access ke school management
/// - Global user management
/// - System monitoring
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();

  // 🆕 State untuk real data dari API
  bool _isLoading = true;
  List<dynamic>? _schools;
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _systemSummary;

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
      if (token == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // Load semua sekolah
      final schoolsResult = await SchoolApiService.getAllSchools(token: token);

      // Load system summary reports
      final summaryResult = await ReportApiService.getSummary(token: token);

      if (mounted) {
        setState(() {
          if (schoolsResult['success'] == true) {
            _schools = schoolsResult['schools'];
          }

          if (summaryResult['success'] == true) {
            _systemSummary = summaryResult['data'];
          }

          // Calculate user stats (sementara hardcoded karena belum ada API)
          _userStats = {
            'by_role': {
              'SUPER_ADMIN': 1,
              'SCHOOL_ADMIN': _schools?.length ?? 0,
              'TEACHER': 2,
              'STUDENT': 6,
            },
            'percentages': {
              'SUPER_ADMIN': '5.0',
              'SCHOOL_ADMIN': '25.0',
              'TEACHER': '16.7',
              'STUDENT': '50.0',
            },
          };

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
        title: 'Super Admin Dashboard',
        userRole: 'SUPER_ADMIN',
        isDarkMode: _themeProvider.isDarkMode,
        showNotifications: true,
        onRefresh: _loadDashboardData,
        onNotification: () {
          // TODO: Implement notifications
        },
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
              // 👑 Welcome message
              DashboardWelcomeCard.forRole(
                role: 'SUPER_ADMIN',
                userName: 'Administrator',
                isDarkMode: _themeProvider.isDarkMode,
              ),
              const SizedBox(height: 20),

              // 📊 System-wide Statistics
              _buildSystemStatsGrid(),
              const SizedBox(height: 20),

              // 🏫 School Management
              _buildSchoolManagementCard(),
              const SizedBox(height: 20),

              // 👥 Global User Stats
              _buildUserStatsCard(),
              const SizedBox(height: 20),

              // ⚠️ System Alerts
              _buildSystemAlertsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatsGrid() {
    // 🆕 Tampilkan loading indicator jika sedang load
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 🆕 Gunakan real data dari API
    final totalSchools = _schools?.length ?? 0;
    final totalUsers = _userStats?['by_role']?['SUPER_ADMIN'] ?? 0 +
                      _userStats?['by_role']?['SCHOOL_ADMIN'] ?? 0 +
                      _userStats?['by_role']?['TEACHER'] ?? 0 +
                      _userStats?['by_role']?['STUDENT'] ?? 0;
    final absensiHariIni = _systemSummary?['attendance']?['total_records'] ?? 0;
    final kehadiran = _systemSummary?['attendance']?['attendance_rate']?.toString() ?? '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Sistem',
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
              icon: Icons.school,
              label: 'Total Sekolah',
              value: totalSchools.toString(),
              color: Colors.deepPurple,
              isDarkMode: _themeProvider.isDarkMode,
            ),
            DashboardStatCard(
              icon: Icons.people,
              label: 'Total Users',
              value: totalUsers.toString(),
              color: AppColors.formalNavy,
              isDarkMode: _themeProvider.isDarkMode,
            ),
            DashboardStatCard(
              icon: Icons.check_circle,
              label: 'Absensi Hari Ini',
              value: absensiHariIni.toString(),
              color: AppColors.formalGreen,
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

  Widget _buildSchoolManagementCard() {
    final schools = _isLoading
        ? []
        : (_schools ?? []).take(3).toList(); // Show only first 3 schools

    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manajemen Sekolah',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_schools?.length ?? 0} Sekolah',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else if (schools.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Tidak ada data sekolah',
                style: TextStyle(
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            )
          else
            ...schools.map((school) => _buildSchoolItem(
                  name: school.nama_sekolah ?? 'Unknown',
                  status: school.status_aktif == true ? 'Active' : 'Inactive',
                  students: 0, // TODO: Get from API
                  attendance: 'N/A', // TODO: Get from API
                  statusColor: school.status_aktif == true
                      ? AppColors.formalGreen
                      : Colors.red,
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSchoolItem({
    required String name,
    required String status,
    required int students,
    required String attendance,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.school, color: statusColor, size: 20),
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
                  '$students siswa • Kehadiran $attendance',
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

  Widget _buildUserStatsCard() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Users',
            style: TextStyle(
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUserStatItem(
            icon: Icons.admin_panel_settings,
            label: 'Super Admins',
            count: '1',
            color: Colors.deepPurple,
            percentage: 5.0,
          ),
          _buildUserStatItem(
            icon: Icons.business,
            label: 'School Admins',
            count: '${_schools?.length ?? 0}',
            color: Colors.orange,
            percentage: 25.0,
          ),
          _buildUserStatItem(
            icon: Icons.person,
            label: 'Teachers',
            count: '2',
            color: Colors.blue,
            percentage: 16.7,
          ),
          _buildUserStatItem(
            icon: Icons.school,
            label: 'Students',
            count: '6',
            color: AppColors.formalGreen,
            percentage: 50.0,
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatItem({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required double percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
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
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemAlertsCard() {
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
                'Alerts System',
                style: TextStyle(
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3 Alerts',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            icon: Icons.warning,
            title: 'Sekolah Inactive',
            description: 'SMK Telkom Jakarta belum aktif 7 hari',
            severity: 'high',
          ),
          _buildAlertItem(
            icon: Icons.people,
            title: 'Pending Approvals',
            description: '5 pendaftaran guru menunggu persetujuan',
            severity: 'medium',
          ),
          _buildAlertItem(
            icon: Icons.storage,
            title: 'Storage Warning',
            description: 'Server storage mencapai 85%',
            severity: 'low',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required String title,
    required String description,
    required String severity,
  }) {
    final color = severity == 'high'
        ? Colors.red
        : severity == 'medium'
            ? Colors.orange
            : Colors.yellow;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
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
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: _themeProvider.isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
