import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  final String? driverId;
  final LatLng? driverPosition;

  const MapScreen({super.key, this.driverId, this.driverPosition});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  List<LatLng> routePoints = [];
  List<Marker> locationMarkers = [];
  Timer? _pulseTimer;
  bool _isPulsing = false;
  double _markerScale = 1.0;
  late MapController _mapController;

  // Define route points
  final List<Map<String, dynamic>> routeLocations = [
    {
      'point': const LatLng(1.4576477649812942, 124.806202431662),
      'name': 'JL. R.W. Monginsidi',
      'color': Colors.red,
    },
    {
      'point': const LatLng(1.463911368970314, 124.83959056958739),
      'name': 'Zero Point',
      'color': Colors.green,
    },
    {
      'point': const LatLng(1.4632790075271764, 124.82742214408177),
      'name': 'Jl. Sam Ratulangi',
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _setupLocationMarkers();
    fetchRoute();
    _startPulseAnimation();
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure the route doesn't disappear when the widget updates
    if (routePoints.isEmpty) {
      fetchRoute();
    }

    // If the driver position changes, update the map view
    if (widget.driverPosition != null &&
        (oldWidget.driverPosition == null ||
            widget.driverPosition != oldWidget.driverPosition)) {
      _centerOnDriverPosition();
    }
  }

  void _centerOnDriverPosition() {
    if (widget.driverPosition != null) {
      _mapController.move(widget.driverPosition!, 15.0);
    }
  }

  void _setupLocationMarkers() {
    locationMarkers = routeLocations.map((location) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: location['point'],
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (location['color'] as Color)
                    .withValues(red: null, green: null, blue: null, alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        red: null, green: null, blue: null, alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(red: null, green: null, blue: null, alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        red: null, green: null, blue: null, alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                location['name'],
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _startPulseAnimation() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) return;
      setState(() {
        _isPulsing = true;
        _markerScale = 1.0;
      });

      // Simple animation sequence
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() {
          _markerScale = 1.2;
        });
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _markerScale = 1.1;
        });
      });

      Future.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        setState(() {
          _markerScale = 1.0;
          _isPulsing = false;
        });
      });
    });
  }

  Future<void> fetchRoute() async {
    const startPoint = '124.806202431662,1.4576477649812942';
    const point1 = '124.83959056958739,1.463911368970314';
    const point2 = '124.82742214408177,1.4632790075271764';
    const url =
        'http://router.project-osrm.org/route/v1/driving/$startPoint;$point1;$point2;$startPoint?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (!mounted) return;

        final data = jsonDecode(response.body);
        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List;

        setState(() {
          routePoints =
              coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        });
      }
    } catch (e) {
      // If the route fetch fails, we'll try again after a brief delay
      if (mounted) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && routePoints.isEmpty) {
            fetchRoute();
          }
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(1.4630, 124.8262),
              initialZoom: 13.5,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.ridehailing.app',
              ),
              // Route polyline - always show when available
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue.shade700,
                      strokeWidth: 4.0,
                      gradientColors: [
                        Colors.blue.shade300,
                        Colors.blue.shade700,
                        Colors.blue.shade900,
                      ],
                    ),
                  ],
                ),
              // Driver position marker
              if (widget.driverPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 60.0,
                      height: 60.0,
                      point: widget.driverPosition!,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        transform: Matrix4.identity()..scale(_markerScale),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isPulsing)
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(
                                      red: null,
                                      green: null,
                                      blue: null,
                                      alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            SvgPicture.asset(
                              'assets/svg/cars.svg',
                              width: 40,
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              // Location markers for route points
              MarkerLayer(markers: locationMarkers),
            ],
          ),
          // Map controls
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // My location button
                FloatingActionButton(
                  heroTag: 'myLocation',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _centerOnDriverPosition,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom in button
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(
                      _mapController.camera.center,
                      zoom > 18 ? 18 : zoom,
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom out button
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(
                      _mapController.camera.center,
                      zoom < 5 ? 5 : zoom,
                    );
                  },
                  child: const Icon(
                    Icons.remove,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
