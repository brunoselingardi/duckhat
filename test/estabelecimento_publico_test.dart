import 'package:duckhat/models/estabelecimento_publico.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses public provider profile from API payload', () {
    final perfil = EstabelecimentoPublico.fromJson({
      'id': 12,
      'nome': 'DuckHat Studio',
      'telefone': '62999990000',
      'endereco': 'Av. Central, 100',
      'descricaoPublica': 'Cortes e cuidados para todos os estilos.',
      'horarioAtendimento': 'Segunda a sexta 9h - 20h',
      'imagemCapa': 'assets/barbie.jpg',
      'imagemLogo': 'assets/barbielogo.jpg',
      'fotoPerfilBase64': 'logo-base64',
    });

    expect(perfil.id, 12);
    expect(perfil.nome, 'DuckHat Studio');
    expect(perfil.endereco, 'Av. Central, 100');
    expect(perfil.descricaoPublica, 'Cortes e cuidados para todos os estilos.');
    expect(perfil.horarioAtendimento, 'Segunda a sexta 9h - 20h');
    expect(perfil.imagemCapa, 'assets/barbie.jpg');
    expect(perfil.imagemLogo, 'assets/barbielogo.jpg');
    expect(perfil.fotoPerfilBase64, 'logo-base64');
  });
}
