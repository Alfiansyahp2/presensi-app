import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/shared_storage.dart';
import '../core/widgets/animated_background.dart';
import '../core/theme/app_colors.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

/// 🎨 Formal Home Screen dengan Theme Support
///
/// Features:
/// - Formal professional design
/// - Light & Dark mode support
/// - Interactive map dengan location tracking
/// - GPS-based attendance validation (50m radius)
/// - Real-time status updates
/// - Theme toggle button
/// - Smooth animations
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  LatLng? _currentPosition;
  bool _hasAbsenToday = false;
  bool _isDarkMode = false;
  bool _isLoading = false;

  // Getter untuk menghitung isInRadius secara real-time
  bool get _isInRadius {
    if (_currentPosition == null) return false;
    return _checkIsInRadius(_currentPosition!, _targetLocation, 50);
  }

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  final LatLng _targetLocation = const LatLng(
    -7.32787262808773,
    112.79426795133186,
  ); // MA-2, Jl. Medokan Asri Tengah No.12 Blok Q, Medokan Ayu, Kec. Rungkut, Surabaya

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkAbsenToday();
    _determinePosition();
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
    // Save theme preference
    SharedStorage.saveThemeMode(_isDarkMode);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAbsenToday() async {
    final hasAbsen = await SharedStorage.hasAbsenToday();
    if (mounted) {
      setState(() {
        _hasAbsenToday = hasAbsen;
      });
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location service disabled');
        setState(() {
          _currentPosition = _targetLocation;
        });
        _fadeController.forward();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          debugPrint('Location permission denied');
          setState(() {
            _currentPosition = _targetLocation;
          });
          _fadeController.forward();
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('Position detected: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _fadeController.forward();
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _currentPosition = _targetLocation;
      });
      _fadeController.forward();
    }
  }

  bool _checkIsInRadius(LatLng current, LatLng target, double radiusMeter) {
    final distance = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      target.latitude,
      target.longitude,
    );
    return distance <= radiusMeter;
  }

  void _showDialog({
    required String title,
    required String content,
    String? actionText,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: _isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: _isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        backgroundColor:
            _isDarkMode ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionText),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAbsen() async {
    if (_currentPosition == null) return;

    final token = await SharedStorage.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      return;
    }

    if (!_isInRadius) {
      _showDialog(
        title: 'Di Luar Radius',
        content:
            'Anda berada di luar radius absen (50 meter). Silakan mendekat ke lokasi absen.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/absen'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'status': 'hadir',
        }),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          await SharedStorage.saveLastAbsenDate(
            DateTime.now().toIso8601String(),
          );

          if (!mounted) return;
          setState(() {
            _hasAbsenToday = true;
            _isLoading = false;
          });

          _showDialog(
            title: 'Absen Berhasil!',
            content: 'Waktu: ${DateTime.now().toString().substring(0, 19)}',
            actionText: 'Lihat Riwayat',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          _showDialog(
            title: 'Gagal',
            content: responseData['message'] ?? 'Terjadi kesalahan',
          );
        }
      }
    } catch (e) {
      debugPrint('Error in _submitAbsen: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showDialog(
          title: 'Error',
          content:
              'Gagal menghubungi server. Silakan cek koneksi internet Anda.',
        );
      }
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _currentPosition == null
        ? _buildLoadingScreen()
        : FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, _slideAnimation.value),
                end: Offset.zero,
              ).animate(_fadeController),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Map Card with Scale Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildMapCard(),
                    ),
                    const SizedBox(height: 20),
                    // Location Info
                    _buildLocationInfo(),
                    const SizedBox(height: 20),
                    // Absen Button
                    _buildAbsenButton(),
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
            // History button
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
            // Profile button
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
            'Mendeteksi lokasi...',
            style: TextStyle(
              color: _isDarkMode ? AppColors.darkAccent : AppColors.formalNavy,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                      color: _isInRadius ? AppColors.formalGreen : AppColors.error,
                      size: 48,
                    ),
                  ),
                  // Target school marker
                  Marker(
                    point: _targetLocation,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.school,
                      color: AppColors.formalNavy,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    // Format tanggal hari ini
    final now = DateTime.now();
    final todayDate = '${now.day}/${now.month}/${now.year}';
    final weekdays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final todayName = weekdays[now.weekday - 1];

    double distance = _currentPosition != null
        ? Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            _targetLocation.latitude,
            _targetLocation.longitude,
          )
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isInRadius ? AppColors.formalGreen : AppColors.error,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_isInRadius ? AppColors.formalGreen : AppColors.error)
                      .withValues(alpha: _isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isInRadius ? Icons.check_circle : Icons.info_outline,
                  color: _isInRadius ? AppColors.formalGreen : AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isInRadius ? 'ANDA DALAM RADIUS' : 'DI LUAR RADIUS',
                      style: TextStyle(
                        color: _isInRadius ? AppColors.formalGreen : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Jarak: ${distance.toStringAsFixed(1)} meter dari lokasi',
                      style: TextStyle(
                        color: _isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (_isDarkMode ? AppColors.darkAccent : AppColors.formalNavy)
                  .withValues(alpha: _isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (_isDarkMode ? AppColors.darkAccent : AppColors.formalNavy)
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _isDarkMode ? AppColors.darkAccent : AppColors.formalNavy,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '$todayName, $todayDate',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.darkTextPrimary : AppColors.formalNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            color: _isDarkMode
                ? AppColors.darkTextSecondary.withValues(alpha: 0.2)
                : AppColors.border.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          // Current Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _isDarkMode ? AppColors.darkAccent : AppColors.formalNavy,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _currentPosition != null
                      ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}'
                      : 'Lokasi tidak terdeteksi',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Target Location
          Row(
            children: [
              Icon(
                Icons.school,
                color: _isDarkMode ? AppColors.darkAccent : AppColors.formalNavy,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'MA-2, Jl. Medokan Asri Tengah No.12 Blok Q',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenButton() {
    // Cek apakah tombol harus disabled
    bool isButtonDisabled = !_isInRadius || _hasAbsenToday || _isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : _submitAbsen,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonDisabled
              ? (_isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary)
              : (_isDarkMode ? AppColors.darkAccent : AppColors.formalNavy),
          foregroundColor: _isDarkMode ? AppColors.darkTextPrimary : Colors.white,
          disabledBackgroundColor: _isDarkMode ? AppColors.darkSurface : AppColors.surfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasAbsenToday
                  ? Icons.check_circle
                  : (_isInRadius ? Icons.check_circle : Icons.location_off),
              color: _isDarkMode ? AppColors.darkTextPrimary : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              _hasAbsenToday
                  ? 'SUDAH ABSEN HARI INI'
                  : (_isInRadius ? 'ABSEN SEKARANG' : 'DI LUAR RADIUS - TIDAK BISA ABSEN'),
              style: TextStyle(
                color: _isDarkMode ? AppColors.darkTextPrimary : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
