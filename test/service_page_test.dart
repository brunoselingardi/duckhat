import 'package:duckhat/models/estabelecimento_publico.dart';
import 'package:duckhat/models/servico_catalogo.dart';
import 'package:duckhat/pages/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ServicePage renders dynamic establishment data', (
    tester,
  ) async {
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
}
