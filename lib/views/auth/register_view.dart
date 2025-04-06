import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/views/auth/login_view.dart';
import 'package:ridehailing/views/widget/auth_form.dart';
import 'package:ridehailing/views/widget/wave_cliper.dart';
import 'package:ridehailing/models/auth/register_models.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                const WaveBackground(height: 150),
                model.isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Mendaftarkan akun Anda...',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 80,
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildProfileImagePicker(model),
                              const SizedBox(height: 16),
                              Form(
                                key: model.formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  children: [
                                    AuthFormFields.buildTextField(
                                      controller: model.nameController,
                                      label: 'Nama Lengkap',
                                      icon: Icons.person,
                                      validator: model.validateName,
                                    ),
                                    AuthFormFields.buildTextField(
                                      controller: model.emailController,
                                      label: 'Email',
                                      icon: Icons.email,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: model.validateEmail,
                                    ),
                                    AuthFormFields.buildTextField(
                                      controller: model.phoneController,
                                      label: 'Nomor Telepon',
                                      icon: Icons.phone,
                                      keyboardType: TextInputType.phone,
                                      validator: model.validatePhone,
                                    ),
                                    AuthFormFields.buildTextField(
                                      controller: model.licenseNumberController,
                                      label: 'Nomor Lisensi',
                                      icon: Icons.badge,
                                      validator: model.validateLicense,
                                    ),
                                    AuthFormFields.buildTextField(
                                      controller: model.simController,
                                      label: 'Nomor SIM',
                                      icon: Icons.credit_card,
                                      keyboardType: TextInputType.number,
                                      validator: model.validateSIM,
                                    ),
                                    AuthFormFields.buildPasswordField(
                                      controller: model.passwordController,
                                      label: 'Password',
                                      isObscure: model.isObscure,
                                      onToggleObscure:
                                          model.togglePasswordVisibility,
                                      validator: model.validatePassword,
                                    ),
                                    AuthFormFields.buildPasswordField(
                                      controller:
                                          model.passwordConfirmationController,
                                      label: 'Konfirmasi Password',
                                      isObscure: model.isConfirmObscure,
                                      onToggleObscure:
                                          model.toggleConfirmPasswordVisibility,
                                      validator: model.validateConfirmPassword,
                                    ),
                                    _buildKtpUploadButton(model),
                                    _buildRegisterButton(context, model),
                                    const SizedBox(height: 10),
                                    _buildLoginLink(context),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImagePicker(RegisterViewModel model) {
    return Column(
      children: [
        GestureDetector(
          onTap: model.pickProfileImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: model.profileImage != null
                    ? FileImage(model.profileImage!)
                    : null,
                child: model.profileImage == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF29455F),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          model.profileImage == null
              ? 'Tambahkan Foto Profil'
              : 'Foto Profil Terpilih',
          style: TextStyle(
            color: model.profileImage == null ? Colors.grey : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKtpUploadButton(RegisterViewModel model) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Unggah Foto KTP',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton.icon(
            onPressed: model.pickKtpImage,
            icon: const Icon(Icons.upload_file),
            label: Text(
              model.ktpImage == null ? 'Pilih File KTP' : 'KTP Terpilih',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: model.ktpImage == null
                  ? const Color(0xFF29455F)
                  : Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (model.ktpImage != null)
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                'File KTP berhasil diunggah',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, RegisterViewModel model) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () => model.register(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: const Color(0xFF29455F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
        child: const Text(
          'Daftar Sekarang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah punya akun?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: const Text(
            'Masuk',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Color(0xFF29455F),
            ),
          ),
        ),
      ],
    );
  }
}
