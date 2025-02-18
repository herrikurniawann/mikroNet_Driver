import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/components/auth_form.dart';
import 'package:ridehailing/components/background.dart';
import 'package:ridehailing/view/auth/register_view.dart';
import 'package:ridehailing/bloc/auth/login_models.dart';
import 'package:ridehailing/view/security/reset_password_view.dart';

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
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: BackgroundWidget(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                    ),
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Form(
                        child: Column(
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ElevatedButton(
                                  onPressed: loginViewModel.isLoading
                                      ? null
                                      : () => loginViewModel.login(context),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: loginViewModel.isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                          'Masuk',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 300,
                              child: Divider(
                                color: Colors.white,
                                thickness: 1,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Belum punya akun?',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14.0),
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
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
