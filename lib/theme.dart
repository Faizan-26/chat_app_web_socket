import 'package:flutter/material.dart';

class AppTheme {
  // Define common colors for consistency
  static const Color _lightPrimaryColor = Color(0xFFF5F5DC); // Beige
  static const Color _darkPrimaryColor = Color(0xFF121212); // Dark Background
  static const Color _lightAccentColor = Color(0xFF87CEEB); // Soft Blue
  static const Color _darkAccentColor = Colors.blueAccent; // Blue Accent
  static const Color _lightTextColor = Color(0xFF333333); // Dark Gray
  static const Color _darkTextColor = Colors.white; // White
  static const Color _lightSecondaryTextColor =
      Color(0xFF666666); // Medium Gray
  static const Color _darkSecondaryTextColor = Colors.grey; // Gray

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _lightPrimaryColor,
      scaffoldBackgroundColor: const Color(0xFFFFF9F6), // Off-White
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimaryColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: _lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: _lightAccentColor),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFDAB9), // Peach
        foregroundColor: _lightTextColor,
        elevation: 6,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFFF9F6), // Off-White
        labelStyle: TextStyle(color: _lightTextColor),
        hintStyle: TextStyle(color: _lightSecondaryTextColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFDAB9), width: 2.0), // Peach
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD3D3D3)), // Light Gray
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF87CEEB), // Soft Blue
          foregroundColor: Colors.white, // White text
          shadowColor: const Color(0xFF87CEEB).withOpacity(0.5),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded edges
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFDAB9), // Peach
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _lightTextColor), // Dark Gray
        bodySmall: TextStyle(color: _lightSecondaryTextColor), // Medium Gray
      ),
      iconTheme: const IconThemeData(color: _lightAccentColor), // Soft Blue
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _darkPrimaryColor,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Slightly lighter Dark
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkPrimaryColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: _darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: _darkAccentColor),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkAccentColor,
        foregroundColor: _darkTextColor,
        elevation: 6,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E), // Slightly lighter Dark
        labelStyle: TextStyle(color: _darkTextColor),
        hintStyle: TextStyle(color: _darkSecondaryTextColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkAccentColor, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF333333)), // Dark Gray
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent, // Blue Accent
          foregroundColor: Colors.white, // White text
          shadowColor: Colors.blueAccent.withOpacity(0.5),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded edges
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blueAccent, // Blue Accent
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _darkTextColor), // White
        bodySmall: TextStyle(color: _darkSecondaryTextColor), // Gray
      ),
      iconTheme: const IconThemeData(color: _darkAccentColor), // Blue Accent
    );
  }
}
