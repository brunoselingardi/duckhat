import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const primary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF24315F);
  static const accent = Color(0xFF1F76D2);
  static const accentLight = Color(0xFFD8E8FF);
  static const dark = Color(0xFF111827);
  static const background = Color(0xFFF6F8FC);
  static const backgroundAlt = background;
  static const cardBackground = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFEAF2FF);
  static const border = Color(0xFFD7E3F5);
  static const shadowLight = Color(0xFFB9CAE2);
  static const shadowAccent = Color(0xFF1D4E89);
  static const splash = Color(0x661F76D2);
  static const highlight = Color(0xFFD8E8FF);
  static const filterSelected = accent;
  static const filterShadow = shadowAccent;
  static const cardShadow = Color(0xFFB9CAE2);
  static const lighter = Color(0xFFD8E8FF);
  static const teal = Color(0xFF3DA3D5);
  static const purple = Color(0xFF5A4FCF);
  static const star = Color(0xFFFFC107);
  static const chatBubbleOther = Color(0xFFF1F5F9);
  static const chatBubbleSelf = accent;
  static const divider = Color(0xFFE4EAF3);
  static const inputFill = Color(0xFFF2F6FC);
  static const textMuted = Color(0xFF64748B);
  static const sectionLabel = textMuted;
  static const grayField = textMuted;
  static const textSecondary = Color(0xFF24315F);
  static const textBold = Color(0xFF18223A);
  static const textRegular = Color(0xFF536179);
  static const textMutedLight = textMuted;
  static const navUnselected = Color(0xFF7C8AA1);
  static const blackText = Color(0xFF18223A);
  static const darkAlt = blackText;
  static const greenText = Color(0xFF334155);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get theme => lightTheme;

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.accent,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.cardBackground,
    onSurface: AppColors.textBold,
    surfaceContainerHighest: AppColors.inputFill,
    outline: AppColors.border,
    shadow: AppColors.cardShadow,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8EC5FF),
    onPrimary: Color(0xFF081525),
    secondary: Color(0xFFB7C8FF),
    onSecondary: Color(0xFF101726),
    error: Color(0xFFFF8A8A),
    onError: Color(0xFF2A0707),
    surface: Color(0xFF101827),
    onSurface: Color(0xFFE8EEF8),
    surfaceContainerHighest: Color(0xFF172337),
    outline: Color(0xFF31425C),
    shadow: Color(0xFF020617),
  );

  static ThemeData get lightTheme => _buildTheme(
    scheme: _lightScheme,
    background: AppColors.background,
    surface: AppColors.cardBackground,
    elevatedSurface: AppColors.cardBackground,
    primaryText: AppColors.textBold,
    secondaryText: AppColors.textRegular,
    mutedText: AppColors.textMuted,
    border: AppColors.border,
    navUnselected: AppColors.navUnselected,
    inputFill: AppColors.inputFill,
    shadow: AppColors.cardShadow,
  );

  static ThemeData get darkTheme => _buildTheme(
    scheme: _darkScheme,
    background: const Color(0xFF0B1220),
    surface: const Color(0xFF101827),
    elevatedSurface: const Color(0xFF172337),
    primaryText: const Color(0xFFE8EEF8),
    secondaryText: const Color(0xFFB8C5D8),
    mutedText: const Color(0xFF94A3B8),
    border: const Color(0xFF31425C),
    navUnselected: const Color(0xFF93A4BA),
    inputFill: const Color(0xFF172337),
    shadow: const Color(0xFF020617),
  );

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color background,
    required Color surface,
    required Color elevatedSurface,
    required Color primaryText,
    required Color secondaryText,
    required Color mutedText,
    required Color border,
    required Color navUnselected,
    required Color inputFill,
    required Color shadow,
  }) {
    final textTheme = Typography.material2021().black.apply(
      fontFamily: 'Poppins',
      bodyColor: primaryText,
      displayColor: primaryText,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      fontFamily: 'Poppins',
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: scheme.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: navUnselected,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : navUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? scheme.primary : navUnselected,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: TextStyle(color: mutedText, fontWeight: FontWeight.w600),
        labelStyle: TextStyle(color: mutedText, fontWeight: FontWeight.w600),
        prefixIconColor: scheme.primary,
        suffixIconColor: mutedText,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: border.withValues(alpha: 0.7)),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: surface,
        iconColor: scheme.primary,
        textColor: primaryText,
        subtitleTextStyle: TextStyle(color: mutedText, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevatedSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
        contentTextStyle: TextStyle(
          color: secondaryText,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.brightness == Brightness.dark
            ? elevatedSurface
            : const Color(0xFF18223A),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.brightness == Brightness.dark
              ? const Color(0xFF93A4BA)
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary.withValues(alpha: 0.36);
          }
          return scheme.brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE4EAF3);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: inputFill,
        selectedColor: scheme.primary.withValues(alpha: 0.16),
        disabledColor: inputFill.withValues(alpha: 0.6),
        side: BorderSide(color: border),
        labelStyle: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
        secondaryLabelStyle: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeColors._(
          isDark: scheme.brightness == Brightness.dark,
          background: background,
          surface: surface,
          elevatedSurface: elevatedSurface,
          primaryText: primaryText,
          secondaryText: secondaryText,
          mutedText: mutedText,
          border: border,
          shadow: shadow,
          navUnselected: navUnselected,
          inputFill: inputFill,
          accent: scheme.primary,
          onAccent: scheme.onPrimary,
          accentSoft: scheme.primary.withValues(alpha: 0.13),
          heroStart: scheme.brightness == Brightness.dark
              ? const Color(0xFF16213A)
              : AppColors.secondary,
          heroEnd: scheme.brightness == Brightness.dark
              ? const Color(0xFF1F76D2)
              : AppColors.accent,
          successSurface: AppColors.success.withValues(alpha: 0.12),
          warningSurface: AppColors.warning.withValues(alpha: 0.13),
          errorSurface: scheme.error.withValues(alpha: 0.12),
          imagePlaceholder: scheme.brightness == Brightness.dark
              ? const Color(0xFF1B2738)
              : const Color(0xFFF2F6FC),
        ),
      ],
      useMaterial3: true,
    );
  }
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

