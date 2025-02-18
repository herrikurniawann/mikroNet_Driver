import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ridehailing/components/localstorage_models.dart';

class ChangePasswordApi {
  final String changePasswordUrl =
      'http://188.166.179.146:8000/api/auth/change-password';

  Future<Map<String, dynamic>> requestChangePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    try {
      final token = await LocalStorage.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak valid. Silakan login kembali.'
        };
      }

      final Uri url = Uri.parse(changePasswordUrl);

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': confirmNewPassword,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          return {'success': true, 'message': decoded['data']};
        } else {
          return {
            'success': false,
            'message': decoded['data'] ?? 'Gagal mengubah password. Coba lagi.'
          };
        }
      } else {
        final decoded = json.decode(response.body);
        return {
          'success': false,
          'message': decoded['message'] ?? 'Gagal mengubah password. Coba lagi.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan pada server.'};
    }
  }
}
