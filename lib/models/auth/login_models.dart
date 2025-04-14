import 'package:flutter/material.dart';
import 'package:ridehailing/models/main/localstorage_models.dart';
import 'package:ridehailing/views/main/main_view.dart';
import 'package:ridehailing/controllers/auth/login_api.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  String? _emailError;
  String? _passwordError;

  bool get isLoading => _isLoading;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get isObscure => _isObscure;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  void resetForm() {
    formKey = GlobalKey<FormState>();

    _emailController.clear();
    _passwordController.clear();
    _emailError = null;
    _passwordError = null;
    _isObscure = true;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Validasi untuk password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    return null;
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }

  // Tampilkan dialog pesan
  void showMessage(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? 'Berhasil' : 'Perhatian'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    // Validasi form sebelum login
    if (formKey.currentState?.validate() != true) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setLoading(true);
    try {
      final result = await _authService.login(email, password);
      if (!context.mounted) return;

      if (result['success'] == true) {
        final token = result['access_token'];
        if (token == null) {
          showMessage(
              context, 'Token tidak diterima. Silakan coba lagi.', false);
          setLoading(false);
          return;
        }

        // Simpan token
        await LocalStorage.saveToken(token);

        if (!context.mounted) return;

        // Navigasi ke halaman utama
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!context.mounted) return;
        showMessage(context,
            result['message'] ?? 'Gagal login. Silakan coba lagi.', false);
      }
    } catch (e) {
      if (!context.mounted) return;
      showMessage(context, 'Terjadi kesalahan: $e', false);
    } finally {
      setLoading(false);
    }
  }

  Future<bool> checkLoginStatus() async {
    String? token = await LocalStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  void checkLoginStatusAndNavigate(BuildContext context) async {
    // Cek apakah pengguna sudah login
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
