import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ridehailing/models/main/trip_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripHistoryService {
  static const String baseUrl = 'http://188.166.179.146:8000/api';
  
  static Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }
  
  static Future<List<TripHistory>> getTripHistory() async {
    try {
      final url = Uri.parse('$baseUrl/driver/trips');
      final token = await getAuthToken();
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> tripsJson = responseData['data'] ?? [];
        
        return tripsJson
            .map<TripHistory>((json) => TripHistory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load trip history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching trip history: $e');
    }
  }
}