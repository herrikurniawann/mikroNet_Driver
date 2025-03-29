import 'package:flutter/material.dart';
import 'package:ridehailing/models/main/localstorage_models.dart';
import 'package:ridehailing/views/auth/login_view.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: ElevatedButton(
        onPressed: () async {
          await LocalStorage.clearToken();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Keluar',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
