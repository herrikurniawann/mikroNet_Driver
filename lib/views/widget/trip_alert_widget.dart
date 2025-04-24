import 'package:flutter/material.dart';
import 'package:ridehailing/models/main/trip_history.dart';
import 'package:ridehailing/controllers/main/trip_alert_services.dart';
import 'package:ridehailing/views/main/trip_history_view.dart';

class TripAlertWidget extends StatelessWidget {
  final TripHistory trip;
  final VoidCallback onDismiss;

  const TripAlertWidget({
    super.key,
    required this.trip,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 8,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0x29, 0x45, 0x5F)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pembayaran Baru',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              children: [
                const TextSpan(text: 'Penumpang '),
                TextSpan(
                  text: trip.passengerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
                  ),
                ),
                const TextSpan(text: ' telah naik dan membayar sejumlah '),
                TextSpan(
                  text: TripAlertService.formatAmount(trip.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 0x29, 0x45, 0x5F),
          ),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: () {
            onDismiss();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TripHistoryView(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0x29, 0x45, 0x5F),
            foregroundColor: Colors.white,
          ),
          child: const Text('Lihat Riwayat'),
        ),
      ],
    );
  }
}
