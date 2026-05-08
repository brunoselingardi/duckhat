import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_pages/shop_service_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => DuckHatApi.instance.clearSession());

  testWidgets('shop service editor loads editable services in dev session', (
    tester,
  ) async {
    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(const MaterialApp(home: ShopServiceDurationPage()));
    await tester.pumpAndSettle();

    expect(find.text('Serviços e Preços'), findsOneWidget);
    expect(find.text('Vitrine de serviços'), findsOneWidget);
    expect(find.text('Corte de cabelo'), findsOneWidget);
    expect(find.text('Serviço 1'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });
}
