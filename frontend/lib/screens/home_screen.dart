import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/shared_storage.dart';
import '../core/widgets/animated_background.dart';
import '../core/theme/app_colors.dart';
import '../api/absensi_api.dart';
import '../models/attendance_status_model.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

/// 🎯 Home Screen dengan Multi-Tenant Backend Integration
///
/// Features:
/// - ✅ Integrasi backend multi-tenant (GET /api/absensi/today)
/// - ✅ 2 tombol terpisah (Masuk & Pulang)
/// - ✅ Status otomatis dari server (HADIR/TERLAMBAT/PULANG)
/// - ✅ Foto absensi (check-in & check-out)
/// - ✅ School config dari backend (jam, radius)
/// - ✅ Light & Dark mode support
///
/// API Integration:
/// - GET /api/absensi/today → untuk tentukan tombol aktif
/// - POST /api/absensi/checkin → absen masuk + foto
/// - POST /api/absensi/checkout → absen pulang + foto
///
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // 📍 Location
  LatLng? _currentPosition;

  // 📊 Status dari Backend
  AttendanceStatus? _attendanceStatus;
  SchoolInfo? _schoolInfo;

  // ⏰ Real-time Clock
  DateTime? _currentTime;

  // ⚙️ State
  bool _isDarkMode = false;
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  // 🎨 Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  // ⏰ Timer untuk real-time clock
  Timer? _clockTimer;

  // 📷 Camera
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _initAnimations();
    _loadData();
    _loadThemePreference();
    _startClock();
  }

  /// ⏰ START CLOCK - Real-time clock update setiap detik
  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  /// 📥 LOAD DATA - Load status hari ini & location
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _loadTodayStatus(),
      _determinePosition(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  /// ✅ GET TODAY STATUS - Ambil status hari ini dari backend
  Future<void> _loadTodayStatus() async {
    try {
      final token = await SharedStorage.getToken();
      if (token == null) {
        if (mounted) _navigateToLogin();
        return;
      }

      final result = await AbsensiApi.getTodayStatus(token: token);

      if (result['success'] == true && mounted) {
        final status = result['data'] as AttendanceStatus;
        setState(() {
          _attendanceStatus = status;
          _schoolInfo = status.school;
        });
      }
    } catch (e) {
      debugPrint('Error loading today status: $e');
    }
  }

  /// 📍 GET LOCATION - Deteksi lokasi user
  Future<void> _determinePosition() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location service disabled');
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          debugPrint('Location permission denied');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('Position: ${position.latitude}, ${position.longitude}');

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _isLoadingLocation = false);
    }
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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    SharedStorage.saveThemeMode(_isDarkMode);
  }

  @override
  void dispose() {
    _clockTimer?.cancel(); // Stop real-time clock
    _fadeController.dispose();
    super.dispose();
  }

  /// ✅ CHECK-IN - Absen masuk dengan foto
  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) {
      _showError('Lokasi belum terdeteksi');
      return;
    }

    // Pilih foto dulu
    final image = await _pickImage(ImageSource.camera);
    if (image == null) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await SharedStorage.getToken();
      if (token == null) {
        if (mounted) _navigateToLogin();
        return;
      }

      final result = await AbsensiApi.checkIn(
        token: token,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        foto: image,
      );

      if (mounted) {
        if (result['success'] == true) {
          _showSuccessDialog(
            'Absen Masuk Berhasil!',
            'Status: ${result['data']?.status ?? "HADIR"}',
          );
          // Refresh status
          await _loadTodayStatus();
        } else {
          _showError(result['message'] ?? 'Gagal absen masuk');
        }
      }
    } catch (e) {
      debugPrint('Error check-in: $e');
      if (mounted) {
        _showError('Terjadi kesalahan. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// ✅ CHECK-OUT - Absen pulang dengan foto
  Future<void> _handleCheckOut() async {
    // Pilih foto dulu
    final image = await _pickImage(ImageSource.camera);
    if (image == null) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await SharedStorage.getToken();
      if (token == null) {
        if (mounted) _navigateToLogin();
        return;
      }

      final result = await AbsensiApi.checkOut(
        token: token,
        foto: image,
      );

      if (mounted) {
        if (result['success'] == true) {
          _showSuccessDialog(
            'Absen Pulang Berhasil!',
            'Hati-hati di jalan! 🙏',
          );
          // Refresh status
          await _loadTodayStatus();
        } else {
          _showError(result['message'] ?? 'Gagal absen pulang');
        }
      }
    } catch (e) {
      debugPrint('Error check-out: $e');
      if (mounted) {
        _showError('Terjadi kesalahan. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 📷 PICK IMAGE - Pilih foto dari camera
  Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        _showError('Gagal mengambil foto');
      }
      return null;
    }
  }

  /// 📏 CHECK RADIUS - Cek apakah dalam radius
  bool _isInRadius() {
    // TODO: Hitung jarak ke school location
    // Untuk sekarang, asumsi in radius
    return true;
  }

  /// 📅 FORMAT TANGGAL - dd-mm-yyyy
  String _formatDate_ddMMyyyy(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day-$month-$year';
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _isDarkMode ? AppColors.darkSurface : AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.formalGreen),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: _isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: _isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _isLoading || _attendanceStatus == null
        ? _buildLoadingScreen()
        : FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, _slideAnimation.value),
                end: Offset.zero,
              ).animate(_fadeController),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🏫 School Info Card
                    if (_schoolInfo != null) _buildSchoolInfoCard(),
                    const SizedBox(height: 20),

                    // 📊 Status Card
                    _buildStatusCard(),
                    const SizedBox(height: 20),

                    // 🗺️ Map Card
                    if (_currentPosition != null) _buildMapCard(),
                    const SizedBox(height: 20),

                    // 🎯 Action Buttons (2 TOMBOL)
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );

    return AnimatedBackground(
      isDarkMode: _isDarkMode,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: _buildThemeToggle(),
          title: const Text(
            'Beranda Absensi',
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
              onPressed: _loadData,
            ),
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Riwayat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(child: content),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode
            ? AppColors.darkSurface.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: _isDarkMode ? AppColors.darkTextPrimary : Colors.white,
        ),
        onPressed: _toggleTheme,
        tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: _isDarkMode ? AppColors.darkAccent : AppColors.formalNavy,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: _isDarkMode ? AppColors.darkAccent : AppColors.formalNavy,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 🏫 SCHOOL INFO CARD - Logo, nama, tanggal real-time, jam masuk/pulang
  Widget _buildSchoolInfoCard() {
    if (_currentTime == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [
                  AppColors.darkSurface,
                  AppColors.darkSurface.withValues(alpha: 0.8),
                ]
              : [
                  AppColors.surface,
                  AppColors.surface.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (_isDarkMode ? AppColors.darkAccent : AppColors.formalNavy)
              .withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🏫 LOGO & NAMA SEKOLAH + TANGGAL REAL-TIME
          Row(
            children: [
              // Logo Sekolah
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (_isDarkMode ? AppColors.darkAccent : AppColors.formalNavy)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_isDarkMode ? AppColors.darkAccent : AppColors.formalNavy)
                        .withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.school,
                  color: _isDarkMode ? AppColors.darkAccent : AppColors.formalNavy,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Nama Sekolah & Tanggal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Sekolah
                    Text(
                      _schoolInfo!.namaSekolah,
                      style: TextStyle(
                        color: _isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Tanggal Real-Time (dd-mm-yyyy)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: _isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.formalNavy,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate_ddMMyyyy(_currentTime!),
                          style: TextStyle(
                            color: _isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            color: (_isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary)
                .withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),

          // Waktu Masuk & Pulang (Grid dengan hh:mm:ss)
          IntrinsicHeight(
            child: Row(
              children: [
                // 🕐 JAM MASUK (hh:mm:ss)
                Expanded(
                  child: _buildTimeCard(
                    icon: Icons.login,
                    label: 'Masuk',
                    time: _schoolInfo!.formattedJamMasuk,
                    color: AppColors.formalGreen,
                  ),
                ),
                const SizedBox(width: 16),

                // Container divider vertical
                Container(
                  width: 1,
                  color: (_isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary)
                      .withValues(alpha: 0.2),
                ),
                const SizedBox(width: 16),

                // 🕑 JAM PULANG (hh:mm:ss)
                Expanded(
                  child: _buildTimeCard(
                    icon: Icons.logout,
                    label: 'Pulang',
                    time: _schoolInfo!.formattedJamPulang,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🕐 TIME CARD - Kartu waktu minimalis
  Widget _buildTimeCard({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: _isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 📊 STATUS CARD - Menampilkan status Masuk & Pulang
  Widget _buildStatusCard() {
    final status = _attendanceStatus!;
    final attendance = status.attendance;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [
                  AppColors.darkSurface,
                  AppColors.darkSurface.withValues(alpha: 0.8),
                ]
              : [
                  AppColors.surface,
                  AppColors.surface.withValues(alpha: 0.95),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (_isDarkMode ? AppColors.darkAccent : AppColors.formalNavy)
              .withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Status Hari Ini',
            style: TextStyle(
              color: _isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Grid 2 Kolom: Masuk | Pulang
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🟢 ABSEN MASUK
                Expanded(
                  child: _buildAttendanceStatusCard(
                    type: 'Masuk',
                    status: _getCheckInStatus(attendance),
                    time: attendance?.jamMasuk,
                    distance: attendance?.jarakMeter,
                    icon: Icons.login,
                    color: AppColors.formalGreen,
                  ),
                ),

                const SizedBox(width: 16),

                // Container divider vertical
                Container(
                  width: 1,
                  color: (_isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary)
                      .withValues(alpha: 0.2),
                ),

                const SizedBox(width: 16),

                // 🟠 ABSEN PULANG
                Expanded(
                  child: _buildAttendanceStatusCard(
                    type: 'Pulang',
                    status: _getCheckOutStatus(attendance),
                    time: attendance?.jamPulang,
                    distance: null,
                    icon: Icons.logout,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 KARTU STATUS (Masuk/Pulang) - Individual card
  Widget _buildAttendanceStatusCard({
    required String type,
    required String status,
    required String? time,
    required int? distance,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + Label
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: _isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Details
        _buildStatusDetail(label: 'Jam', value: time ?? '-'),
        if (distance != null) _buildStatusDetail(label: 'Jarak', value: '${distance}m'),
      ],
    );
  }

  /// 📝 DETAIL ROW (Label: Value)
  Widget _buildStatusDetail({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ GET CHECK-IN STATUS (Masuk)
  String _getCheckInStatus(AttendanceData? attendance) {
    if (attendance == null) return 'BELUM';
    if (attendance.jamMasuk == null) return 'BELUM';

    // Status dari attendance
    final status = attendance.status?.toUpperCase() ?? 'BELUM';
    if (status == 'HADIR' || status == 'TERLAMBAT') {
      return status;
    }
    return 'BELUM';
  }

  /// ✅ GET CHECK-OUT STATUS (Pulang)
  String _getCheckOutStatus(AttendanceData? attendance) {
    if (attendance == null) return 'BELUM';
    if (attendance.jamPulang != null) return 'PULANG';
    if (attendance.status?.toUpperCase() == 'PULANG') return 'PULANG';

    // Jika sudah check-in tapi belum check-out
    if (attendance.jamMasuk != null) return 'MENUNGGU';

    return 'BELUM';
  }

  /// 🗺️ MAP CARD
  Widget _buildMapCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 320,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 17,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.mobile_absen',
                ),
                MarkerLayer(
                  markers: [
                    // Current location marker
                    Marker(
                      point: _currentPosition!,
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.my_location,
                        color: _isInRadius() ? AppColors.formalGreen : AppColors.error,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 ACTION BUTTONS - 2 TOMBOL (MASUK & PULANG)
  Widget _buildActionButtons() {
    final status = _attendanceStatus!;

    // Jika sudah selesai (PULANG), tidak ada tombol
    if (status.isSelesai) {
      return _buildCompletedCard();
    }

    return Column(
      children: [
        // 🟢 TOMBOL ABSEN MASUK
        if (status.canCheckIn)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleCheckIn,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.login, size: 24),
              label: Text(
                _isSubmitting ? 'Memproses...' : 'ABSEN MASUK',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.formalGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.formalGreen.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

        // 🟠 TOMBOL ABSEN PULANG
        if (status.canCheckOut) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleCheckOut,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.logout, size: 24),
              label: Text(
                _isSubmitting ? 'Memproses...' : 'ABSEN PULANG',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.formalGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.formalGreen.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.formalGreen,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Selesai!',
            style: TextStyle(
              color: _isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda sudah menyelesaikan absensi hari ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
