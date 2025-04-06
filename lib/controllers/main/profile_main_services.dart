import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
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
      throw Exception(responseBody['message'] ?? 'Failed to update driver data');
    }
  }
  
  static Future<void> uploadProfilePicture(File imageFile) async {
    bearerToken = await LocalStorage.getToken();
    
    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/driver/profile_picture'),
    );
    
    // Set authorization header
    request.headers.addAll({
      'Authorization': 'Bearer $bearerToken',
    });
    
    // Determine file extension and mime type
    final fileExtension = extension(imageFile.path).toLowerCase();
    String mimeType;
    
    if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
      mimeType = 'image/jpeg';
    } else if (fileExtension == '.png') {
      mimeType = 'image/png';
    } else {
      mimeType = 'application/octet-stream';
    }
    
    // Add file to request
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture', // This should match the field name expected by your API
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );
    
    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return;
    } else {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(responseBody['message'] ?? 'Failed to upload profile picture');
    }
  }
}