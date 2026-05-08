import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String? _resolvedBaseUrl;

  static String get _defaultBaseUrl {
    return baseUrlCandidates.first;
  }

  static String get baseUrl {
    final resolved = _resolvedBaseUrl;
    if (resolved != null && resolved.isNotEmpty) return resolved;

    final configured = _normalizeNullable(_configuredBaseUrl);
    if (configured != null) return configured;

    return _defaultBaseUrl;
  }

  static List<String> get baseUrlCandidates {
    final configured = _normalizeNullable(_configuredBaseUrl);
    if (configured != null) return [configured];

    final candidates = <String>[
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ...[
        'http://10.0.2.2:8081',
        'http://127.0.0.1:8081',
        'http://localhost:8081',
      ] else ...[
        'http://localhost:8081',
        'http://127.0.0.1:8081',
      ],
    ];

    return candidates.map(_normalize).toSet().toList(growable: false);
  }

  static void useBaseUrl(String value) {
    _resolvedBaseUrl = _normalize(value);
  }

  static void resetResolvedBaseUrl() {
    _resolvedBaseUrl = null;
  }

  static const loginEmail = String.fromEnvironment('DUCKHAT_LOGIN_EMAIL');
  static const loginPassword = String.fromEnvironment('DUCKHAT_LOGIN_PASSWORD');
  static const geoapifyApiKey = String.fromEnvironment('GEOAPIFY_API_KEY');

  static bool get hasGeoapifyApiKey => geoapifyApiKey.trim().isNotEmpty;

  static String? _normalizeNullable(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return _normalize(trimmed);
  }

  static String _normalize(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
