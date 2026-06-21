import 'package:flutter/material.dart';
import '../utils/shared_storage.dart';
import '../core/widgets/animated_background.dart';
import '../core/theme/app_colors.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 🎨 Formal History Screen dengan Theme Support
///
/// Features:
/// - Formal professional design
/// - Light & Dark mode support
/// - Animated gradient background
/// - Attendance history dengan animations
/// - Theme toggle button
/// - Refresh functionality
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  List<dynamic> _attendanceHistory = [];
  bool _isLoading = true;
  bool _isDarkMode = false;

  // Fade & slide animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
    _initAnimations();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final isDarkMode = await SharedStorage.getThemeMode();
    if (mounted) {
      setState(() {
        _isDarkMode = isDarkMode;
      });
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // Save theme preference
    SharedStorage.saveThemeMode(_isDarkMode);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendanceHistory() async {
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

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _attendanceHistory = responseData['data'];
            _isLoading = false;
          });
        }
      } else {
        _handleError('Gagal memuat riwayat');
      }
    } catch (e) {
      _handleError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchAttendanceHistory();
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AppColors.formalGreen;
      case 'izin':
        return AppColors.formalGold;
      case 'sakit':
        return const Color(0xFF8B5CF6); // Violet untuk sakit
      default:
        return AppColors.error;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      default:
        return 'Tidak Hadir';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle;
      case 'izin':
        return Icons.event_note;
      case 'sakit':
        return Icons.local_hospital;
      default:
        return Icons.cancel;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: _isDarkMode
                ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                : AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Riwayat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda belum melakukan absensi',
            style: TextStyle(
              fontSize: 16,
              color: _isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> absen, int index) {
    final status = absen['status'].toString();
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    final statusIcon = _getStatusIcon(status);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.1 + (index * 0.05),
              0.6 + (index * 0.05),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        return FadeTransition(
          opacity: itemAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(itemAnimation),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isDarkMode
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
              color: statusColor.withValues(alpha: _isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Text(
                statusLabel.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: _isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${absen['latitude']}, ${absen['longitude']}',
                      style: TextStyle(
                        color: _isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: _isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                absen['waktu_absen'],
                style: TextStyle(
                  color: _isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _isDarkMode,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Riwayat Absensi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          actions: [
            // Theme toggle button
            _buildThemeToggle(),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: _isDarkMode
                        ? AppColors.darkAccent
                        : AppColors.formalNavy,
                  ),
                )
              : _attendanceHistory.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: _isDarkMode
                          ? AppColors.darkAccent
                          : AppColors.formalNavy,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Total Absensi: ${_attendanceHistory.length}',
                                    style: TextStyle(
                                      color: _isDarkMode
                                          ? AppColors.darkTextPrimary
                                          : Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _buildHistoryCard(
                                  _attendanceHistory[index],
                                  index,
                                );
                              },
                              childCount: _attendanceHistory.length,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: _isDarkMode
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
          _isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: _isDarkMode
              ? AppColors.darkTextPrimary
              : Colors.white,
        ),
        onPressed: _toggleTheme,
        tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    );
  }
}
