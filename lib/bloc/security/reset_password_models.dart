import 'package:flutter/material.dart';
import 'package:ridehailing/repositories/security/reset_password_repo.dart';
import 'package:ridehailing/bloc/data.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final ResetPasswordRepository _repository = ResetPasswordRepository();
  final TextEditingController emailController = TextEditingController();
  Driver? _driver;

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setDriver(Driver driver) {
    _driver = driver;
    notifyListeners();
  }

  Future<void> resetPassword(BuildContext context) async {
    final String email = emailController.text.trim();
    if (email.isEmpty) {
      _errorMessage = 'Email tidak boleh kosong';
      notifyListeners();
      if (context.mounted) {
        showSnackBar(context, _errorMessage, Colors.red);
      }
      return;
    }

    if (_driver == null) {
      _errorMessage = 'Data pengguna tidak ditemukan';
      notifyListeners();
      if (context.mounted) {
        showSnackBar(context, _errorMessage, Colors.red);
      }
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    if (context.mounted) {
      showSnackBar(context, 'Memproses permintaan reset password...', Colors.blue);
    }

    try {
      final result = await _repository.resetPassword(email, _driver!);
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        if (result['success']) {
          showSnackBar(context, 'Sukses: ${result['message']}', Colors.green);
          emailController.clear();
        } else {
          _errorMessage = result['message'] ?? 'Gagal mereset password';
          notifyListeners();
          showSnackBar(context, _errorMessage, Colors.red);
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      if (context.mounted) {
        showSnackBar(context, _errorMessage, Colors.red);
      }
    }
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
