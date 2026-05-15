import 'package:duckhat/pages/home.dart';
import 'package:duckhat/pages/search.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => DuckHatApi.instance.clearSession());

  testWidgets('home banner points to search without promotions CTA', (
    tester,
  ) async {
    DuckHatApi.instance.startDevSession(tipo: 'CLIENTE');

    await tester.pumpWidget(const MaterialApp(home: Home()));
    await tester.pumpAndSettle();

    expect(find.text('Encontre os\nmelhores serviços'), findsOneWidget);
    expect(find.text('Ver promoções'), findsNothing);

    await tester.tap(find.text('Encontre os\nmelhores serviços'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchPage), findsOneWidget);
  });
}
