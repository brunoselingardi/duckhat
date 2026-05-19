import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

const _transparent = Color(0x00000000);

AppBar buildShopAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
}) {
  final themeColors = AppThemeColors.of(context);

  return AppBar(
    backgroundColor: themeColors.surface,
    surfaceTintColor: _transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.accent),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      title,
      style: TextStyle(
        color: themeColors.primaryText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: themeColors.border),
    ),
  );
}

BoxDecoration buildShopCardDecoration({
  Color color = AppColors.cardBackground,
  double radius = 16,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: borderColor == null ? null : Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadow.withValues(alpha: 0.32),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

BoxDecoration buildShopCardDecorationFor(
  BuildContext context, {
  Color? color,
  double radius = 16,
  Color? borderColor,
}) {
  final themeColors = AppThemeColors.of(context);

  return BoxDecoration(
    color: color ?? themeColors.elevatedSurface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor ?? themeColors.border),
    boxShadow: [
      BoxShadow(
        color: themeColors.shadow.withValues(
          alpha: themeColors.isDark ? 0.34 : 0.18,
        ),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

InputDecoration buildShopInputDecoration({
  required BuildContext context,
  required String hintText,
  Widget? prefixIcon,
}) {
  final themeColors = AppThemeColors.of(context);

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: themeColors.mutedText),
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: themeColors.inputFill,
  );
}
