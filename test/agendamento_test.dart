import 'package:duckhat/models/agendamento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses provider profile image from appointment payload', () {
    final agendamento = Agendamento.fromJson({
      'id': 1,
      'clienteId': 7,
      'clienteNome': 'Cliente',
      'prestadorId': 2,
      'prestadorNome': 'DuckHat Studio',
      'prestadorFotoPerfilBase64': 'logo-base64',
      'servicoId': 10,
      'servicoNome': 'Corte social',
      'inicioEm': '2026-05-15T10:00:00',
      'fimEm': '2026-05-15T10:45:00',
      'status': 'PENDENTE',
      'observacoes': null,
      'criadoEm': '2026-05-15T09:00:00',
    });

    expect(agendamento.prestadorId, 2);
    expect(agendamento.prestadorFotoPerfilBase64, 'logo-base64');
  });
}
