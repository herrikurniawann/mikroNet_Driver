import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ridehailing/bloc/data.dart';

class ResetPasswordService {
  final String baseUrl = 'http://188.166.179.146:8000/api/auth/reset-password';

  Future<Map<String, dynamic>> requestResetPassword(String email, Driver driver) async {
    try {
      final Uri url = Uri.parse('$baseUrl/${driver.id}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? 'Gagal mendapatkan response'
        };
      } else {
        return {'success': false, 'message': 'Permintaan gagal. Coba lagi.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan pada server.'};
    }
  }
}
