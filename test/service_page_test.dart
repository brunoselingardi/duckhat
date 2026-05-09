import 'package:duckhat/models/estabelecimento_catalogo.dart';
import 'package:duckhat/models/estabelecimento_publico.dart';
import 'package:duckhat/models/servico_catalogo.dart';
import 'package:duckhat/pages/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ServicePage renders dynamic establishment data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ServicePage(
          prestadorId: 2,
          profileLoader: (_) async => const EstabelecimentoPublico(
            id: 2,
            nome: 'DuckHat Studio',
            telefone: '62999990000',
            endereco: 'Av. Central, 100',
            descricaoPublica: 'Cortes e cuidados para todos os estilos.',
            horarioAtendimento: 'Segunda a sexta 9h - 20h',
            imagemCapa: 'assets/barbie.jpg',
            imagemLogo: 'assets/barbielogo.jpg',
          ),
          servicesLoader: (_) async => [
            ServicoCatalogo(
              id: 10,
              prestadorId: 2,
              nome: 'Corte social',
              descricao: 'Acabamento completo.',
              duracaoMin: 45,
              preco: 39.9,
              ativo: true,
            ),
          ],
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('DuckHat Studio'), findsOneWidget);
    expect(find.text('Av. Central, 100'), findsOneWidget);
    expect(find.text('Corte social'), findsOneWidget);
    expect(find.text('Barbie Dream Barber'), findsNothing);
  });

  testWidgets('ServicePage renders catalog establishment as reusable template', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ServicePage(
          prestadorId: 13,
          estabelecimento: EstabelecimentoCatalogo(
            prestadorId: 13,
            nome: 'Jorje Encanamentos',
            telefone: '62999990013',
            endereco: 'Rua dos Canos, 45 - Setor Oeste',
            categoria: 'encanador',
            categoriaLabel: 'Encanador',
            descricao:
                'Atendimento rapido para vazamentos, pias, ralos e manutencao hidraulica.',
            horarioAtendimento: 'Segunda a sabado 7h - 19h',
            bannerImagemBase64: null,
            totalServicos: 1,
            precoInicial: 90,
            servicos: [
              ServicoCatalogo(
                id: 5,
                prestadorId: 13,
                nome: 'Visita tecnica de encanador',
                descricao: 'Diagnostico inicial para canos e vazamentos.',
                duracaoMin: 45,
                preco: 90,
                ativo: true,
              ),
            ],
          ),
          profileLoader: (_) async => throw Exception('offline no teste'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Jorje Encanamentos'), findsOneWidget);
    expect(find.text('Rua dos Canos, 45 - Setor Oeste'), findsOneWidget);
    expect(find.text('Segunda a sabado 7h - 19h'), findsOneWidget);
    expect(find.text('Visita tecnica de encanador'), findsOneWidget);
    expect(find.text('Serviços e preços'), findsOneWidget);
    expect(find.text('Nenhuma avaliação publicada ainda.'), findsOneWidget);
    expect(find.text('Nenhuma pergunta frequente cadastrada.'), findsOneWidget);
    expect(find.text('Barbie Dream Barber'), findsNothing);
    expect(find.text('Mostrar mais detalhes'), findsNothing);
  });
}
