import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridehailing/views/widget/maps.dart';
import 'package:ridehailing/controllers/driver_services.dart';
import 'package:ridehailing/controllers/profile_main_services.dart';
import 'package:ridehailing/models/data.dart';
import 'package:ridehailing/views/profile/profile_view.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ridehailing/models/localstorage_models.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Driver? driver;
  bool isOnline = false;
  final TextEditingController nameController = TextEditingController();
  WebSocketChannel? channel;
  Timer? locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    fetchDriverData();
    fetchDriverStatus();
  }

  Future<void> fetchDriverStatus() async {
    try {
      bool status = await DriverStatusService.getDriverStatus();
      if (!mounted) return;
      setState(() {
        isOnline = status;
      });
      _manageWebSocket();
    } catch (e) {
      print('Error fetching driver status: $e');
    }
  }

  Future<void> toggleOnlineStatus() async {
    try {
      bool newStatus = await DriverStatusService.updateDriverStatus(!isOnline);
      if (!mounted) return;
      setState(() {
        isOnline = newStatus;
      });
      _manageWebSocket();
    } catch (e) {
      print('Error updating driver status: $e');
    }
  }

  void _manageWebSocket() {
    if (isOnline) {
      _connectWebSocket();
    } else {
      _disconnectWebSocket();
    }
  }

  Future<void> _connectWebSocket() async {
    final token = await LocalStorage.getToken();
    if (token == null) {
      print('Error: Token not found');
      return;
    }

    final wsUrl = 'ws://188.166.179.146:8000/api/tracking/ws/location';
    print('Connecting to WebSocket: $wsUrl');

    try {
      channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      channel!.stream.listen((message) {
        print('Received message: $message');
      }, onError: (error) {
        print('WebSocket Error: $error');
      }, onDone: () {
        print('WebSocket Connection Closed');
      });

      _startLocationUpdates();
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  void _disconnectWebSocket() {
    locationUpdateTimer?.cancel();
    channel?.sink.close();
    channel = null;
    print('WebSocket disconnected');
  }

  void _startLocationUpdates() {
    locationUpdateTimer?.cancel();
    locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      Position position = await Geolocator.getCurrentPosition();
      final data = {
        "user_id": driver?.id,
        "lat": position.latitude,
        "lng": position.longitude
      };
      channel?.sink.add(jsonEncode(data));
    });
  }

  Future<void> fetchDriverData() async {
    try {
      final data = await ApiService.fetchDriver();
      if (!mounted) return;
      setState(() {
        driver = data;
        nameController.text = data.name;
      });
    } catch (e) {
      print('Error fetching driver data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(driver?.profilePictureUrl ?? ''),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo👋',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    driver?.name ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF4678A5),
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: toggleOnlineStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnline ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: Icon(isOnline ? Icons.check_circle : Icons.remove_circle,
                  color: Colors.white),
              label: Text(
                isOnline ? 'Online' : 'Offline',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          const Expanded(child: MapScreen()),
        ],
      ),
    );
  }
}
