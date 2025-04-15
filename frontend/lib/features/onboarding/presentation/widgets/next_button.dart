// lib/widgets/next_button.dart
import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners with a radius of 12
        ),
        padding: const EdgeInsets.all(10),
        backgroundColor: const Color(0xFF00826C),
      ),
      child: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
    );
  }
}