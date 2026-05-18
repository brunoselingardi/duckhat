import 'package:flutter/material.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/theme.dart';
import 'package:duckhat/pages/service.dart';

class RebookCard extends StatelessWidget {
  final String name;
  final int? prestadorId;
  final String image;
  final double? rating;

  const RebookCard({
    super.key,
    required this.name,
    this.prestadorId,
    required this.image,
    this.rating,
  });

  void _navigateToEstabelecimento(BuildContext context) {
    Navigator.push(
      context,
      AppRoute(builder: (_) => ServicePage(prestadorId: prestadorId ?? 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return GestureDetector(
      onTap: () => _navigateToEstabelecimento(context),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: themeColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeColors.border),
          boxShadow: [
            BoxShadow(
              color: themeColors.shadow.withValues(
                alpha: themeColors.isDark ? 0.30 : 0.18,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: themeColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    if (rating != null) const SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: themeColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 10,
                          color: themeColors.mutedText,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            "Rua Example, 123",
                            style: TextStyle(
                              fontSize: 10,
                              color: themeColors.mutedText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Agendar",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(16),
                    ),
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: themeColors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
