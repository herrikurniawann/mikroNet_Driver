import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ridehailing/components/localstorage_models.dart';

class DriverStatusService {
  static const String baseUrl = 'http://188.166.179.146:8000/api/driver/status';

  static Future<bool> getDriverStatus() async {
    final token = await LocalStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data']['status'] == 'on';
    } else {
      throw Exception('Gagal mendapatkan status driver');
    }
  }

  static Future<bool> updateDriverStatus(bool isOnline) async {
    final token = await LocalStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.put(
      Uri.parse('http://188.166.179.146:8000/api/driver/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': isOnline ? 'on' : 'off'}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data']['status'] == 'on';
    } else {
      throw Exception('Gagal memperbarui status driver');
    }
  }
}
