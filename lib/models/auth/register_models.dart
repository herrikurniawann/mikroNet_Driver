import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridehailing/views/auth/login_view.dart';
import 'package:ridehailing/controllers/auth/register_api.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  bool isObscure = true;
  File? profileImage;
  String? errorMessage;

  void togglePasswordVisibility() {
    isObscure = !isObscure;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage = File(image.path);
      notifyListeners();
    }
  }

  Future<void> register(BuildContext context) async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        !emailController.text.contains('@') ||
        passwordController.text.length < 6 ||
        passwordController.text != passwordConfirmationController.text ||
        profileImage == null) {
      errorMessage = 'Harap isi semua data dengan benar';
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendaftar. Harap isi semua data dengan benar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _authService.registerDriver(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      passwordConfirmation: passwordConfirmationController.text,
      profileImage: profileImage!,
    );

    if (success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daftar Berhasil Silahkan Menunggu Validasi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendaftar. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
