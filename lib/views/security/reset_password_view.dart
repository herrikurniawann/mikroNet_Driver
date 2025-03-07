import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/models/security/reset_password_models.dart';
import 'package:ridehailing/views/widget/auth_form.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(),
      child: Consumer<ResetPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Reset Password'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/password-strenght.png',
                      width: 150),
                  const SizedBox(height: 10),
                  const SizedBox(
                    width: 290,
                    child: Text(
                      'Masukkan alamat email Anda untuk menerima tautan reset password.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: AuthFormFields.buildTextField(
                      controller: viewModel.emailController,
                      label: 'Email',
                      icon: Icons.email,
                    ),
                  ),
                  SizedBox(
                    width: 290,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => viewModel.resetPassword(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: const Color(0xFF4678A5),
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Reset Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
