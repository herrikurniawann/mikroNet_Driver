import 'package:flutter/material.dart';

class AuthFormFields {
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: onToggleObscure,
                  )
                : null,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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
  }) {
    return buildTextField(
      controller: controller,
      label: label,
      icon: Icons.lock,
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
