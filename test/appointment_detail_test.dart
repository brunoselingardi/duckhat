import 'package:duckhat/models/agendamento.dart';
import 'package:duckhat/pages/appointment_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Agendamento _agendamento({String status = 'CONFIRMADO'}) {
  return Agendamento(
    id: 42,
    clienteId: 7,
    clienteNome: 'Cliente Duck',
    prestadorId: 12,
    prestadorNome: 'DuckHat Studio',
    servicoId: 3,
    servicoNome: 'Corte completo',
    inicioEm: DateTime(2026, 5, 6, 14),
    fimEm: DateTime(2026, 5, 6, 15),
    status: status,
    observacoes: 'Preferencia por tesoura.',
    criadoEm: DateTime(2026, 5, 1, 9),
  );
}

void main() {
  testWidgets('appointment detail exposes complete action when available', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppointmentDetailPage(
          agendamento: _agendamento(),
          onComplete: (agendamento) async {
            completed = agendamento.id == 42;
          },
        ),
      ),
    );

    expect(find.text('Concluir atendimento'), findsOneWidget);

    await tester.tap(find.text('Concluir'));
    await tester.pump();

    expect(completed, isTrue);
  });
}
