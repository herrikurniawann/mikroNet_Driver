import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/models/security/change_password_models.dart';
import 'package:ridehailing/views/widget/auth_form.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: SvgPicture.asset(
                'assets/svg/logo_ride.svg',
                height: 40,
                width: 30,
              ),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/bg_pw_2.png', width: 250),
                    const SizedBox(height: 10),
                    const SizedBox(
                      width: 290,
                      child: Text(
                        'Masukkan password lama Anda, lalu buat password baru yang kuat',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AuthFormFields.buildPasswordField(
                      controller: viewModel.oldPasswordController,
                      label: 'Password Lama',
                      isObscure: viewModel.isObscure,
                      onToggleObscure: viewModel.toggleObscure,
                    ),
                    AuthFormFields.buildPasswordField(
                      controller: viewModel.newPasswordController,
                      label: 'Password Baru',
                      isObscure: viewModel.isObscure,
                      onToggleObscure: viewModel.toggleObscure,
                    ),
                    AuthFormFields.buildPasswordField(
                      controller: viewModel.confirmPasswordController,
                      label: 'Konfirmasi Password',
                      isObscure: viewModel.isObscure,
                      onToggleObscure: viewModel.toggleObscure,
                    ),
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => viewModel.changePassword(context),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 0x29, 0x45, 0x5F),
                          ),
                          child: viewModel.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
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
