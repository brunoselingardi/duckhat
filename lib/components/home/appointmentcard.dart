import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class AppointmentCard extends StatelessWidget {
  final String time;
  final String service;
  final String place;
  final String? image;
  final String? imageBase64;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.time,
    required this.service,
    required this.place,
    this.image,
    this.imageBase64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeColors.border),
            boxShadow: [
              BoxShadow(
                color: themeColors.shadow.withValues(
                  alpha: themeColors.isDark ? 0.30 : 0.18,
                ),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              _AppointmentImage(image: image, imageBase64: imageBase64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            place,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: themeColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service,
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColors.mutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: themeColors.mutedText,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            "Detalhes e local do atendimento",
                            style: TextStyle(
                              fontSize: 11,
                              color: themeColors.mutedText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentImage extends StatelessWidget {
  final String? image;
  final String? imageBase64;

  const _AppointmentImage({required this.image, required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    Widget child;
    final value = imageBase64?.trim();
    if (value != null && value.isNotEmpty) {
      try {
        child = Image.memory(
          base64Decode(value),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } on FormatException {
        child = _fallbackImage();
      }
    } else {
      child = _fallbackImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: 52, height: 52, child: child),
    );
  }

  Widget _fallbackImage() {
    final value = image?.trim();
    if (value == null || value.isEmpty) {
      return Container(
        color: AppColors.accent.withValues(alpha: 0.10),
        child: const Icon(Icons.storefront, color: AppColors.accent),
      );
    }
    return Image.asset(value, fit: BoxFit.cover);
  }
}
