import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:ridehailing/components/localstorage_models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridehailing/services/driver_services.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];
  LatLng? driverPosition;
  WebSocketChannel? channel;
  Timer? _timer;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    fetchRoute();
    _checkStatusAndConnect();
  }

  Future<void> fetchRoute() async {
    const url =
        'http://router.project-osrm.org/route/v1/driving/124.8104,1.4638;124.8421,1.4748?geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        routePoints =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
      });
    }
  }

  void _checkStatusAndConnect() async {
    final token = await LocalStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final status = await DriverStatusService.getDriverStatus();
    setState(() {
      _isOnline = status;
    });

    if (_isOnline) {
      _connectToWebSocket();
      _startSendingLocation();
    }
  }

  void _connectToWebSocket() async {
    final token = await LocalStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    channel = WebSocketChannel.connect(
      Uri.parse('ws://188.166.179.146:8000/api/tracking/ws/location'),
    );

    channel?.stream.listen((message) {
      print('Pesan diterima dari WebSocket: $message');
      
      final data = jsonDecode(message);
      if (data['user_id'] == "123123") {
        setState(() {
          driverPosition = LatLng(data['lat'], data['lng']);
        });
      }
      if (driverPosition != null) {
        print("Driver Position: $driverPosition");
      } else {
        print("Driver position belum tersedia");
      }
    });
  }

  void _startSendingLocation() {
    const interval = Duration(seconds: 10);
    _timer = Timer.periodic(interval, (timer) async {
      final position = await Geolocator.getCurrentPosition();
      final token = await LocalStorage.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final locationData = {
        "user_id": "123123",
        "lat": position.latitude,
        "lng": position.longitude,
      };

      channel?.sink.add(jsonEncode(locationData));
    });
  }

  void _stopSendingLocation() {
    _timer?.cancel();
    channel?.sink.close();
  }

  @override
  void dispose() {
    _stopSendingLocation();
    super.dispose();
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
                  strokeWidth: 5.0,
                ),
              ],
            ),
          if (driverPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: driverPosition!,
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}