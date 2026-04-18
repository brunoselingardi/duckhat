class ApiConfig {
  static const _defaultBaseUrl = 'http://localhost:8081';

  static String get baseUrl {
    const value = String.fromEnvironment('API_BASE_URL');
    if (value.isEmpty) return _defaultBaseUrl;
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static const loginEmail = String.fromEnvironment('DUCKHAT_LOGIN_EMAIL');
  static const loginPassword = String.fromEnvironment('DUCKHAT_LOGIN_PASSWORD');
}
