import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_pages/shop_establishment_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => DuckHatApi.instance.clearSession());

  testWidgets('salva alteracoes do estabelecimento no modo dev local', (
    tester,
  ) async {
    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(
      const MaterialApp(home: ShopEstablishmentDataPage()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do estabelecimento'),
      'DuckHat Studio Atualizado',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Endereço'),
      'Av. Central, 100',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Horário de atendimento'),
      'Segunda a sexta 8h - 18h',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descrição para clientes'),
      'Atendimento atualizado para clientes.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telefone'),
      '62999998888',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'studio@duckhat.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'CNPJ'),
      '11222333000144',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Responsavel'),
      'Ana Responsavel',
    );

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final session = DuckHatApi.instance.currentSession;
    expect(session?.nome, 'DuckHat Studio Atualizado');
    expect(session?.telefone, '62999998888');
    expect(session?.cnpj, '11222333000144');
    expect(session?.responsavelNome, 'Ana Responsavel');
    expect(session?.endereco, 'Av. Central, 100');
    expect(session?.descricao, 'Atendimento atualizado para clientes.');
    expect(session?.horarioAtendimento, 'Segunda a sexta 8h - 18h');
  });
}
