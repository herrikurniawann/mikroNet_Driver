import 'package:flutter/material.dart';

class FormFieldWithLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType keyboardType;

  const FormFieldWithLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.controller,
    required this.isEditing,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    // Debug print to verify isEditing state
    debugPrint('FormFieldWithLabel: $label isEditing=$isEditing');
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              if (isEditing)
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14),
                )
              else
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        ),
      ],
    );
  }
}