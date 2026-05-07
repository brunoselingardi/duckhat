import 'package:flutter/material.dart';

class ServiceImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;
  final int? cacheWidth;
  final FilterQuality filterQuality;

  const ServiceImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.filterQuality = FilterQuality.medium,
  });

  static bool isRemote(String? source) {
    if (source == null) return false;
    return source.startsWith('http://') || source.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final value = source?.trim();
    if (value == null || value.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFF2F4F7)),
        child: Center(
          child: Icon(Icons.image_outlined, color: Color(0xFF98A2B3), size: 32),
        ),
      );
    }

    if (isRemote(value)) {
      return Image.network(
        value,
        fit: fit,
        cacheWidth: cacheWidth,
        filterQuality: filterQuality,
        errorBuilder: (_, _, _) => const DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFFF2F4F7)),
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF98A2B3),
              size: 32,
            ),
          ),
        ),
      );
    }

    return Image.asset(
      value,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: filterQuality,
      errorBuilder: (_, _, _) => const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFF2F4F7)),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF98A2B3),
            size: 32,
          ),
        ),
      ),
    );
  }
}
