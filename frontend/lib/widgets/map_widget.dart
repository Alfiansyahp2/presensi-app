import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  final LatLng? currentLocation;
  final LatLng targetLocation;
  final double radius;
  final Color primaryColor;

  const MapWidget({
    super.key,
    this.currentLocation,
    required this.targetLocation,
    this.radius = 50,
    this.primaryColor = const Color(0xFF1976D2),
  });

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  late LatLng _centerLocation;

  @override
  void initState() {
    super.initState();
    _centerLocation = widget.currentLocation ?? widget.targetLocation;
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

  @override
  Widget build(BuildContext context) {
    if (widget.currentLocation == null) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[200],
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mendeteksi lokasi...'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
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
                      Marker(
                        point: widget.currentLocation!,
                        width: 60,
                        height: 60,
                        child: Icon(
                          Icons.location_on,
                          color: isInRadius ? Colors.green : Colors.red,
                          size: 48,
                        ),
                      ),
                      Marker(
                        point: widget.targetLocation,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.school,
                          color: widget.primaryColor,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: widget.targetLocation,
                        color: widget.primaryColor.withOpacity(0.1),
                        borderStrokeWidth: 2,
                        borderColor: widget.primaryColor,
                        radius: widget.radius,
                        useRadiusInMeter: true,
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    'Radius: ${widget.radius.toInt()}m',
                    style: TextStyle(
                      color: widget.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isInRadius)
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Anda berada dalam radius sekolah',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
