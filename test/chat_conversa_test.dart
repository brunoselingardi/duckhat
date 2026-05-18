import 'package:duckhat/models/chat_conversa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses participant establishment profile image', () {
    final conversa = ChatConversa.fromJson({
      'id': 10,
      'clienteId': 1,
      'clienteNome': 'Cliente',
      'prestadorId': 2,
      'prestadorNome': 'DuckHat Studio',
      'participanteId': 2,
      'participanteNome': 'DuckHat Studio',
      'participanteFotoPerfilBase64': 'logo-base64',
      'ultimaMensagem': 'Oi',
      'ultimaMensagemEm': '2026-05-15T10:30:00',
    });

    expect(conversa.participanteId, 2);
    expect(conversa.participanteNome, 'DuckHat Studio');
    expect(conversa.participanteFotoPerfilBase64, 'logo-base64');
  });
}
