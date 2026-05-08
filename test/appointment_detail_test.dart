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
  testWidgets('appointment detail exposes cancel action when available', (
    tester,
  ) async {
    var cancelled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppointmentDetailPage(
          agendamento: _agendamento(),
          onCancel: (agendamento) async {
            cancelled = agendamento.id == 42;
          },
        ),
      ),
    );

    expect(find.text('Cancelar agendamento'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(cancelled, isTrue);
  });
}
