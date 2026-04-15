import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF291970);
  static const accent = Color(0xFF217CE5);
  static const accentLight = Color(0xFF8EB5F0);
  static const dark = Color(0xFF0F172A);
  static const background = Color(0xFFF0F4F8);
  static const cardBackground = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFCAD6F8);
  static const border = Color(0xFFB3D5FB);
  static const shadowLight = Color(0xFFB3D5FB);
  static const shadowAccent = Color(0xFF443A9C);
  static const splash = Color(0x808EB5F0);
  static const highlight = Color(0xFF8FADF2);
  static const filterSelected = Color(0xFF217CE5);
  static const filterShadow = Color(0xFF443A9C);
  static const cardShadow = Color(0xFFB3D5FB);
  static const lighter = Color(0xFFB3D5FB);
  static const teal = Color(0xFF8FADF2);
  static const purple = Color(0xFF443A9C);
  static const star = Color(0xFFFFC107);
  static const chatBubbleOther = Color(0xFFF0F0F0);
  static const chatBubbleSelf = Color(0xFF217CE5);
  static const divider = Color(0xFFE5E7EB);
  static const inputFill = Color(0xFFF5F5F5);
  static const textMuted = Color(0x99629170);
  static const textSecondary = Color(0xFF291970);
  static const textBold = Color(0xFF291970);
  static const textRegular = Color(0xB3291970);
  static const textMutedLight = Color(0x80291970);
  static const navUnselected = Color(0xB3291970);
  static const blackText = Color(0xFF0C0041);
  static const greenText = Color(0xA60C0041);
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
