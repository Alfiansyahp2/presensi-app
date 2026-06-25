import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/theme/app_colors.dart';
import '../../api/report_api.dart';
import '../../api/school_api.dart';
import '../../utils/shared_storage.dart';
import '../../widgets/layouts/dashboard_layout.dart';
import '../../widgets/dashboard/dashboard_section_card.dart';
import '../../providers/theme_provider.dart';

/// School Admin - Reports Screen dengan Data Aktual
///
/// Fitur:
/// - Filter laporan berdasarkan tanggal
/// - Statistik kehadiran
/// - Export laporan (TODO)
/// - Grafik kehadiran
class SchoolAdminReportsScreen extends StatefulWidget {
  const SchoolAdminReportsScreen({super.key});

  @override
  State<SchoolAdminReportsScreen> createState() =>
      _SchoolAdminReportsScreenState();
}

class _SchoolAdminReportsScreenState extends State<SchoolAdminReportsScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  bool _isLoading = true;

  // Data dari API
  Map<String, dynamic>? _reportData;
  Map<String, dynamic>? _schoolStats;

  // Filter tanggal
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initDateFilter();
    _loadReportData();
  }

  void _initDateFilter() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1); // Awal bulan ini
    _endDate = now; // Hari ini
  }

  Future<void> _loadReportData() async {
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

      final schoolId = userData['school_id'] as int?;
      if (schoolId == null) {
        _handleError('School ID tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      // Load report data
      if (_startDate != null && _endDate != null) {
        final reportResult = await ReportApiService.getAttendanceReport(
          token: token,
          startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
          schoolId: schoolId,
        );

        // Load school statistics
        final statsResult = await SchoolApiService.getSchoolStatistics(
          token: token,
          schoolId: schoolId,
        );

        if (mounted) {
          setState(() {
            if (reportResult['success'] == true) {
              _reportData = reportResult['data'];
            }
            if (statsResult['success'] == true) {
              _schoolStats = statsResult['data'];
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading report: $e');
      _handleError('Terjadi kesalahan: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: DateTimeRange(
        start: _startDate!,
        end: _endDate!,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
      child: DashboardLayout(
        title: 'Laporan Kehadiran',
        userRole: 'SCHOOL_ADMIN',
        isDarkMode: _themeProvider.isDarkMode,
        onRefresh: _loadReportData,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Pilih Rentang Tanggal',
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export (TODO)',
            onPressed: () {
              // TODO: Implement export
            },
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 80, // ✅ Increased space for bottom navigation
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reportData == null
                  ? _buildEmptyState()
                  : _buildReportContent(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: _themeProvider.isDarkMode
                ? AppColors.darkAccent.withValues(alpha: 0.5)
                : AppColors.formalNavy.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada data laporan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih rentang tanggal untuk melihat laporan',
            style: TextStyle(
              fontSize: 14,
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📅 Date Range Info
        _buildDateRangeCard(),
        const SizedBox(height: 20),

        // 📊 Statistics Overview
        _buildStatisticsOverview(),
        const SizedBox(height: 20),

        // 📈 Detailed Statistics
        _buildDetailedStatistics(),
      ],
    );
  }

  Widget _buildDateRangeCard() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: _themeProvider.isDarkMode
                ? AppColors.darkAccent
                : AppColors.formalNavy,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periode Laporan',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: _selectDateRange,
            tooltip: 'Ubah Rentang Tanggal',
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Kehadiran',
            style: TextStyle(
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total Siswa',
                  value: '${_schoolStats?['total_users'] ?? 0}',
                  icon: Icons.people,
                  color: AppColors.formalNavy,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Tingkat Kehadiran',
                  value: '${_schoolStats?['attendance_rate']?.toStringAsFixed(1) ?? '0.0'}%',
                  icon: Icons.show_chart,
                  color: AppColors.formalGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
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
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStatistics() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Detail',
            style: TextStyle(
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            label: 'Hadir',
            value: '${_schoolStats?['present'] ?? 0}',
            icon: Icons.check_circle,
            color: AppColors.formalGreen,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            label: 'Terlambat',
            value: '${_schoolStats?['late'] ?? 0}',
            icon: Icons.access_time,
            color: Colors.orange,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            label: 'Izin',
            value: '${_schoolStats?['permission'] ?? 0}',
            icon: Icons.event_note,
            color: Colors.blue,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            label: 'Sakit',
            value: '${_schoolStats?['sick'] ?? 0}',
            icon: Icons.healing,
            color: Colors.purple,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            label: 'Tidak Hadir',
            value: '${_schoolStats?['absent'] ?? 0}',
            icon: Icons.cancel,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
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
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
