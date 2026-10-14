import 'package:flutter/material.dart';

class AppColors {
  // Biru primer diambil dari tombol pada desain (35, 91, 198).
  static const primary = Color(0xFF235BC6);
  static const primaryDark = Color(0xFF1B4AA3);
  static const ink = Color(0xFF101E33);
  static const body = Color(0xFF5B6B82);
  static const hint = Color(0xFF9AA5B8);
  static const line = Color(0xFFD5DDE8);
  static const page = Color(0xFFF1F5F9);
  static const card = Colors.white;
  static const softBlue = Color(0xFFE8EFFC);
  static const softBlueText = Color(0xFF235BC6);
  static const softRed = Color(0xFFFDECEC);
  static const red = Color(0xFFD64545);
  static const fieldFill = Colors.white;
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.page,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}
