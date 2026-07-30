import 'package:flutter/material.dart';

class MbgTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool showIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const MbgTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.showIcon = true,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: (showIcon && icon != null) ? Icon(icon, size: 20) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}