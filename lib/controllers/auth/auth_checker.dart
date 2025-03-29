import 'package:flutter/material.dart';
import 'package:ridehailing/models/main/localstorage_models.dart';
import 'package:ridehailing/views/auth/login_view.dart';

class AuthChecker {
  static Future<void> checkLoginStatus(BuildContext context) async {
    String? token = await LocalStorage.getToken();
    int? loginTimestamp = await LocalStorage.getLoginTimestamp();

    if (token == null || loginTimestamp == null) {
      if (!context.mounted) return;
      _navigateToLogin(context);
      return;
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedTime = currentTime - loginTimestamp;

    if (elapsedTime >= 24 * 60 * 60 * 1000) {
      await LocalStorage.clearToken();
      if (!context.mounted) return;
      _navigateToLogin(context);
    }
  }

  static void _navigateToLogin(BuildContext context) {
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