class AppThemeColors extends ThemeExtension<AppThemeColors> {
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
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color heroStart;
  final Color heroEnd;
  final Color successSurface;
  final Color warningSurface;
  final Color errorSurface;
  final Color imagePlaceholder;

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
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.heroStart,
    required this.heroEnd,
    required this.successSurface,
    required this.warningSurface,
    required this.errorSurface,
    required this.imagePlaceholder,
  });

  factory AppThemeColors.of(BuildContext context) {
    final extension = Theme.of(context).extension<AppThemeColors>();
    if (extension != null) return extension;

    final colorScheme = Theme.of(context).colorScheme;
    if (colorScheme.brightness == Brightness.light) {
      return AppThemeColors._(
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
        accent: AppColors.accent,
        onAccent: Colors.white,
        accentSoft: AppColors.accent.withValues(alpha: 0.13),
        heroStart: AppColors.secondary,
        heroEnd: AppColors.accent,
        successSurface: AppColors.success.withValues(alpha: 0.12),
        warningSurface: AppColors.warning.withValues(alpha: 0.13),
        errorSurface: AppColors.error.withValues(alpha: 0.12),
        imagePlaceholder: const Color(0xFFF2F6FC),
      );
    }

    return AppThemeColors._(
      isDark: true,
      background: Color(0xFF0B1220),
      surface: Color(0xFF101827),
      elevatedSurface: Color(0xFF172337),
      primaryText: Color(0xFFE8EEF8),
      secondaryText: Color(0xFFB8C5D8),
      mutedText: Color(0xFF94A3B8),
      border: Color(0xFF31425C),
      shadow: Color(0xFF020617),
      navUnselected: Color(0xFF93A4BA),
      inputFill: Color(0xFF172337),
      accent: Color(0xFF8EC5FF),
      onAccent: Color(0xFF081525),
      accentSoft: Color(0x218EC5FF),
      heroStart: Color(0xFF16213A),
      heroEnd: Color(0xFF1F76D2),
      successSurface: Color(0x1F22C55E),
      warningSurface: Color(0x21F59E0B),
      errorSurface: Color(0x1FFF8A8A),
      imagePlaceholder: Color(0xFF1B2738),
    );
  }

  @override
  AppThemeColors copyWith({
    bool? isDark,
    Color? background,
    Color? surface,
    Color? elevatedSurface,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? border,
    Color? shadow,
    Color? navUnselected,
    Color? inputFill,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? heroStart,
    Color? heroEnd,
    Color? successSurface,
    Color? warningSurface,
    Color? errorSurface,
    Color? imagePlaceholder,
  }) {
    return AppThemeColors._(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      navUnselected: navUnselected ?? this.navUnselected,
      inputFill: inputFill ?? this.inputFill,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      successSurface: successSurface ?? this.successSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      errorSurface: errorSurface ?? this.errorSurface,
      imagePlaceholder: imagePlaceholder ?? this.imagePlaceholder,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors._(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      imagePlaceholder: Color.lerp(
        imagePlaceholder,
        other.imagePlaceholder,
        t,
      )!,
    );
  }
}
