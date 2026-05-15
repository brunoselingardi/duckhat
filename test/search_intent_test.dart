import 'package:duckhat/services/search_intent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchIntent', () {
    test('maps beauty keywords to service terms', () {
      expect(SearchIntent.fromQuery('unha').serviceTerm, 'manicure');
      expect(SearchIntent.fromQuery('mãos').serviceTerm, 'manicure');
      expect(SearchIntent.fromQuery('cabelo').serviceTerm, 'cabeleireiro');
    });

    test('maps maintenance keywords to service terms', () {
      expect(SearchIntent.fromQuery('cano banheiro').serviceTerm, 'encanador');
      expect(
        SearchIntent.fromQuery('desentupimento de pia').serviceTerm,
        'encanador',
      );
      expect(
        SearchIntent.fromQuery('manutencao hidráulica').serviceTerm,
        'encanador',
      );
      expect(
        SearchIntent.fromQuery('luz do quarto').serviceTerm,
        'eletricista',
      );
    });

    test('prefers normalized internal catalog terms for known intents', () {
      expect(
        SearchIntent.fromQuery('cano banheiro').internalCatalogTerm,
        'encanador',
      );
      expect(
        SearchIntent.fromQuery('barbie dream barber').internalCatalogTerm,
        'barbie dream barber',
      );
    });

    test('builds catalog search term from normalized intent', () {
      expect(
        SearchIntent.catalogSearchTerm(query: 'cano banheiro', category: null),
        'encanador',
      );
      expect(
        SearchIntent.catalogSearchTerm(
          query: 'barbie dream barber',
          category: null,
        ),
        'barbie dream barber',
      );
      expect(
        SearchIntent.catalogSearchTerm(query: '', category: 'barbearia'),
        'barbearia',
      );
    });

    test('narrows external search for maintenance services', () {
      expect(SearchIntent.fromQuery('cano').usesExternalNameFilter, isTrue);
      expect(SearchIntent.fromQuery('luz').usesExternalNameFilter, isTrue);
    });

    test('returns Barbie as internal result for hair searches', () {
      final results = SearchIntent.fromQuery(
        'cabeleireiros proximos a mim',
      ).demoPlaces(const SearchPoint(latitude: -16.6869, longitude: -49.2648));

      final barbie = results.singleWhere(
        (item) => item.name == 'Barbie Dream Barber',
      );

      expect(results.map((item) => item.name), contains('Barbie Dream Barber'));
      expect(barbie.hasInternalPage, isTrue);
      expect(barbie.prestadorId, 2);
    });

    test('builds WhatsApp url for external results', () {
      final result = SearchIntent.fromQuery('cano')
          .demoPlaces(
            const SearchPoint(latitude: -16.6869, longitude: -49.2648),
          )
          .singleWhere((item) => item.name == 'M&L Encanamentos LTDA');

      expect(result.hasInternalPage, isFalse);
      expect(result.whatsappUrl.toString(), startsWith('https://wa.me/'));
      expect(result.whatsappUrl.queryParameters['text'], contains('DuckHat'));
    });
  });
}
