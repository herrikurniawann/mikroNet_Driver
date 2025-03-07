import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart';

class WebSocketService {
  final WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse('ws://188.166.179.146:8000/api/tracking/ws/location'));

  Stream<LatLng> get driverLocationStream => channel.stream.map((message) {
        final data = jsonDecode(message);
        return LatLng(data['lat'], data['lng']);
      });

  void sendLocation(double lat, double lng) {
    channel.sink.add(jsonEncode({'lat': lat, 'lng': lng}));
  }

  void close() {
    channel.sink.close();
  }
}
