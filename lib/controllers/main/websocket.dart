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
  Position? _lastPosition;

  final double _minDistance = 10.0;

  WebSocketService({this.onLocationUpdated, this.onDisconnected});

  Future<void> connect(String driverId) async {
    final token = await LocalStorage.getToken();
    if (token == null) {
      return;
    }
    const wsUrl = 'ws://188.166.179.146:8000/api/tracking/ws/location';

    try {
      LatLng? cachedLocation = await getCachedDriverLocation();
      if (cachedLocation != null && onLocationUpdated != null) {
        onLocationUpdated!(cachedLocation);
      }

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data['user_id'] == driverId && onLocationUpdated != null) {
              final location = LatLng(data['lat'], data['lng']);
              onLocationUpdated!(location);
            }
          } catch (e) {
            return;
          }
        },
        onError: (error) {
          if (onDisconnected != null) {
            onDisconnected!();
          }
        },
        onDone: () {
          if (onDisconnected != null) {
            onDisconnected!();
          }
        },
      );

      _startLocationUpdates(driverId);
    } catch (e) {
      return;
    }
  }

  void disconnect() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (e) {
        return;
      }
      _channel = null;
    }

    if (onDisconnected != null) {
      onDisconnected!();
    }
  }

  void _startLocationUpdates(String driverId) {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        try {
          const locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          );
          
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          );

          bool shouldSend = true;
          if (_lastPosition != null) {
            double distance = Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            shouldSend = distance >= _minDistance;
          }

          if (shouldSend) {
            _lastPosition = position;

            final data = {
              "user_id": driverId,
              "lat": position.latitude,
              "lng": position.longitude
            };

            _cacheDriverLocation(position.latitude, position.longitude);

            if (_channel != null) {
              _channel!.sink.add(jsonEncode(data));
            }

            if (onLocationUpdated != null) {
              onLocationUpdated!(LatLng(position.latitude, position.longitude));
            }
          }
        } catch (e) {
          return;
        }
      },
    );
  }

  Future<void> _cacheDriverLocation(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('driver_lat', lat);
      await prefs.setDouble('driver_lng', lng);
      await prefs.setInt(
          'driver_location_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      return;
    }
  }

  Future<LatLng?> getCachedDriverLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('driver_lat');
      final lng = prefs.getDouble('driver_lng');

      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void dispose() => disconnect();
}