import 'package:ridehailing/controllers/security/reset_password_api.dart';
import 'package:ridehailing/models/data.dart';

class ResetPasswordRepository {
  final ResetPasswordService _resetPasswordService = ResetPasswordService();

  Future<Map<String, dynamic>> resetPassword(String email, Driver driver) async {
    return await _resetPasswordService.requestResetPassword(email);
  }
}
