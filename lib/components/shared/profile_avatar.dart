import 'dart:convert';

import 'package:duckhat/theme.dart' show AppThemeColors;
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imageBase64;
  final double size;
  final double? borderRadius;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.imageBase64,
    this.size = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);
    final radius = borderRadius ?? size / 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: themeColors.accentSoft,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(themeColors),
    );
  }

  Widget _buildContent(AppThemeColors themeColors) {
    final value = imageBase64?.trim();
    if (value != null && value.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(value),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } on FormatException {
        return _Initial(name: name, size: size);
      }
    }

    return _Initial(name: name, size: size);
  }
}

class _Initial extends StatelessWidget {
  final String name;
  final double size;

  const _Initial({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);
    final normalizedName = name.trim();
    final initial = normalizedName.isEmpty
        ? '?'
        : normalizedName[0].toUpperCase();

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: themeColors.accent,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
