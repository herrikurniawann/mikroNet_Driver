import 'package:ridehailing/services/auth/login_api.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _authService.login(email, password);
  }
}
