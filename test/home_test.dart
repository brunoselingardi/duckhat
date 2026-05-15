import 'package:duckhat/components/home/header.dart';
import 'package:duckhat/components/home/rebookcard.dart';
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

  testWidgets('home shows only real saved favorites', (tester) async {
    DuckHatApi.instance.startDevSession(tipo: 'CLIENTE');

    await tester.pumpWidget(const MaterialApp(home: Home()));
    await tester.pumpAndSettle();

    expect(find.text('Seus favoritos:'), findsOneWidget);
    expect(find.text('Seus favoritos salvos aparecerão aqui.'), findsOneWidget);
    expect(
      find.text(
        'Seus favoritos aparecerão aqui conforme você usar mais os mesmos estabelecimentos.',
      ),
      findsNothing,
    );
  });

  testWidgets('home header uses the canonical logo asset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeHeader()));

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as AssetImage;

    expect(provider.assetName, 'assets/logologo.png');
  });

  testWidgets('favorite card shows rating average without review count', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RebookCard(
            name: 'Jorje Encanamentos',
            prestadorId: 13,
            image: 'assets/logologo.png',
            rating: 4.5,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(2)'), findsNothing);
    expect(find.text('(0)'), findsNothing);
  });
}
