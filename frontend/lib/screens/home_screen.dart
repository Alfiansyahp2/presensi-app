import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_absensi/screens/profile_screen.dart';
import 'package:flutter_absensi/screens/history_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_absensi/service/API_config.dart';
import 'package:flutter_absensi/utils/shared_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_absensi/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  LatLng? _currentPosition;
  bool _hasAbsenToday = false;

  // Getter untuk menghitung isInRadius secara real-time
  bool get _isInRadius {
    if (_currentPosition == null) return false;
    return _checkIsInRadius(_currentPosition!, _targetLocation, 50);
  }

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final LatLng _targetLocation =
      const LatLng(-7.32787262808773, 112.79426795133186); // MA-2, Jl. Medokan Asri Tengah No.12 Blok Q, Medokan Ayu, Kec. Rungkut, Surabaya

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Cek apakah sudah absen hari ini
    _checkAbsenToday();

    // Pindahkan pemanggilan _determinePosition setelah inisialisasi animasi
    _determinePosition();
  }

  Future<void> _checkAbsenToday() async {
    final hasAbsen = await SharedStorage.hasAbsenToday();
    if (mounted) {
      setState(() {
        _hasAbsenToday = hasAbsen;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location service disabled');
        // Set default position untuk testing jika location tidak aktif
        setState(() {
          _currentPosition = _targetLocation; // Gunakan lokasi target sebagai default
        });
        _animationController.forward();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          debugPrint('Location permission denied');
          // Set default position untuk testing
          setState(() {
            _currentPosition = _targetLocation;
          });
          _animationController.forward();
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

      _animationController.forward();
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Set default position untuk testing jika gagal
      setState(() {
        _currentPosition = _targetLocation;
      });
      _animationController.forward();
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

  void _showIOSDialog({
    required String title,
    required String content,
    String? actionText,
    VoidCallback? onAction,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (actionText != null && onAction != null)
            CupertinoDialogAction(
              child: Text(actionText),
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
            ),
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
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
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (!_isInRadius) {
      if (!mounted) return;
      _showIOSDialog(
        title: 'Di Luar Radius',
        content: 'Anda berada di luar radius absen (50 meter). Silakan mendekat ke lokasi absen.',
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/absen'),
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
          // Simpan tanggal absen terakhir
          await SharedStorage.saveLastAbsenDate(DateTime.now().toIso8601String());

          // Update state bahwa sudah absen hari ini
          if (!mounted) return;
          setState(() {
            _hasAbsenToday = true;
          });

          // Tampilkan dialog sukses iOS-style
          _showIOSDialog(
            title: 'Absen Berhasil!',
            content: 'Waktu: ${DateTime.now().toString().substring(0, 19)}',
            actionText: 'Lihat Riwayat',
            onAction: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          );
        } else {
          if (!mounted) return;
          _showIOSDialog(
            title: 'Gagal',
            content: responseData['message'] ?? 'Terjadi kesalahan',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showIOSDialog(
        title: 'Error',
        content: 'Gagal menghubungi server. Silakan cek koneksi internet Anda.',
      );
    }
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox(
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
                      Marker(
                        point: _currentPosition!,
                        width: 60,
                        height: 60,
                        child: Icon(
                          CupertinoIcons.location_solid,
                          color: _isInRadius ? AppColors.success : AppColors.error,
                          size: 48,
                        ),
                      ),
                      Marker(
                        point: _targetLocation,
                        width: 40,
                        height: 40,
                        child: Icon(
                          CupertinoIcons.location_solid,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Radius Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowMedium,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.scope,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Radius: 50m',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Status Badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isInRadius
                      ? AppColors.success
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isInRadius ? AppColors.success : AppColors.error).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isInRadius ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                      color: AppColors.textLight,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isInRadius ? 'Dalam Radius' : 'Di Luar Radius',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Status Bar at Bottom
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isInRadius
                      ? AppColors.success
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (_isInRadius ? AppColors.success : AppColors.error).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isInRadius ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                      color: AppColors.textLight,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isInRadius
                            ? 'Anda berada dalam radius absen (50m)'
                            : 'Anda di luar radius absen - Jarak lebih dari 50m',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isInRadius ? AppColors.success : AppColors.error,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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
            // Status Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isInRadius
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isInRadius ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.info_circle_fill,
                    color: _isInRadius ? AppColors.success : AppColors.error,
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
                        style: AppTextStyles.titleSmall.copyWith(
                          color: _isInRadius ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jarak: ${distance.toStringAsFixed(1)} meter dari lokasi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$todayName, $todayDate',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            // Current Location
            Row(
              children: [
                Icon(
                  CupertinoIcons.location,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _currentPosition != null
                        ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}'
                        : 'Lokasi tidak terdeteksi',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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
                  CupertinoIcons.location_solid,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'MA-2, Jl. Medokan Asri Tengah No.12 Blok Q, Medokan Ayu, Rungkut, Surabaya',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsenButton() {
    // Cek apakah tombol harus disabled
    bool isButtonDisabled = !_isInRadius || _hasAbsenToday;

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: isButtonDisabled ? null : _submitAbsen,
        color: isButtonDisabled
            ? AppColors.textTertiary
            : AppColors.primary,
        disabledColor: AppColors.textTertiary,
        padding: const EdgeInsets.symmetric(vertical: 18),
        borderRadius: BorderRadius.circular(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasAbsenToday
                  ? CupertinoIcons.check_mark_circled
                  : (_isInRadius ? CupertinoIcons.check_mark_circled : CupertinoIcons.location),
              color: AppColors.textLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              _hasAbsenToday
                  ? 'SUDAH ABSEN HARI INI'
                  : (_isInRadius ? 'ABSEN SEKARANG' : 'DI LUAR RADIUS - TIDAK BISA ABSEN'),
              style: AppTextStyles.buttonLarge.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
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
            child: CupertinoActivityIndicator(
              color: AppColors.primary,
              radius: 20,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mendeteksi lokasi...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Beranda Absensi',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.time,
            color: AppColors.textLight,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const HistoryScreen(),
              ),
            );
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.person_circle,
            color: AppColors.textLight,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const ProfileScreen(),
                fullscreenDialog: true,
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: _currentPosition == null
            ? _buildLoadingScreen()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, _slideAnimation.value),
                    end: Offset.zero,
                  ).animate(_animationController),
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
              ),
            ),
          );
  }
}