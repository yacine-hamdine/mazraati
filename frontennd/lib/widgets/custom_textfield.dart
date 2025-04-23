import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType; // <-- Fix: use TextInputType

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.onSuffixTap,
    this.controller,
    this.suffixIcon,
    this.validator,
    this.keyboardType, // <-- Fix: add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType, // <-- Fix: set here
      style: const TextStyle(
        color: Color(0xFF00826C),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFB6C2C9),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F8F7),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD6E3E2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00826C), width: 2),
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: suffixIcon,
              )
            : null,
      ),
    );
  }
}