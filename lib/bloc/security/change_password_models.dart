import 'package:flutter/material.dart';
import 'package:ridehailing/services/security/change_password_api.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isObscure => _isObscure;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  Future<void> changePassword(BuildContext context) async {
    final String oldPassword = oldPasswordController.text.trim();
    final String newPassword = newPasswordController.text.trim();
    final String confirmNewPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      _errorMessage = 'Semua field harus diisi';
      notifyListeners();
      if (context.mounted) {
        showSnackBar(context, _errorMessage, Colors.red);
      }
      return;
    }

    if (newPassword != confirmNewPassword) {
      _errorMessage = 'Password baru dan konfirmasi password tidak cocok';
      notifyListeners();
      if (context.mounted) {
        showSnackBar(context, _errorMessage, Colors.red);
      }
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await ChangePasswordApi().requestChangePassword(
        oldPassword,
        newPassword,
        confirmNewPassword,
      );

      _isLoading = false;
      notifyListeners();

      if (!context.mounted) return;

      if (result['success']) {
        showSnackBar(context, 'Password berhasil diubah!', Colors.green);
        clearFields();
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengubah password.';
        notifyListeners();
        showSnackBar(context, _errorMessage, Colors.red);
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

  void clearFields() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
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
