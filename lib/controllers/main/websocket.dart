import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
      }, onError: (error) {
      }, onDone: () {
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
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position position = await Geolocator.getCurrentPosition();
      final data = {
        "user_id": driverId,
        "lat": position.latitude,
        "lng": position.longitude
      };
      _channel?.sink.add(jsonEncode(data));
    });
  }

  void dispose() => disconnect();
}
