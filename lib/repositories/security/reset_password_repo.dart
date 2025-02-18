import 'package:ridehailing/services/security/reset_password_api.dart';
import 'package:ridehailing/bloc/data.dart';

class ResetPasswordRepository {
  final ResetPasswordService _resetPasswordService = ResetPasswordService();

  Future<Map<String, dynamic>> resetPassword(String email, Driver driver) async {
    return await _resetPasswordService.requestResetPassword(email, driver);
  }
}
