import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark mode hotspots use theme-aware surface tokens', () {
    final files = {
      'lib/components/user/editar_perfil.dart': [
        'color: AppColors.cardBackground',
        'fillColor: AppColors.cardBackground',
      ],
      'lib/components/user/notificacoes.dart': [
        '? AppColors.cardBackground',
        'color: AppColors.cardBackground',
      ],
      'lib/pages/signup.dart': ['fillColor: Colors.white'],
      'lib/shop_pages/shop_schedule.dart': [
        'color: AppColors.cardBackground',
        'color: AppColors.inputBackground',
      ],
    };

    for (final entry in files.entries) {
      final source = File(entry.key).readAsStringSync();
      for (final forbidden in entry.value) {
        expect(
          source.contains(forbidden),
          isFalse,
          reason: '${entry.key} still contains `$forbidden`',
        );
      }
    }
  });
}
