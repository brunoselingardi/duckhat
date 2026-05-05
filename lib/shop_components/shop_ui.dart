import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

const _transparent = Color(0x00000000);

AppBar buildShopAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: AppColors.cardBackground,
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
      style: const TextStyle(
        color: AppColors.textBold,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
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

InputDecoration buildShopInputDecoration({
  required String hintText,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.grayField),
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: AppColors.cardBackground,
  );
}
