import 'package:flutter/material.dart';
import 'package:ridehailing/models/main/localstorage_models.dart';
import 'package:ridehailing/views/main/main_view.dart';
import 'package:ridehailing/controllers/auth/login_api.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  bool get isLoading => _isLoading;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get isObscure => _isObscure;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password harus diisi')),
      );
      return;
    }

    setLoading(true);
    try {
      final result = await _authService.login(email, password);

      if (!context.mounted) return;

      if (result['success'] == true) {
        final token = result['access_token'];

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token tidak diterima. Silakan coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
          setLoading(false);
          return;
        }

        await LocalStorage.saveToken(token);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        // 🔹 Navigasi ke halaman utama
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? 'Gagal login. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setLoading(false);
    }
  }

  Future<bool> checkLoginStatus() async {
    String? token = await LocalStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  void checkLoginStatusAndNavigate(BuildContext context) async {
    bool isLoggedIn = await checkLoginStatus();
    if (isLoggedIn && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainView()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
