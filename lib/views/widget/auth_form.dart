import 'package:flutter/material.dart';

class AuthFormFields {
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isObscure = true,
    VoidCallback? onToggleObscure,
  }) {
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? isObscure : false,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: onToggleObscure,
                  )
                : null,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            errorMaxLines: 2,
          ),
        ),
      ),
    );
  }

  static Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return buildTextField(
      controller: controller,
      label: label,
      icon: Icons.lock,
      validator: validator,
      isPassword: true,
      isObscure: isObscure,
      onToggleObscure: onToggleObscure,
    );
  }
}

class AuthFormEditing {
  static Widget buildForm({
    required String label,
    required TextEditingController controller,
    bool isEditing = false,
  }) {
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          enabled: isEditing,
        ),
      ),
    );
  }
}
