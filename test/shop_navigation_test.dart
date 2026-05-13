import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_main.dart';
import 'package:duckhat/shop_pages/shop_establishment_data.dart';
import 'package:duckhat/shop_pages/shop_home.dart';
import 'package:duckhat/shop_pages/shop_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => DuckHatApi.instance.clearSession());

  testWidgets('shop home no longer shows description and services shortcuts', (
    tester,
  ) async {
    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(const MaterialApp(home: ShopHomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Vitrine do estabelecimento'), findsNothing);
    expect(find.text('Descricao'), findsNothing);
    expect(find.text('Servicos'), findsNothing);
  });

  testWidgets('shop profile tab opens original profile page', (tester) async {
    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(const MaterialApp(home: ShopMainNavigator()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(ShopProfilePage), findsOneWidget);
    expect(find.text('Perfil do estabelecimento'), findsOneWidget);
    expect(find.text('Editar perfil público'), findsOneWidget);
    expect(find.text('Serviços e Preços'), findsNothing);
    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets(
    'shop profile edit public profile action opens establishment data',
    (tester) async {
      DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

      await tester.pumpWidget(const MaterialApp(home: ShopProfilePage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar perfil público'));
      await tester.pumpAndSettle();

      expect(find.byType(ShopEstablishmentDataPage), findsOneWidget);
      expect(find.text('Dados do Estabelecimento'), findsOneWidget);
    },
  );
}
