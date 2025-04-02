import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridehailing/models/main/localstorage_models.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _locationUpdateTimer;
  final Function(LatLng)? onLocationUpdated;
  final Function()? onDisconnected;

  WebSocketService({this.onLocationUpdated, this.onDisconnected});

  Future<void> connect(String driverId) async {
    final token = await LocalStorage.getToken();
    if (token == null) {
      return;
    }

    const wsUrl = 'ws://188.166.179.146:8000/api/tracking/ws/location';

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['user_id'] == driverId && onLocationUpdated != null) {
          onLocationUpdated!(LatLng(data['lat'], data['lng']));
        }
      }, onError: (error) {}, onDone: () {
        if (onDisconnected != null) {
          onDisconnected!();
        }
      });

      _startLocationUpdates(driverId);
    } catch (e) {
      return;
    }
  }

  void disconnect() {
    _locationUpdateTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    if (onDisconnected != null) {
      onDisconnected!();
    }
  }

  void _startLocationUpdates(String driverId) {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition();
      int interval = _getAdaptiveInterval(position.speed);

      _locationUpdateTimer?.cancel();
      _locationUpdateTimer =
          Timer.periodic(Duration(seconds: interval), (timer) async {
        Position newPosition = await Geolocator.getCurrentPosition();
        final data = {
          "user_id": driverId,
          "lat": newPosition.latitude,
          "lng": newPosition.longitude
        };

        // Simpan lokasi ke cache
        _cacheDriverLocation(newPosition.latitude, newPosition.longitude);

        _channel?.sink.add(jsonEncode(data));
      });
    });
  }

  int _getAdaptiveInterval(double speed) {
    if (speed < 5) return 10;
    if (speed < 20) return 5;
    return 3;
  }

  Future<void> _cacheDriverLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('driver_lat', lat);
    await prefs.setDouble('driver_lng', lng);
  }

  Future<LatLng?> getCachedDriverLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('driver_lat');
    final lng = prefs.getDouble('driver_lng');
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  }

  void dispose() => disconnect();
}
