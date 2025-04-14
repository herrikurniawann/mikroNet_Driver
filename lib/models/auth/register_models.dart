import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridehailing/controllers/auth/register_api.dart';
import 'package:ridehailing/views/auth/login_view.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController simController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  bool isObscure = true;
  bool isConfirmObscure = true;
  File? profileImage;
  File? ktpImage;
  bool isLoading = false;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
      if (value.length < 7) {
      return 'Nama minimal 7 karakter';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email tidak valid, harus menggunakan @';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (value.length < 10 || value.length > 13) {
      return 'Nomor telepon harus 10-13 digit';
    }
    return null;
  }

  String? validateLicense(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor lisensi tidak boleh kosong';
    }
    return null;
  }

  String? validateSIM(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor SIM tidak boleh kosong';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor SIM hanya boleh berisi angka';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 simbol';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf kapital';
    }
    return null;
  }

  // Validasi konfirmasi password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  void togglePasswordVisibility() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmObscure = !isConfirmObscure;
    notifyListeners();
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage = File(image.path);
      notifyListeners();
    }
  }

  Future<void> pickKtpImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ktpImage = File(image.path);
      notifyListeners();
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perhatian'),
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

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      showErrorDialog(context, 'Mohon periksa kembali form registrasi Anda.');
      return;
    }

    if (profileImage == null) {
      showErrorDialog(context, 'Foto profil harus diunggah.');
      return;
    }

    if (ktpImage == null) {
      showErrorDialog(context, 'Foto KTP harus diunggah.');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.registerDriver(
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        licenseNumber: licenseNumberController.text,
        sim: simController.text,
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
        profileImage: profileImage!,
        ktpImage: ktpImage!,
      );

      isLoading = false;
      notifyListeners();

      if (!context.mounted) return;

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Pendaftaran Berhasil'),
            content: const Text(
                'Pendaftaran berhasil! Silakan tunggu validasi dari admin. Anda akan diarahkan ke halaman login.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showErrorDialog(context, 'Gagal mendaftar. Silakan coba lagi.');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      if (!context.mounted) return;
      showErrorDialog(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }
}
