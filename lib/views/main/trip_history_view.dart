import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ridehailing/controllers/main/trip_history_services.dart';
import 'package:ridehailing/models/main/trip_history.dart';

class TripHistoryView extends StatefulWidget {
  const TripHistoryView({super.key});

  @override
  State<TripHistoryView> createState() => _TripHistoryViewState();
}

class _TripHistoryViewState extends State<TripHistoryView>
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool isLoading = true;
  List<TripHistory> tripHistory = [];
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _fetchTripHistory();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTripHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await TripHistoryService.getTripHistory();
      if (mounted) {
        setState(() {
          tripHistory = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Gagal memuat riwayat perjalanan';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0x29, 0x45, 0x5F);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Perjalanan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
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
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTripHistory,
        color: primaryColor,
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.shade100,
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (errorMessage != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchTripHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            else if (tripHistory.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_transfer,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat perjalanan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Perjalanan Anda akan muncul di sini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Trip History List
              FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tripHistory.length + 1, // +1 for the header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Header with summary
                      return _buildSummaryCard();
                    }
                    final trip = tripHistory[index - 1];
                    return _buildTripCard(trip);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (tripHistory.isEmpty) return const SizedBox.shrink();

    // Calculate total earnings
    final totalEarnings = tripHistory.fold(0, (sum, trip) => sum + trip.amount);
    final totalTrips = tripHistory.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 0x29, 0x45, 0x5F),
              const Color.fromARGB(255, 0x29, 0x45, 0x5F)
                  .withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Perjalanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Pendapatan',
                    currencyFormat.format(totalEarnings),
                    Icons.monetization_on,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Jumlah Perjalanan',
                    totalTrips.toString(),
                    Icons.directions_car,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(TripHistory trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0x29, 0x45, 0x5F)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Perjalanan #${trip.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (trip.passengerName.isNotEmpty)
              _buildInfoRow('Penumpang', trip.passengerName, Icons.person),
            _buildInfoRow('Total Tarif', currencyFormat.format(trip.amount),
                Icons.attach_money),
            _buildInfoRow(
                'Tanggal', _formatDate(trip.createdAt), Icons.calendar_today),
            _buildInfoRow(
                'Waktu', _formatTime(trip.createdAt), Icons.access_time),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy', 'id');
    return formatter.format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm', 'id');
    return formatter.format(dateTime);
  }
}
