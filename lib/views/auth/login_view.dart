import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/views/widget/auth_form.dart';
import 'package:ridehailing/views/auth/register_view.dart';
import 'package:ridehailing/views/security/reset_password_view.dart';
import 'package:ridehailing/models/auth/login_models.dart';
import 'package:ridehailing/views/widget/wave_cliper.dart';
import 'package:lottie/lottie.dart'; // Untuk animasi overlay

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginViewModel = context.read<LoginViewModel>();
      loginViewModel.checkLoginStatusAndNavigate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, loginViewModel, _) {
          return Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: true,
                body: Stack(
                  children: [
                    const WaveBackground(height: 250),
                    SizedBox(
                      height: 250,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 250,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 250),
                      child: Material(
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              AuthFormFields.buildTextField(
                                controller: loginViewModel.emailController,
                                label: 'Email',
                                icon: Icons.email,
                              ),
                              AuthFormFields.buildPasswordField(
                                controller: loginViewModel.passwordController,
                                label: 'Password',
                                isObscure: loginViewModel.isObscure,
                                onToggleObscure: () {
                                  loginViewModel.toggleObscure();
                                },
                              ),
                              SizedBox(
                                width: 300,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ResetPasswordView(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Lupa Password',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                height: 60,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ElevatedButton(
                                    onPressed: loginViewModel.isLoading
                                        ? null
                                        : () => loginViewModel.login(context),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                          255, 0x29, 0x45, 0x5F),
                                    ),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Belum punya akun?',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color.fromARGB(
                                            255, 0x29, 0x45, 0x5F),
                                        fontSize: 14.0),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterPage()),
                                      );
                                    },
                                    child: const Text(
                                      'Daftar Sekarang',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color.fromARGB(
                                            255, 0x29, 0x45, 0x5F),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Loading Overlay (Muncul di atas layar saat login berlangsung)
              if (loginViewModel.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Center(
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
