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
        SearchIntent.fromQuery('luz do quarto').serviceTerm,
        'eletricista',
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

      expect(results.map((item) => item.name), contains('Barbie Dream Barber'));
      expect(
        results
            .singleWhere((item) => item.name == 'Barbie Dream Barber')
            .hasInternalPage,
        isTrue,
      );
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
