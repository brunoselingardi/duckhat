import 'package:duckhat/models/catalogo_prestador_busca.dart';
import 'package:duckhat/models/estabelecimento_catalogo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses internal catalog provider result', () {
    final item = CatalogoPrestadorBusca.fromJson({
      'prestadorId': 2,
      'nome': 'Barbie Dream Barber',
      'categoriaLabel': 'Servico no DuckHat',
      'endereco': 'Av. DuckHat, 120 - Setor Bueno',
      'telefone': '62999990000',
      'descricaoPublica': 'Descricao publica',
      'horarioAtendimento': 'Segunda a sexta 9h - 20h',
      'imagemCapa': 'assets/barbie.jpg',
      'imagemLogo': 'assets/barbielogo.jpg',
      'fotoPerfilBase64': 'logo-base64',
    });

    expect(item.prestadorId, 2);
    expect(item.nome, 'Barbie Dream Barber');
    expect(item.categoriaLabel, 'Servico no DuckHat');
    expect(item.endereco, 'Av. DuckHat, 120 - Setor Bueno');
    expect(item.fotoPerfilBase64, 'logo-base64');
  });

  test('parses Jorje Encanamentos as internal catalog establishment', () {
    final item = EstabelecimentoCatalogo.fromJson({
      'prestadorId': 13,
      'nome': 'Jorje Encanamentos',
      'telefone': '62999990013',
      'endereco': 'Rua dos Canos, 45 - Setor Oeste',
      'descricao': 'Atendimento rapido para vazamentos.',
      'horarioAtendimento': 'Segunda a sabado 7h - 19h',
      'bannerImagemBase64': null,
      'fotoPerfilBase64': 'logo-jorje',
      'totalServicos': 1,
      'precoInicial': 90,
      'servicos': [
        {
          'id': 5,
          'prestadorId': 13,
          'nome': 'Visita tecnica de encanador',
          'descricao': 'Diagnostico inicial para canos e vazamentos.',
          'duracaoMin': 45,
          'preco': 90,
          'ativo': true,
        },
      ],
    });

    expect(item.prestadorId, 13);
    expect(item.nome, 'Jorje Encanamentos');
    expect(item.enderecoPublico, 'Rua dos Canos, 45 - Setor Oeste');
    expect(item.fotoPerfilBase64, 'logo-jorje');
    expect(item.precoInicialLabel, 'A partir de R\$ 90');
    expect(item.servicos.single.prestadorId, 13);
    expect(item.servicos.single.ativo, isTrue);
  });
}
