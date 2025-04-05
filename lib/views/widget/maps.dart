import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MapScreen extends StatefulWidget {
  final String? driverId;
  final LatLng? driverPosition;

  const MapScreen({super.key, this.driverId, this.driverPosition});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    fetchRoute();
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
        final data = jsonDecode(response.body);
        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List;

        setState(() {
          routePoints =
              coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        });
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(1.4693, 124.8262),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  color: Colors.blue,
                  strokeWidth: 3.0,
                ),
              ],
            ),
          if (widget.driverPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: widget.driverPosition!,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svg/cars.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ],
            ),
          const MarkerLayer(
            markers: [
              Marker(
                  point: LatLng(1.4576477649812942, 124.806202431662),
                  child: Icon(Icons.place_sharp, color: Colors.black)),
              Marker(
                  point: LatLng(1.463911368970314, 124.83959056958739),
                  child: SizedBox()),
              Marker(
                  point: LatLng(1.4632790075271764, 124.82742214408177),
                  child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}
