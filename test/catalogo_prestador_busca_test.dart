import 'package:duckhat/models/catalogo_prestador_busca.dart';
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
    });

    expect(item.prestadorId, 2);
    expect(item.nome, 'Barbie Dream Barber');
    expect(item.categoriaLabel, 'Servico no DuckHat');
    expect(item.endereco, 'Av. DuckHat, 120 - Setor Bueno');
  });
}
