import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ridehailing/controllers/main/trip_history_services.dart';
import 'package:ridehailing/models/main/trip_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripAlertService {
  static const String _lastTripIdKey = 'last_trip_id';
  static Timer? _checkTimer;
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static void startMonitoring(Function(TripHistory) onNewTrip) async {
    stopMonitoring();
    
    await _checkForNewTrips(onNewTrip);
    
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _checkForNewTrips(onNewTrip);
    });
  }

  static void stopMonitoring() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  static Future<void> _checkForNewTrips(Function(TripHistory) onNewTrip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastKnownTripId = prefs.getInt(_lastTripIdKey) ?? 0;
      
      final trips = await TripHistoryService.getTripHistory();
      
      if (trips.isEmpty) return;
      
      trips.sort((a, b) => b.id.compareTo(a.id));
      
      final newestTripId = trips.first.id;
      
      if (lastKnownTripId > 0 && newestTripId > lastKnownTripId) {
        final newTrips = trips.where((trip) => trip.id > lastKnownTripId).toList();
        
        for (var trip in newTrips) {
          onNewTrip(trip);
        }
      }
      
      await prefs.setInt(_lastTripIdKey, newestTripId);
    } catch (e) {
      debugPrint('Error checking for new trips: $e');
    }
  }

  static String formatAmount(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}