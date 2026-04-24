import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get _defaultBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8081';
    }
    return 'http://localhost:8081';
  }

  static String get baseUrl {
    const value = String.fromEnvironment('API_BASE_URL');
    if (value.isEmpty) return _defaultBaseUrl;
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static const loginEmail = String.fromEnvironment('DUCKHAT_LOGIN_EMAIL');
  static const loginPassword = String.fromEnvironment('DUCKHAT_LOGIN_PASSWORD');
  static const geoapifyApiKey = String.fromEnvironment('GEOAPIFY_API_KEY');

  static bool get hasGeoapifyApiKey => geoapifyApiKey.trim().isNotEmpty;
}
