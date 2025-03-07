import 'package:flutter/material.dart';
import 'package:ridehailing/views/auth/login_view.dart';
import 'package:ridehailing/views/widget/wave_cliper.dart';
import 'package:ridehailing/views/widget/auth_form.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/models/auth/register_models.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                const WaveBackground(height: 200),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: model.pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: model.profileImage != null
                              ? FileImage(model.profileImage!)
                              : null,
                          child: model.profileImage == null
                              ? const Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              AuthFormFields.buildTextField(
                                  controller: model.nameController,
                                  label: 'Nama Lengkap',
                                  icon: Icons.person),
                              AuthFormFields.buildTextField(
                                controller: model.emailController,
                                label: 'Email',
                                icon: Icons.email,
                              ),
                              AuthFormFields.buildPasswordField(
                                controller: model.passwordController,
                                label: 'Password',
                                isObscure: model.isObscure,
                                onToggleObscure: model.togglePasswordVisibility,
                              ),
                              AuthFormFields.buildPasswordField(
                                controller:
                                    model.passwordConfirmationController,
                                label: 'Konfirmasi Password',
                                isObscure: model.isObscure,
                                onToggleObscure: model.togglePasswordVisibility,
                              ),
                              SizedBox(
                                width: 300,
                                height: 60,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await model.register(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                          255, 0x29, 0x45, 0x5F),
                                    ),
                                    child: const Text(
                                      'Daftar',
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
                                    'Sudah punya akun?',
                                    style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 0x29, 0x45, 0x5F),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()),
                                      );
                                    },
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 0x29, 0x45, 0x5F),
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
