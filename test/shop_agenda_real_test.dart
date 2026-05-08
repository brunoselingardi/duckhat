import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_pages/shop_home.dart';
import 'package:duckhat/shop_pages/shop_schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => DuckHatApi.instance.clearSession());

  testWidgets('shop home no longer renders static appointment clients', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(const MaterialApp(home: ShopHomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Agendamentos de hoje'), findsOneWidget);
    expect(find.text('Nenhum agendamento hoje'), findsOneWidget);
    expect(find.text('João Silva'), findsNothing);
    expect(find.text('Pedro Santos'), findsNothing);
  });

  testWidgets(
    'shop schedule uses provider agenda states instead of mock slots',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

      await tester.pumpWidget(const MaterialApp(home: ShopSchedulePage()));
      await tester.pumpAndSettle();

      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Nenhum cliente agendado nesta data'), findsOneWidget);
      expect(find.text('Bloquear'), findsNothing);
      expect(find.text('Disponível'), findsNothing);
      expect(find.text('João Silva'), findsNothing);
    },
  );
}
