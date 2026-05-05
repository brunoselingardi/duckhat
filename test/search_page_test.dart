import 'package:duckhat/pages/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SearchPage renders improved search experience', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SearchPage()));

    expect(find.text('NO LOCAL'), findsOneWidget);
    expect(find.text('EM DOMICÍLIO'), findsOneWidget);
    expect(find.text('Encontre serviços ou estabelecimentos'), findsOneWidget);
    expect(find.text('Encontre por bairro, cidade ou CEP'), findsOneWidget);
    expect(find.text('SUGESTÕES'), findsOneWidget);
    expect(find.text('Barbeiro'), findsOneWidget);
    expect(find.text('Cabeleireiro'), findsOneWidget);
  });
}
