class TripHistory {
  final int id;
  final String passengerName;
  final String driverName;
  final int amount;
  final DateTime createdAt;

  TripHistory({
    required this.id,
    required this.passengerName,
    required this.driverName,
    required this.amount,
    required this.createdAt,
  });

  factory TripHistory.fromJson(Map<String, dynamic> json) {
    return TripHistory(
      id: json['id'],
      passengerName: json['passenger_name'] ?? '',
      driverName: json['driver_name'] ?? '',
      amount: json['amount'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}