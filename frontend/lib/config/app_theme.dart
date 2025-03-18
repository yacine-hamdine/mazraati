import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF6AB187), // Adjust to your brand color
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF6AB187),
      secondary: const Color(0xFFECECEC),
    ),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto', // Or your custom font
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6AB187),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
  );
}
