import 'dart:io';
import 'package:ridehailing/services/auth/register_api.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<bool> registerDriver({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required File profileImage,
  }) async {
    return await _authService.registerDriver(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      profileImage: profileImage,
    );
  }
}
