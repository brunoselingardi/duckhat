import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

import 'service_image.dart';

class ServiceGallerySection extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final PageController controller;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenGallery;

  const ServiceGallerySection({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.controller,
    required this.onChanged,
    required this.onSelected,
    required this.onOpenGallery,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Galeria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textBold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma imagem disponível no momento.',
              style: TextStyle(color: AppColors.textRegular),
            ),
          ],
        ),
      );
    }

    final safeSelectedIndex = selectedIndex < images.length ? selectedIndex : 0;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Galeria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textBold,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onOpenGallery,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 1.35,
                  child: _AssetGalleryImage(
                    imagePath: images[safeSelectedIndex],
                    cacheWidth: 1200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: PageView.builder(
                controller: controller,
                onPageChanged: onChanged,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _AssetGalleryImage(
                          imagePath: images[index],
                          cacheWidth: 320,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetGalleryImage extends StatelessWidget {
  final String imagePath;
  final int cacheWidth;

  const _AssetGalleryImage({required this.imagePath, required this.cacheWidth});

  @override
  Widget build(BuildContext context) {
    return ServiceImage(
      source: imagePath,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
    );
  }
}
