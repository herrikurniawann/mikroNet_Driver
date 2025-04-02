import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridehailing/views/widget/maps.dart';
import 'package:ridehailing/controllers/main/driver_services.dart';
import 'package:ridehailing/controllers/main/profile_main_services.dart';
import 'package:ridehailing/models/main/data.dart';
import 'package:ridehailing/views/main/profile_view.dart';
import 'package:ridehailing/views/widget/route_item.dart';
import 'package:ridehailing/controllers/main/websocket.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Driver? driver;
  bool isOnline = false;
  final TextEditingController nameController = TextEditingController();
  LatLng? driverPosition;
  WebSocketService? _webSocketService;

  @override
  void initState() {
    super.initState();
    fetchDriverData();
    fetchDriverStatus();
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    super.dispose();
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
      return;
    }
  }

  Future<void> toggleOnlineStatus() async {
    try {
      bool newStatus = await DriverStatusService.updateDriverStatus(!isOnline);
      if (!mounted) return;
      setState(() {
        isOnline = newStatus;
        if (!isOnline) {
          driverPosition = null;
        }
      });
      _manageWebSocket();
    } catch (e) {
      return;
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
    if (driver == null) return;

    LatLng? lastPosition = await _webSocketService?.getCachedDriverLocation();
    if (lastPosition != null) {
      setState(() {
        driverPosition = lastPosition;
      });
    }

    _webSocketService = WebSocketService(
      onLocationUpdated: (position) {
        if (!mounted) return;
        setState(() {
          driverPosition = position;
        });
      },
      onDisconnected: () {
        if (!mounted) return;
        setState(() {
          driverPosition = null;
        });
      },
    );

    _webSocketService!.connect(driver!.id);
  }

  void _disconnectWebSocket() {
    _webSocketService?.disconnect();
    _webSocketService = null;
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
      return;
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
                backgroundImage: driver?.profilePictureUrl != null &&
                        driver!.profilePictureUrl.isNotEmpty
                    ? NetworkImage(driver!.profilePictureUrl)
                    : const AssetImage('assets/images/default.jpg')
                        as ImageProvider,
                child: driver?.profilePictureUrl == null ||
                        driver!.profilePictureUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    driver?.name ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0x29, 0x45, 0x5F),
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.all(1.0),
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
      body: Column(
        children: [
          Expanded(
            child: MapScreen(
              driverId: driver?.id,
              driverPosition: driverPosition,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rute Yang Tersedia:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildRouteItem('JL. R.W. Monginsidi - Zero Point'),
                        buildRouteItem('Zero Point - Jl. Sam Ratulangi'),
                        buildRouteItem(
                            'Jl. Sam Ratulangi - Jl. R.W Monginsidi'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
