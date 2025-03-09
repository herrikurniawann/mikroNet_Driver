import 'package:flutter/material.dart';

class FormFieldWithLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final TextEditingController controller;
  final bool isEditing;

  const FormFieldWithLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: isEditing
                  ? TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Masukkan $label',
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}