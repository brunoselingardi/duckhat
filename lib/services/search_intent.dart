import 'dart:math' as math;

enum SearchServiceKind { beauty, manicure, plumbing, electrical, generic }

class SearchIntent {
  final String rawQuery;
  final String normalizedQuery;
  final String serviceTerm;
  final SearchServiceKind kind;

  const SearchIntent._({
    required this.rawQuery,
    required this.normalizedQuery,
    required this.serviceTerm,
    required this.kind,
  });

  factory SearchIntent.fromQuery(String query) {
    final normalized = _normalize(query);

    if (_containsAny(normalized, const [
      'unha',
      'unhas',
      'mao',
      'maos',
      'manicure',
      'pedicure',
    ])) {
      return SearchIntent._(
        rawQuery: query,
        normalizedQuery: normalized,
        serviceTerm: 'manicure',
        kind: SearchServiceKind.manicure,
      );
    }

    if (_containsAny(normalized, const [
      'cabelo',
      'cabelereiro',
      'cabeleireiro',
      'cabeleireira',
      'corte',
      'barba',
      'barbeiro',
      'barbearia',
      'salao',
      'salon',
    ])) {
      return SearchIntent._(
        rawQuery: query,
        normalizedQuery: normalized,
        serviceTerm: 'cabeleireiro',
        kind: SearchServiceKind.beauty,
      );
    }

    if (_containsAny(normalized, const [
      'cano',
      'canos',
      'banheiro',
      'encanador',
      'encanamento',
      'vazamento',
      'pia',
      'ralo',
    ])) {
      return SearchIntent._(
        rawQuery: query,
        normalizedQuery: normalized,
        serviceTerm: 'encanador',
        kind: SearchServiceKind.plumbing,
      );
    }

    if (_containsAny(normalized, const [
      'luz',
      'eletrica',
      'eletrico',
      'eletricista',
      'tomada',
      'lampada',
      'energia',
      'disjuntor',
    ])) {
      return SearchIntent._(
        rawQuery: query,
        normalizedQuery: normalized,
        serviceTerm: 'eletricista',
        kind: SearchServiceKind.electrical,
      );
    }

    final trimmed = query.trim();
    return SearchIntent._(
      rawQuery: query,
      normalizedQuery: normalized,
      serviceTerm: trimmed.isEmpty ? 'estabelecimentos' : trimmed,
      kind: SearchServiceKind.generic,
    );
  }

  bool get usesExternalNameFilter =>
      (kind == SearchServiceKind.generic &&
          serviceTerm != 'estabelecimentos') ||
      kind == SearchServiceKind.plumbing ||
      kind == SearchServiceKind.electrical;

  String get geoapifyCategories {
    return switch (kind) {
      SearchServiceKind.beauty ||
      SearchServiceKind.manicure => 'service.beauty,service.beauty.hairdresser',
      SearchServiceKind.plumbing ||
      SearchServiceKind.electrical => 'service,commercial',
      SearchServiceKind.generic =>
        'service,commercial,catering,office,pet,sport,accommodation',
    };
  }

  List<SearchDemoPlace> demoPlaces(SearchPoint origin) {
    final places = <SearchDemoPlace>[];

    if (kind == SearchServiceKind.beauty ||
        kind == SearchServiceKind.manicure) {
      places.add(
        SearchDemoPlace(
          id: 'duckhat-barbie-dream-barber',
          name: 'Barbie Dream Barber',
          categoryLabel: 'Barbearia e cabelo',
          address: 'Av. DuckHat, 120 - Setor Bueno',
          latitude: origin.latitude + 0.004,
          longitude: origin.longitude + 0.003,
          phone: '5562999990001',
          hasInternalPage: true,
        ),
      );
    }

    if (kind == SearchServiceKind.manicure) {
      places.add(
        SearchDemoPlace(
          id: 'duckhat-bella-unhas',
          name: 'Bella Unhas Studio',
          categoryLabel: 'Manicure e pedicure',
          address: 'Rua das Flores, 88 - Centro',
          latitude: origin.latitude + 0.002,
          longitude: origin.longitude - 0.003,
          phone: '5562999990002',
        ),
      );
    }

    if (kind == SearchServiceKind.plumbing) {
      places.add(
        SearchDemoPlace(
          id: 'duckhat-ml-encanamentos',
          name: 'M&L Encanamentos LTDA',
          categoryLabel: 'Encanador',
          address: 'Atendimento em banheiro, pia, cano e vazamentos',
          latitude: origin.latitude - 0.003,
          longitude: origin.longitude + 0.002,
          phone: '5562999990003',
        ),
      );
    }

    if (kind == SearchServiceKind.electrical) {
      places.add(
        SearchDemoPlace(
          id: 'duckhat-luz-certa',
          name: 'Luz Certa Eletricista',
          categoryLabel: 'Eletricista',
          address: 'Atendimento em luz, tomadas e disjuntores',
          latitude: origin.latitude - 0.002,
          longitude: origin.longitude - 0.004,
          phone: '5562999990004',
        ),
      );
    }

    return places;
  }

  static String _normalize(String value) {
    const replacements = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    var text = value.toLowerCase();
    replacements.forEach((from, to) => text = text.replaceAll(from, to));
    return text
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }
}

class SearchPoint {
  final double latitude;
  final double longitude;

  const SearchPoint({required this.latitude, required this.longitude});
}

class SearchDemoPlace {
  final String id;
  final String name;
  final String categoryLabel;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final bool hasInternalPage;

  const SearchDemoPlace({
    required this.id,
    required this.name,
    required this.categoryLabel,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.hasInternalPage = false,
  });

  Uri get whatsappUrl => SearchContact.whatsappUri(
    phone: phone,
    message:
        'Ola, encontrei ${name.trim()} pelo DuckHat e gostaria de atendimento.',
  );

  double distanceTo(SearchPoint origin) {
    const earthRadiusMeters = 6371000.0;
    final lat1 = _degreesToRadians(origin.latitude);
    final lat2 = _degreesToRadians(latitude);
    final deltaLat = _degreesToRadians(latitude - origin.latitude);
    final deltaLon = _degreesToRadians(longitude - origin.longitude);
    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}

class SearchContact {
  static Uri whatsappUri({required String phone, required String message}) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return Uri.https('wa.me', '/$digits', {'text': message});
  }
}
