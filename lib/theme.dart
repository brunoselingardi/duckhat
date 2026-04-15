import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF2F4987);
  static const accent = Color(0xFF3A7FD5);
  static const accentLight = Color(0xFF8EB5F0);
  static const dark = Color(0xFF0F172A);
  static const textSecondary = Color(0xCC2F4987);
  static const textMuted = Color(0xFF64748B);
  static const background = Color(0xFFFBFCFE);
  static const cardBackground = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFF2F8FF);
  static const border = Color(0xFFE5E7EB);
  static const shadowLight = Color(0x803A7FD5);
  static const shadowAccent = Color(0x66A2D7EC);
  static const splash = Color(0x4D8EB5F0);
  static const highlight = Color(0x268EB5F0);
  static const filterSelected = Color(0xFF6497ED);
  static const filterShadow = Color(0x600334A7);
  static const cardShadow = Color(0x6680C2F8);
  static const darkAlt = Color(0xFF0C0041);
  static const grayField = Color(0xFF6B7280);
  static const backgroundAlt = Color(0xFFF0F4F8);
  static const chatBackground = Color(0xFFFAFBFC);
  static const messageOther = Color(0xFFF0F0F0);
  static const inputField = Color(0xFFF5F5F5);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      secondary: AppColors.secondary,
      surface: AppColors.cardBackground,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
  );
}
