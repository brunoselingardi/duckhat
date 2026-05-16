import 'dart:convert';

import 'package:flutter/material.dart';

class ServiceImage extends StatelessWidget {
  final String? source;
  final String? base64Source;
  final BoxFit fit;
  final int? cacheWidth;
  final FilterQuality filterQuality;

  const ServiceImage({
    super.key,
    required this.source,
    this.base64Source,
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
    final base64Value = _normalizeBase64(base64Source);
    if (base64Value != null && base64Value.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(base64Value),
          fit: fit,
          cacheWidth: cacheWidth,
          filterQuality: filterQuality,
          gaplessPlayback: true,
        );
      } on FormatException {
        return _brokenImage();
      }
    }

    final value = source?.trim();
    if (value == null || value.isEmpty) {
      return _emptyImage();
    }

    if (isRemote(value)) {
      return Image.network(
        value,
        fit: fit,
        cacheWidth: cacheWidth,
        filterQuality: filterQuality,
        errorBuilder: (_, _, _) => _brokenImage(),
      );
    }

    return Image.asset(
      value,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: filterQuality,
      errorBuilder: (_, _, _) => _brokenImage(),
    );
  }

  static String? _normalizeBase64(String? source) {
    final value = source?.trim();
    if (value == null || value.isEmpty) return null;
    final commaIndex = value.indexOf(',');
    if (value.startsWith('data:image') && commaIndex >= 0) {
      return value.substring(commaIndex + 1);
    }
    return value;
  }

  static Widget _emptyImage() {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFF2F4F7)),
      child: Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF98A2B3), size: 32),
      ),
    );
  }

  static Widget _brokenImage() {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFF2F4F7)),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Color(0xFF98A2B3),
          size: 32,
        ),
      ),
    );
  }
}
