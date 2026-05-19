import 'package:duckhat/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('signup starts with animated account type choices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    expect(find.text('Escolha como quer entrar'), findsOneWidget);
    expect(find.text('Sou cliente'), findsOneWidget);
    expect(find.text('Sou estabelecimento'), findsOneWidget);
  });

  testWidgets('client signup uses profile photo without banner', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await tester.tap(find.text('Sou cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar foto'), findsOneWidget);
    expect(find.text('Adicionar banner'), findsNothing);
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('client signup does not overflow when keyboard is open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await tester.tap(find.text('Sou cliente'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 500);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Minimo 6 caracteres'),
      '123456',
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Crie seu perfil'), findsOneWidget);
  });

  testWidgets('business signup is split into multiple steps', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await tester.tap(find.text('Sou estabelecimento'));
    await tester.pumpAndSettle();

    expect(find.text('Categoria do estabelecimento'), findsOneWidget);
    expect(find.text('Buscar categoria'), findsOneWidget);
    expect(find.text('Barbearia'), findsOneWidget);

    await tester.tap(find.text('Barbearia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Dados do estabelecimento'), findsOneWidget);
    expect(find.text('Adicionar foto'), findsOneWidget);
    expect(find.text('Adicionar banner'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Adicionar foto')).dy,
      lessThan(tester.getTopLeft(find.text('Adicionar banner')).dy),
    );
    expect(find.text('Nome do estabelecimento'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do estabelecimento'),
      'DuckHat Studio',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Descrição da vitrine'), findsOneWidget);
    expect(find.text('Descrição do estabelecimento'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descrição do estabelecimento'),
      'Atendimento profissional com horario marcado.',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Serviços iniciais'), findsOneWidget);
    expect(find.text('Serviço ativo'), findsOneWidget);
    expect(find.text('Duração e preço'), findsOneWidget);
    expect(find.text('Nome do serviço'), findsOneWidget);
    expect(find.text('Preço'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do serviço'),
      'Corte premium',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descrição do serviço'),
      'Corte completo com finalizacao.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço'),
      '45,00',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Responsavel e contato'), findsOneWidget);
    expect(find.text('CNPJ'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Responsavel'),
      'Ana Duck',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'CNPJ'),
      '12345678000199',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Acesso da empresa'), findsOneWidget);
    expect(find.text('Criar estabelecimento'), findsOneWidget);
  });
}
