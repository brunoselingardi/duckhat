import 'package:duckhat/core/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    ApiConfig.resetResolvedBaseUrl();
  });

  test('android default tries emulator and physical device reverse URLs', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(
      ApiConfig.baseUrlCandidates,
      containsAllInOrder([
        'http://10.0.2.2:8081',
        'http://127.0.0.1:8081',
        'http://localhost:8081',
      ]),
    );
  });

  test('resolved base URL is normalized and reused', () {
    ApiConfig.useBaseUrl('http://127.0.0.1:8081/');

    expect(ApiConfig.baseUrl, 'http://127.0.0.1:8081');
  });
}
