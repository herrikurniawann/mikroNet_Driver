import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/models/security/change_password_models.dart';
import 'package:ridehailing/views/widget/auth_form.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Change Password'),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/reset-password.png', width: 150),
                    const SizedBox(height: 10),
                    const SizedBox(
                      width: 290,
                      child: Text(
                        'Silakan masukkan password lama Anda, lalu buat password baru yang kuat',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthFormFields.buildPasswordField(
                      controller: viewModel.oldPasswordController,
                      label: 'Password Lama',
                      isObscure: viewModel.isObscure,
                      onToggleObscure: viewModel.toggleObscure,
                    ),
                    const SizedBox(height: 10),
                    AuthFormFields.buildPasswordField(
                      controller: viewModel.newPasswordController,
                      label: 'Password Baru',
                      isObscure: viewModel.isObscure,
                      onToggleObscure: viewModel.toggleObscure,
                    ),
                    const SizedBox(height: 10),
                    AuthFormFields.buildPasswordField(
                      controller: viewModel.confirmPasswordController,
                      label: 'Konfirmasi Password',
                      isObscure: viewModel.isObscure,
                      onToggleObscure: viewModel.toggleObscure,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 285,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => viewModel.changePassword(context),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: const Color(0xFF4678A5),
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
