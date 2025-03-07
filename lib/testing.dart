import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridehailing/models/localstorage_models.dart';
import 'package:ridehailing/controllers/driver_services.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  WebSocketChannel? channel;
  bool isOnline = false;
  LatLng? driverPosition;

  @override
  void initState() {
    super.initState();
    _fetchDriverStatus();
  }

  @override
  void dispose() {
    disconnectWebSocket(); 
    super.dispose();
  }

  Future<void> _fetchDriverStatus() async {
    try {
      bool status = await DriverStatusService.getDriverStatus();
      if (!mounted) return; 
      setState(() {
        isOnline = status;
      });

      if (status) {
        connectToWebSocket();
      }
    } catch (e) {
      print('Error mengambil status driver: $e');
    }
  }

  Future<void> connectToWebSocket() async {
    final token = await LocalStorage.getToken();
    if (token == null) {
      print('Error: Token tidak ditemukan');
      return;
    }

    const wsUrl = 'ws://188.166.179.146:8000/api/tracking/ws/location';
    print('Menghubungkan ke WebSocket: $wsUrl');

    try {
      channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      channel!.stream.listen((message) {
        print('Pesan diterima: $message');

        try {
          final data = jsonDecode(message);
          if (data.containsKey('user_id') && data['user_id'] == "123123") {
            if (!mounted) return; // 🔥 Hindari error jika widget sudah dihapus
            setState(() {
              driverPosition = LatLng(data['lat'], data['lng']);
            });
          }
        } catch (e) {
          print('Error parsing WebSocket message: $e');
        }
      }, onError: (error) {
        print('WebSocket Error: $error');
        if (!mounted) return;
        setState(() {
          isOnline = false;
        });
      }, onDone: () {
        print('WebSocket Connection Closed');
        if (!mounted) return;
        setState(() {
          isOnline = false;
        });
      });

      if (!mounted) return;
      setState(() {
        isOnline = true;
      });
    } catch (e) {
      print('Gagal menghubungkan WebSocket: $e');
    }
  }

  Future<void> toggleDriverStatus() async {
    bool newStatus = !isOnline;

    try {
      bool updatedStatus =
          await DriverStatusService.updateDriverStatus(newStatus);
      if (!mounted) return;
      setState(() {
        isOnline = updatedStatus;
      });

      if (updatedStatus) {
        connectToWebSocket();
      } else {
        disconnectWebSocket();
      }
    } catch (e) {
      print('Error mengupdate status driver: $e');
    }
  }

  void disconnectWebSocket() {
    if (channel != null) {
      print('Menutup koneksi WebSocket...');
      channel!.sink.close();
      channel = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking Driver")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isOnline ? "🟢 Online" : "🔴 Offline",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleDriverStatus,
              child: Text(isOnline ? "Go Offline" : "Go Online"),
            ),
          ],
        ),
      ),
    );
  }
}
