import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../core/api_config.dart';

class GeoSearchService {
  GeoSearchService._();

  static final GeoSearchService instance = GeoSearchService._();
  static const _searchRadiusMeters = 5000;

  final http.Client _client = http.Client();

  Future<GeocodedLocation> geocode(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      throw Exception('Informe um endereco ou CEP para pesquisar.');
    }

    final cep = _normalizeCep(query);
    if (cep != null) {
      return _geocodeBrazilianCep(cep);
    }

    return _geocodeWithGeoapify(query);
  }

  Future<GeocodedLocation> _geocodeBrazilianCep(String cep) async {
    final response = await _client.get(
      Uri.https('viacep.com.br', '/ws/$cep/json/'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao consultar o CEP informado.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta invalida do servico de CEP.');
    }

    if (body['erro'] == true) {
      throw Exception('CEP nao encontrado.');
    }

    return _geocodeWithGeoapifyStructured(
      postcode: cep,
      street: _stringOrNull(body['logradouro']),
      city: _stringOrNull(body['localidade']),
      state: _stringOrNull(body['uf']),
      country: 'Brasil',
      fallbackFormattedAddress: _buildFormattedAddress([
        body['logradouro'],
        body['bairro'],
        body['localidade'],
        body['uf'],
        'Brasil',
      ]),
    );
  }

  Future<GeocodedLocation> _geocodeWithGeoapify(
    String query, {
    String? fallbackFormattedAddress,
  }) async {
    _requireApiKey();

    final response = await _client.get(
      Uri.https('api.geoapify.com', '/v1/geocode/search', {
        'text': query,
        'lang': 'pt',
        'limit': '1',
        'filter': 'countrycode:br',
        'format': 'json',
        'apiKey': ApiConfig.geoapifyApiKey,
      }),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao resolver o endereco informado.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta invalida da geocodificacao.');
    }

    final results = body['results'];
    if (results is! List || results.isEmpty) {
      throw Exception('Nenhum endereco encontrado para "$query".');
    }

    final first = Map<String, dynamic>.from(results.first as Map);
    final lat = (first['lat'] as num?)?.toDouble();
    final lon = (first['lon'] as num?)?.toDouble();

    if (lat == null || lon == null) {
      throw Exception('A geocodificacao retornou coordenadas invalidas.');
    }

    return GeocodedLocation(
      point: LatLng(lat, lon),
      formattedAddress:
          first['formatted'] as String? ??
          fallbackFormattedAddress ??
          query,
    );
  }

  Future<GeocodedLocation> _geocodeWithGeoapifyStructured({
    required String postcode,
    String? street,
    String? city,
    String? state,
    required String country,
    String? fallbackFormattedAddress,
  }) async {
    _requireApiKey();

    final query = <String, String>{
      'postcode': postcode,
      'country': country,
      'lang': 'pt',
      'limit': '1',
      'format': 'json',
      'apiKey': ApiConfig.geoapifyApiKey,
    };

    if (street != null) query['street'] = street;
    if (city != null) query['city'] = city;
    if (state != null) query['state'] = state;

    final response = await _client.get(
      Uri.https('api.geoapify.com', '/v1/geocode/search', query),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao resolver o CEP informado.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta invalida da geocodificacao.');
    }

    final results = body['results'];
    if (results is! List || results.isEmpty) {
      if (fallbackFormattedAddress != null && fallbackFormattedAddress.isNotEmpty) {
        return _geocodeWithGeoapify(
          fallbackFormattedAddress,
          fallbackFormattedAddress: fallbackFormattedAddress,
        );
      }
      throw Exception('Nao foi possivel localizar o CEP informado no mapa.');
    }

    final first = Map<String, dynamic>.from(results.first as Map);
    final lat = (first['lat'] as num?)?.toDouble();
    final lon = (first['lon'] as num?)?.toDouble();

    if (lat == null || lon == null) {
      throw Exception('A geocodificacao retornou coordenadas invalidas.');
    }

    return GeocodedLocation(
      point: LatLng(lat, lon),
      formattedAddress:
          first['formatted'] as String? ??
          fallbackFormattedAddress ??
          postcode,
    );
  }

  Future<List<PlaceSearchResult>> searchText({
    required LatLng center,
    required String query,
  }) async {
    _requireApiKey();

    final normalizedQuery = query.trim();
    final categories = _categoriesForQuery(normalizedQuery);
    final nameFilter = _nameFilterForQuery(normalizedQuery);
    final response = await _client.get(
      Uri.https('api.geoapify.com', '/v2/places', {
        'categories': categories,
        ...?nameFilter == null ? null : {'name': nameFilter},
        'filter':
            'circle:${center.longitude},${center.latitude},$_searchRadiusMeters',
        'bias': 'proximity:${center.longitude},${center.latitude}',
        'limit': '12',
        'lang': 'pt',
        'apiKey': ApiConfig.geoapifyApiKey,
      }),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao consultar estabelecimentos no Geoapify.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta invalida do Geoapify.');
    }

    final features = body['features'];
    if (features is! List || features.isEmpty) {
      return const [];
    }

    return features.map((item) {
      final feature = Map<String, dynamic>.from(item as Map);
      final properties = Map<String, dynamic>.from(
        feature['properties'] as Map<String, dynamic>? ?? const {},
      );
      final geometry = Map<String, dynamic>.from(
        feature['geometry'] as Map<String, dynamic>? ?? const {},
      );
      final coordinates = geometry['coordinates'];
      final latitude = properties['lat'] as num?;
      final longitude = properties['lon'] as num?;

      double? lat = latitude?.toDouble();
      double? lon = longitude?.toDouble();
      if ((lat == null || lon == null) && coordinates is List && coordinates.length >= 2) {
        lon = (coordinates[0] as num?)?.toDouble();
        lat = (coordinates[1] as num?)?.toDouble();
      }

      if (lat == null || lon == null) {
        return null;
      }

      return PlaceSearchResult(
        id: properties['place_id'] as String? ?? '',
        name: _stringOrNull(properties['name']) ?? 'Estabelecimento',
        formattedAddress:
            _stringOrNull(properties['formatted']) ??
            _buildFormattedAddress([
              properties['address_line1'],
              properties['address_line2'],
              properties['city'],
              properties['state'],
            ]) ??
            'Endereco indisponivel',
        location: LatLng(
          lat,
          lon,
        ),
      );
    }).whereType<PlaceSearchResult>().toList();
  }

  String? _normalizeCep(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    return digits;
  }

  String? _stringOrNull(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _buildFormattedAddress(List<Object?> parts) {
    final normalized = parts
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (normalized.isEmpty) return null;
    return normalized.join(', ');
  }

  String _categoriesForQuery(String query) {
    final normalized = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .trim();

    if (normalized.isEmpty) {
      return 'service,commercial,catering';
    }

    if (_containsAny(normalized, [
      'barbearia',
      'barbeiro',
      'barber',
      'cabelo',
      'cabeleireiro',
      'cabeleireira',
      'salao',
      'salon',
      'manicure',
      'pedicure',
      'estetica',
      'beauty',
    ])) {
      return 'service.beauty,service.beauty.hairdresser';
    }

    if (_containsAny(normalized, [
      'restaurante',
      'lanchonete',
      'lanche',
      'pizzaria',
      'pizza',
      'hamburguer',
      'hamburger',
      'sushi',
      'acai',
      'cafe',
      'cafeteria',
      'bar',
    ])) {
      return 'catering,catering.restaurant,catering.cafe,catering.fast_food,catering.bar';
    }

    if (_containsAny(normalized, [
      'academia',
      'gym',
      'crossfit',
      'fitness',
    ])) {
      return 'sport.fitness,sport.fitness.fitness_centre,sport.sports_centre';
    }

    if (_containsAny(normalized, [
      'hotel',
      'pousada',
      'hostel',
      'motel',
    ])) {
      return 'accommodation,accommodation.hotel,accommodation.guest_house,accommodation.hostel,accommodation.motel';
    }

    if (_containsAny(normalized, [
      'pet',
      'veterinario',
      'veterinaria',
      'petshop',
    ])) {
      return 'pet,pet.shop,pet.veterinary,pet.service';
    }

    if (_containsAny(normalized, [
      'mercado',
      'supermercado',
      'loja',
      'shopping',
      'comercio',
    ])) {
      return 'commercial';
    }

    return 'service,commercial,catering,office,pet,sport,accommodation';
  }

  String? _nameFilterForQuery(String query) {
    final normalized = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .trim();

    if (normalized.isEmpty) return null;

    if (_containsAny(normalized, [
      'barbearia',
      'barbeiro',
      'barber',
      'cabelo',
      'cabeleireiro',
      'cabeleireira',
      'salao',
      'salon',
      'manicure',
      'pedicure',
      'estetica',
      'beauty',
      'restaurante',
      'lanchonete',
      'lanche',
      'pizzaria',
      'pizza',
      'hamburguer',
      'hamburger',
      'sushi',
      'acai',
      'cafe',
      'cafeteria',
      'bar',
      'academia',
      'gym',
      'crossfit',
      'fitness',
      'hotel',
      'pousada',
      'hostel',
      'motel',
      'pet',
      'veterinario',
      'veterinaria',
      'petshop',
      'mercado',
      'supermercado',
      'loja',
      'shopping',
      'comercio',
    ])) {
      return null;
    }

    return query.trim();
  }

  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }

  void _requireApiKey() {
    if (ApiConfig.hasGeoapifyApiKey) return;
    throw Exception(
      'Defina GEOAPIFY_API_KEY via --dart-define para buscar estabelecimentos no mapa.',
    );
  }
}

class GeocodedLocation {
  final LatLng point;
  final String formattedAddress;

  const GeocodedLocation({
    required this.point,
    required this.formattedAddress,
  });
}

class PlaceSearchResult {
  final String id;
  final String name;
  final String formattedAddress;
  final LatLng location;

  const PlaceSearchResult({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.location,
  });
}
