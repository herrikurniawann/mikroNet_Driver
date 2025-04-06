import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridehailing/views/widget/maps.dart';
import 'package:ridehailing/controllers/main/driver_services.dart';
import 'package:ridehailing/controllers/main/profile_main_services.dart';
import 'package:ridehailing/models/main/data.dart';
import 'package:ridehailing/views/main/profile_view.dart';
import 'package:ridehailing/views/main/trip_history_view.dart';
import 'package:ridehailing/controllers/main/websocket.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  Driver? driver;
  bool isOnline = false;
  final TextEditingController nameController = TextEditingController();
  LatLng? driverPosition;
  WebSocketService? _webSocketService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    fetchDriverData();
    fetchDriverStatus();
    _animationController.forward();
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchDriverStatus() async {
    try {
      bool status = await DriverStatusService.getDriverStatus();
      if (!mounted) return;
      setState(() {
        isOnline = status;
        isLoading = false;
      });
      _manageWebSocket();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  Future<void> toggleOnlineStatus() async {
    setState(() {
      isLoading = true;
    });
    try {
      bool newStatus = await DriverStatusService.updateDriverStatus(!isOnline);
      if (!mounted) return;
      setState(() {
        isOnline = newStatus;
        isLoading = false;
        if (!isOnline) {
          driverPosition = null;
        }
      });
      _manageWebSocket();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    const primaryColor = Color.fromARGB(255, 0x29, 0x45, 0x5F);

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
              Hero(
                tag: 'profilePicture',
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(22),
                  child: CircleAvatar(
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
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    driver?.name ?? 'Driver',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                // Trip History Icon Button
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  tooltip: 'Riwayat Perjalanan',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TripHistoryView(),
                      ),
                    );
                  },
                ),
                // Online/Offline Button
                ElevatedButton.icon(
                  onPressed: isLoading ? null : toggleOnlineStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOnline ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    elevation: 4,
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          isOnline
                              ? Icons.check_circle
                              : Icons.power_settings_new,
                          color: Colors.white,
                          size: 18,
                        ),
                  label: Text(
                    isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      MapScreen(
                        driverId: driver?.id,
                        driverPosition: driverPosition,
                      ),
                      if (isOnline)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.green.withValues(alpha: 0.9),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Anda sedang online dan siap menerima penumpang',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Rute Yang Tersedia:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
                              ),
                              onPressed: () {
                                // Refresh routes logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Memperbarui rute'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 130,
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            children: [
                              _buildRouteCard(
                                  'JL. R.W. Monginsidi - Zero Point'),
                              _buildRouteCard('Zero Point - Jl. Sam Ratulangi'),
                              _buildRouteCard(
                                  'Jl. Sam Ratulangi - Jl. R.W Monginsidi'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRouteCard(String title) {
    return SizedBox(
      height: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
