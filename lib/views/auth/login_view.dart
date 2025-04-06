import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/views/auth/register_view.dart';
import 'package:ridehailing/views/security/reset_password_view.dart';
import 'package:ridehailing/models/auth/login_models.dart';
import 'package:ridehailing/views/widget/wave_cliper.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Periksa status login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginViewModel = context.read<LoginViewModel>();
      loginViewModel.checkLoginStatusAndNavigate(context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
                    // Wave background
                    const WaveBackground(height: 250),

                    // Main content with Form
                    SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          // Logo section with animation
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              height: 250,
                              child: Center(
                                child: Hero(
                                  tag: 'app_logo',
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 250,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Form section
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            width: screenSize.width,
                            child: Form(
                              key: loginViewModel.formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Title
                                  const SizedBox(height: 24),

                                  // Email field
                                  buildEmailField(loginViewModel),

                                  const SizedBox(height: 16),

                                  // Password field
                                  buildPasswordField(loginViewModel),

                                  // Remember me checkbox and Forget password link
                                  buildRememberMeAndForgotPassword(
                                      context, loginViewModel),

                                  const SizedBox(height: 24),

                                  // Login button
                                  buildLoginButton(loginViewModel),

                                  const SizedBox(height: 24),

                                  // Register link
                                  buildRegisterLink(context),

                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Loading overlay
              if (loginViewModel.isLoading) buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget buildEmailField(LoginViewModel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      keyboardType: TextInputType.emailAddress,
      validator: viewModel.validateEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'contoh@email.com',
        prefixIcon: const Icon(Icons.email, color: Color(0xFF29455F)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF29455F), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        errorText: viewModel.emailError,
      ),
    );
  }

  Widget buildPasswordField(LoginViewModel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      validator: viewModel.validatePassword,
      obscureText: viewModel.isObscure,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Masukkan password',
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF29455F)),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.isObscure ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF29455F),
          ),
          onPressed: viewModel.toggleObscure,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF29455F), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        errorText: viewModel.passwordError,
      ),
    );
  }

  Widget buildRememberMeAndForgotPassword(
      BuildContext context, LoginViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: viewModel.rememberMe,
                onChanged: (_) => viewModel.toggleRememberMe(),
                activeColor: const Color(0xFF29455F),
              ),
              const Text(
                'Ingat Saya',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),

          // Forgot password link
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordView(),
                ),
              );
            },
            child: const Text(
              'Lupa Password?',
              style: TextStyle(
                color: Color(0xFF29455F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginButton(LoginViewModel viewModel) {
    return ElevatedButton(
      onPressed: viewModel.isLoading ? null : () => viewModel.login(context),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF29455F),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: const Text(
        'MASUK',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text(
            'Daftar Sekarang',
            style: TextStyle(
              color: Color(0xFF29455F),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/loading.json',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
