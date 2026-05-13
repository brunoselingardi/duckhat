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
    expect(find.text('Painel da vitrine'), findsOneWidget);
    expect(find.text('Serviços ativos'), findsOneWidget);
    expect(find.text('Serviços pausados'), findsOneWidget);
    expect(find.text('Informações do serviço'), findsWidgets);
    expect(find.text('Agenda e preço'), findsWidgets);
    expect(find.text('Salvar alterações'), findsOneWidget);
    expect(find.text('Corte de cabelo'), findsWidgets);
    expect(find.text('Ativo na vitrine'), findsWidgets);
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets('scrolls to the new service after adding it', (tester) async {
    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(const MaterialApp(home: ShopServiceDurationPage()));
    await tester.pumpAndSettle();

    final scrollable = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .where((state) => state.position.axis == Axis.vertical)
        .firstWhere((state) => state.position.maxScrollExtent > 0);
    expect(scrollable.position.pixels, 0);

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Novo serviço'), findsWidgets);
    expect(scrollable.position.pixels, greaterThan(0));

    final newServiceNameField = find
        .widgetWithText(TextFormField, 'Nome do serviço')
        .last;
    final editableText = tester.widget<EditableText>(
      find.descendant(
        of: newServiceNameField,
        matching: find.byType(EditableText),
      ),
    );
    expect(editableText.focusNode.hasFocus, isTrue);
  });

  testWidgets('paused service cards collapse editing fields', (tester) async {
    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(const MaterialApp(home: ShopServiceDurationPage()));
    await tester.pumpAndSettle();

    const firstCardKey = ValueKey('service-card-0');
    final expandedHeight = tester.getSize(find.byKey(firstCardKey)).height;
    expect(find.text('Informações do serviço'), findsOneWidget);
    expect(find.text('Agenda e preço'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Pausado'), findsOneWidget);
    final collapsedHeight = tester.getSize(find.byKey(firstCardKey)).height;
    expect(collapsedHeight, lessThan(expandedHeight * 0.65));
    expect(
      find.text('Serviço pausado: reative para editar detalhes.'),
      findsOneWidget,
    );
  });

  testWidgets('service editor fits on narrow phones', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(const MaterialApp(home: ShopServiceDurationPage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Painel da vitrine'), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);
  });
}
