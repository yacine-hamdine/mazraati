// lib/widgets/page_indicator.dart
import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Smooth animation
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: currentPage == index ? 24.0 : 8.0, // Long shape when selected
          height: 8.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0), // Rounded corners
            color: currentPage == index ? Color(0xFF00826C) : Color(0xFFE6EAFF),
          ),
        ),
      ),
    );
  }
}