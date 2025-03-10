import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ridehailing/models/main/localstorage_models.dart';
import 'package:ridehailing/models/main/data.dart';

class ApiService {
  static const String baseUrl = 'http://188.166.179.146:8000/api';
  static String? bearerToken;

  static Future<Driver> fetchDriver() async {
    String? bearerToken = await LocalStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/driver/'),
      headers: {'Authorization': 'Bearer $bearerToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return Driver.fromJson(responseBody['data']);
    } else {
      throw Exception('Failed to load driver data');
    }
  }

  static Future<void> updateDriver(Map<String, String> updatedData) async {
    bearerToken = await LocalStorage.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/driver/'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(
          responseBody['message'] ?? 'Failed to update driver data');
    }
  }
}
