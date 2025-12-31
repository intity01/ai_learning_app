import 'package:flutter/material.dart';

class AppTheme {
  static final LinearGradient gradientPurpleBlue = LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient gradientGreenBlue = LinearGradient(
    colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient gradientPinkRed = LinearGradient(
    colors: [Color(0xFFF7971E), Color(0xFFFF6A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
  );
}