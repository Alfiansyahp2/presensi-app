import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';

/// 🎨 Modern iOS-Style Map Widget
///
/// Cupertino-style map widget with iOS design language
/// Professional markers and indicators - not "norak"
class MapWidget extends StatefulWidget {
  final LatLng? currentLocation;
  final LatLng targetLocation;
  final double radius;

  const MapWidget({
    super.key,
    this.currentLocation,
    required this.targetLocation,
    this.radius = 50,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>
    with SingleTickerProviderStateMixin {
  late LatLng _centerLocation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _centerLocation = widget.currentLocation ?? widget.targetLocation;
    _initPulseAnimation();
  }

  void _initPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocation != null) {
      setState(() {
        _centerLocation = widget.currentLocation!;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get isInRadius {
    if (widget.currentLocation == null) return false;
    final distance = Geolocator.distanceBetween(
      widget.currentLocation!.latitude,
      widget.currentLocation!.longitude,
      widget.targetLocation.latitude,
      widget.targetLocation.longitude,
    );
    return distance <= widget.radius;
  }

  Color get _statusColor {
    if (widget.currentLocation == null) return AppColors.textSecondary;
    return isInRadius ? AppColors.statusHadir : AppColors.statusSakit;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentLocation == null) {
      return _buildLoadingState();
    }

    return _buildMap();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 15),
            SizedBox(height: 16),
            Text(
              'Mendeteksi lokasi...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Map
            FlutterMap(
              options: MapOptions(
                initialCenter: _centerLocation,
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
                      point: widget.currentLocation!,
                      width: 60,
                      height: 60,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          CupertinoIcons.location_solid,
                          color: _statusColor,
                          size: 40,
                        ),
                      ),
                    ),
                    // Target location marker (School)
                    Marker(
                      point: widget.targetLocation,
                      width: 50,
                      height: 50,
                      child: Icon(
                        CupertinoIcons.building_2_fill,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                // Circle layer untuk radius
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: widget.targetLocation,
                      color: AppColors.primary.withOpacity(0.15),
                      borderStrokeWidth: 2,
                      borderColor: AppColors.primary,
                      radius: widget.radius,
                      useRadiusInMeter: true,
                    ),
                  ],
                ),
              ],
            ),

            // Radius badge
            Positioned(
              top: 12,
              left: 12,
              child: _buildRadiusBadge(),
            ),

            // Status indicator
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _buildStatusIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          const SizedBox(width: 8),
          Text(
            'Radius: ${widget.radius.toInt()}m',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final bool inRadius = isInRadius;
    final Color statusColor = inRadius
        ? AppColors.statusHadir
        : AppColors.statusSakit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            inRadius
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.xmark_circle_fill,
            color: AppColors.textLight,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              inRadius
                  ? 'Anda berada dalam radius sekolah'
                  : 'Di luar radius sekolah',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
