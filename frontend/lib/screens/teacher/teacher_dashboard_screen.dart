import 'package:flutter/material.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/theme/app_colors.dart';
import '../../api/absensi_api.dart';
import '../../utils/shared_storage.dart';
import '../../providers/theme_provider.dart';

/// Teacher Dashboard Screen
///
/// Fitur:
/// - Melihat statistik absensi hari ini (hadir, terlambat, izin, sakit)
/// - Daftar siswa yang belum absen
/// - Quick access ke class list dan approval
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();

  // 🆕 State untuk real data dari API
  bool _isLoading = true;
  Map<String, dynamic>? _todayStats;
  List<dynamic>? _allStudents;
  List<dynamic>? _missingStudents;
  List<dynamic>? _pendingApprovals;

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

      // Load attendance data hari ini untuk semua siswa
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

      final attendanceResult = await AbsensiApi.getAdminAttendance(
        token: token,
        date: today,
      );

      if (attendanceResult['success'] == true && mounted) {
        final attendanceData = attendanceResult['data'] as Map;

        // Parse data dari paginated response
        final attendances = attendanceData['data'] as List? ?? [];

        // Hitung statistik
        final hadir = attendances.where((a) => a['status'] == 'HADIR').length;
        final terlambat = attendances.where((a) => a['status'] == 'TERLAMBAT').length;
        final izin = attendances.where((a) => a['status'] == 'IZIN').length;
        final sakit = attendances.where((a) => a['status'] == 'SAKIT').length;

        setState(() {
          _todayStats = {
            'hadir': hadir,
            'terlambat': terlambat,
            'izin': izin,
            'sakit': sakit,
            'total': attendances.length,
          };

          // Load pending approvals (IZIN & SAKIT)
          _pendingApprovals = attendances.where((a) =>
              a['status'] == 'IZIN' || a['status'] == 'SAKIT').toList();

          _isLoading = false;
        });
      } else {
        _handleError('Gagal memuat data absensi');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      _handleError('Terjadi kesalahan: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  /// 🚨 Handle error dan tampilkan snackbar
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Dashboard Guru',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _loadDashboardData(); // 🆕 Refresh data
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 Welcome message
                _buildWelcomeCard(),
                const SizedBox(height: 20),

                // 📊 Statistics Cards
                _buildStatisticsGrid(),
                const SizedBox(height: 20),

                // 👥 Students not yet present
                _buildMissingStudentsCard(),
                const SizedBox(height: 20),

                // ✅ Pending Approvals
                _buildPendingApprovalsCard(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _themeProvider.isDarkMode
              ? [
                  AppColors.darkAccent,
                  AppColors.darkAccent.withOpacity(0.7),
                ]
              : [
                  AppColors.formalNavy,
                  AppColors.formalNavyLight,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_themeProvider.isDarkMode ? AppColors.darkAccent : AppColors.formalNavy)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang, Guru! 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Berikut ringkasan absensi hari ini',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    // 🆕 Tampilkan loading indicator jika sedang load data
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 🆕 Gunakan real data dari API
    final hadir = _todayStats?['hadir'] ?? 0;
    final terlambat = _todayStats?['terlambat'] ?? 0;
    final izin = _todayStats?['izin'] ?? 0;
    final sakit = _todayStats?['sakit'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Hari Ini',
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
            _buildStatCard(
              icon: Icons.check_circle,
              label: 'Hadir',
              value: hadir.toString(),
              color: AppColors.formalGreen,
            ),
            _buildStatCard(
              icon: Icons.access_time,
              label: 'Terlambat',
              value: terlambat.toString(),
              color: Colors.orange,
            ),
            _buildStatCard(
              icon: Icons.event_note,
              label: 'Izin',
              value: izin.toString(),
              color: Colors.blue,
            ),
            _buildStatCard(
              icon: Icons.sick,
              label: 'Sakit',
              value: sakit.toString(),
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _themeProvider.isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: _themeProvider.isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingStudentsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _themeProvider.isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Belum Absen',
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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '2 Siswa',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildStudentItem(name: 'Ahmad Rizki', kelas: 'XII-A'),
          _buildStudentItem(name: 'Siti Nurhaliza', kelas: 'XII-A'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStudentItem({required String name, required String kelas}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: Colors.red, size: 20),
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
                  kelas,
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
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Belum',
              style: TextStyle(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsCard() {
    // 🆕 Gunakan real data dari API
    final pendingApprovals = _pendingApprovals ?? [];

    // Jika tidak ada pending approvals, jangan tampilkan card
    if (pendingApprovals.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: _themeProvider.isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Persetujuan Izin',
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pendingApprovals.length} Pending',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 🆕 Tampilkan list pending approvals dari API
          ...pendingApprovals.map((approval) {
            final user = approval['user'] as Map? ?? {};
            return _buildApprovalItem(
              name: user['fullname']?.toString() ?? 'Unknown',
              kelas: user['kelas']?.toString() ?? '-',
              reason: approval['status']?.toString() ?? 'IZIN',
              time: approval['jam_masuk']?.toString().substring(0, 5) ?? '-',
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildApprovalItem({
    required String name,
    required String kelas,
    required String reason,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_note, color: Colors.orange, size: 20),
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
                  '$kelas • $reason • $time',
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
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to approval screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.formalGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Review',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _themeProvider.isDarkMode
            ? AppColors.darkSurface.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // TODO: Navigate based on index
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              // Navigate to class list
              break;
            case 2:
              // Navigate to approvals
              break;
            case 3:
              // Navigate to profile
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Siswa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Persetujuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
