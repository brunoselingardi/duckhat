import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const primary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF291970);
  static const accent = Color(0xFF217CE5);
  static const accentLight = Color(0xFF8EB5F0);
  static const dark = Color(0xFF0F172A);
  static const background = Color(0xFFF0F4F8);
  static const backgroundAlt = background;
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
  static const textMuted = Color(0x803A7FD5);
  static const sectionLabel = textMuted;
  static const grayField = textMuted;
  static const textSecondary = Color(0xFF291970);
  static const textBold = Color(0xFF291970);
  static const textRegular = Color(0xB3291970);
  static const textMutedLight = textMuted;
  static const navUnselected = Color(0xB3291970);
  static const blackText = Color(0xFF0C0041);
  static const darkAlt = blackText;
  static const greenText = Color(0xA60C0041);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get theme => lightTheme;

  static ThemeData get lightTheme => ThemeData(
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      secondary: AppColors.secondary,
      surface: AppColors.cardBackground,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.cardBackground,
    dividerColor: AppColors.divider,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.secondary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.navUnselected,
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return const Color(0xFFFFFFFF);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent.withValues(alpha: 0.32);
        }
        return const Color(0xFFE5E7EB);
      }),
    ),
    useMaterial3: true,
  );

  static ThemeData get darkTheme => ThemeData(
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      primary: const Color(0xFF7DB4F5),
      secondary: const Color(0xFFB7C8FF),
      surface: const Color(0xFF111827),
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1220),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111827),
      foregroundColor: Color(0xFF7DB4F5),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: const Color(0xFF111827),
    dividerColor: const Color(0xFF263244),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF111827),
      selectedItemColor: Color(0xFF7DB4F5),
      unselectedItemColor: Color(0xFF94A3B8),
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF7DB4F5);
        }
        return const Color(0xFF94A3B8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF3A7FD5).withValues(alpha: 0.45);
        }
        return const Color(0xFF334155);
      }),
    ),
    useMaterial3: true,
  );
}

class AppThemeController {
  static const _storageKey = 'duckhat_theme_mode';
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);
  static bool _initialized = false;

  static bool get isDark => mode.value == ThemeMode.dark;

  static Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_storageKey);
    mode.value = savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _initialized = true;
  }

  static Future<void> setDark(bool value) async {
    final nextMode = value ? ThemeMode.dark : ThemeMode.light;
    if (mode.value == nextMode) return;
    mode.value = nextMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, value ? 'dark' : 'light');
  }

  @visibleForTesting
  static void resetForTests({ThemeMode value = ThemeMode.light}) {
    mode.value = value;
    _initialized = false;
  }
}

class AppThemeColors {
  final bool isDark;
  final Color background;
  final Color surface;
  final Color elevatedSurface;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color border;
  final Color shadow;
  final Color navUnselected;
  final Color inputFill;

  const AppThemeColors._({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.border,
    required this.shadow,
    required this.navUnselected,
    required this.inputFill,
  });

  factory AppThemeColors.of(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    if (!isDark) {
      return const AppThemeColors._(
        isDark: false,
        background: AppColors.background,
        surface: AppColors.cardBackground,
        elevatedSurface: AppColors.cardBackground,
        primaryText: AppColors.textBold,
        secondaryText: AppColors.textRegular,
        mutedText: AppColors.textMuted,
        border: AppColors.border,
        shadow: AppColors.cardShadow,
        navUnselected: AppColors.navUnselected,
        inputFill: AppColors.cardBackground,
      );
    }

    return const AppThemeColors._(
      isDark: true,
      background: Color(0xFF0B1220),
      surface: Color(0xFF111827),
      elevatedSurface: Color(0xFF172033),
      primaryText: Color(0xFFE5EDF8),
      secondaryText: Color(0xFFB8C5D8),
      mutedText: Color(0xFF94A3B8),
      border: Color(0xFF2B3A52),
      shadow: Color(0xFF020617),
      navUnselected: Color(0xFF94A3B8),
      inputFill: Color(0xFF172033),
    );
  }
}
