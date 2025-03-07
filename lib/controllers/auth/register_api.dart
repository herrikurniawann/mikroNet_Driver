import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://188.166.179.146:8000/api/auth';

  Future<bool> registerDriver({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required File profileImage,
  }) async {
    final url = Uri.parse('$_baseUrl/register/driver');
    final request = http.MultipartRequest('POST', url);

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['password_confirmation'] = passwordConfirmation;
    request.files.add(
      await http.MultipartFile.fromPath('profile_picture', profileImage.path),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}