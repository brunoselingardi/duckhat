import 'package:duckhat/services/duckhat_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => DuckHatApi.instance.clearSession());

  test('excluirMinhaConta limpa a sessão em modo desenvolvimento', () async {
    DuckHatApi.instance.startDevSession(tipo: 'CLIENTE');

    await DuckHatApi.instance.excluirMinhaConta();

    expect(DuckHatApi.instance.currentSession, isNull);
    expect(DuckHatApi.instance.isDevMode, isFalse);
  });
}
