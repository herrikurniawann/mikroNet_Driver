import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordService {
  final String resetPasswordUrl =
      'http://188.166.179.146:8000/api/auth/reset-password';

  Future<Map<String, dynamic>> requestResetPassword(String email) async {
    try {
      final Uri url = Uri.parse(resetPasswordUrl);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('status') &&
            responseData['status'] == 'success') {
          return {
            'success': true,
            'message': responseData['message'],
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'Permintaan gagal. Coba lagi.',
          };
        }
      } else {
        return {'success': false, 'message': 'Permintaan gagal. Coba lagi.'};
      }
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan pada server.'};
    }
  }
}
