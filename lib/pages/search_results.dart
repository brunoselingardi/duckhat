import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_route.dart';
import 'service.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  final String location;
  final String? category;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.location,
    this.category,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  static const _fallbackPoint = LatLng(-16.6869, -49.2648);

  late final TextEditingController _queryController;
  late final TextEditingController _locationController;
  final _mapController = MapController();

  LatLng _basePoint = _fallbackPoint;
  bool _locating = true;
  String? _locationMessage;

  final _results = const [
    _ProviderResult(
      name: 'Barbie Dream Barber',
      category: 'Salao e barbearia',
      image: 'assets/barbielogo.jpg',
      rating: 4.9,
      reviews: 5500,
      address: 'Av. Castelo Branco, 2857 - Campinas',
      city: 'Goiania - GO, 74513-101',
      weekdayHours: 'SEG a SEX: 8h - 18h',
      weekendHours: 'SAB: 8h - 13h',
      phone: '(62) 3233-9953',
      distance: '1,2 km',
      tags: ['Corte', 'Barba', 'Manicure'],
    ),
    _ProviderResult(
      name: 'Arthur Cavalos e Cia',
      category: 'Artigos para cavalos',
      image: 'assets/icon.jpg',
      rating: 4.8,
      reviews: 5500,
      address: 'Avenida Castelo Branco, 2857',
      city: 'Goiania - GO, 74513-101',
      weekdayHours: 'SEG a SEX: 7h - 18h',
      weekendHours: 'SAB: 8h - 13h',
      phone: '(62) 3233-9953',
      distance: '2,4 km',
      tags: ['Acessorios', 'Limpeza', 'Entrega'],
    ),
    _ProviderResult(
      name: 'John Chapeus',
      category: 'Moda e acessorios',
      image: 'assets/niceduck.jpg',
      rating: 4.7,
      reviews: 3200,
      address: 'Rua 44, Setor Norte Ferroviario',
      city: 'Goiania - GO, 74063-010',
      weekdayHours: 'SEG a SEX: 9h - 18h',
      weekendHours: 'SAB: 9h - 14h',
      phone: '(62) 3233-9953',
      distance: '3,1 km',
      tags: ['Chapeus', 'Ajustes', 'Atacado'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: _displayQuery);
    _locationController = TextEditingController(text: _displayLocation);
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useFallbackLocation('GPS desligado. Usando Goiania como referencia.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _useFallbackLocation(
          'Permissao de localizacao negada. Usando Goiania como referencia.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final point = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _basePoint = point;
        _locating = false;
        _locationMessage = 'Usando sua localizacao atual';
      });
      _moveMap(point, 14.5);
    } catch (_) {
      _useFallbackLocation('Nao foi possivel obter sua localizacao atual.');
    }
  }

  void _useFallbackLocation(String message) {
    if (!mounted) return;
    setState(() {
      _basePoint = _fallbackPoint;
      _locating = false;
      _locationMessage = message;
    });
    _moveMap(_fallbackPoint, 13.5);
  }

  void _moveMap(LatLng point, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapController.move(point, zoom);
    });
  }

  String get _displayQuery {
    if (widget.query.isNotEmpty) return widget.query;
    if (widget.category != null && widget.category!.isNotEmpty) {
      return widget.category!;
    }
    return 'Servicos proximos a mim';
  }

  String get _displayLocation {
    if (widget.location.isNotEmpty) return widget.location;
    return 'Proximos a mim';
  }

  List<_ProviderResult> get _filteredResults {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isEmpty || query == 'servicos proximos a mim') return _results;

    return _results.where((item) {
      final haystack = [
        item.name,
        item.category,
        item.address,
        item.city,
        ...item.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  void _runLocalSearch() {
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void _openProvider(_ProviderResult result) {
    Navigator.of(context).push(AppRoute(builder: (_) => const ServicePage()));
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          key: const PageStorageKey('search-results-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _ResultsSearchBar(
                    queryController: _queryController,
                    locationController: _locationController,
                    onBack: () => Navigator.of(context).pop(),
                    onSubmit: _runLocalSearch,
                  ),
                  _QuickFilters(
                    selected: widget.category,
                    onSelected: (value) {
                      _queryController.text = value;
                      _runLocalSearch();
                    },
                  ),
                  _MapPreview(
                    mapController: _mapController,
                    basePoint: _basePoint,
                    results: results,
                    locating: _locating,
                    message: _locationMessage,
                  ),
                  _ResultsSummary(count: results.length),
                ],
              ),
            ),
            if (results.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _NoResults(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                sliver: SliverList.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return _ResultCard(
                      result: result,
                      onTap: () => _openProvider(result),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultsSearchBar extends StatelessWidget {
  final TextEditingController queryController;
  final TextEditingController locationController;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const _ResultsSearchBar({
    required this.queryController,
    required this.locationController,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textMuted,
            tooltip: 'Voltar',
          ),
          Expanded(
            child: Column(
              children: [
                _CompactSearchField(
                  controller: queryController,
                  icon: Icons.search,
                  hint: 'O que voce procura?',
                  onSubmitted: onSubmit,
                ),
                const SizedBox(height: 8),
                _CompactSearchField(
                  controller: locationController,
                  icon: Icons.location_on_outlined,
                  hint: 'Localizacao',
                  onSubmitted: onSubmit,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            onPressed: onSubmit,
            icon: const Icon(Icons.search),
            tooltip: 'Pesquisar',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactSearchField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final VoidCallback onSubmitted;

  const _CompactSearchField({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSubmitted(),
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AppColors.textBold,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _QuickFilters extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _QuickFilters({required this.selected, required this.onSelected});

  static const _items = [
    'algumacoisabemgrande',
    'pra deixar',
    'desalinhado',
    'aberto agora',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _items[index];
          final isSelected = selected == item;

          return ChoiceChip(
            selected: isSelected,
            label: Text(item),
            onSelected: (_) => onSelected(item),
            selectedColor: AppColors.accent.withValues(alpha: 0.16),
            backgroundColor: const Color(0xFFE5EBF2),
            side: BorderSide.none,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.textRegular,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final MapController mapController;
  final LatLng basePoint;
  final List<_ProviderResult> results;
  final bool locating;
  final String? message;

  const _MapPreview({
    required this.mapController,
    required this.basePoint,
    required this.results,
    required this.locating,
    required this.message,
  });

  LatLng _resultPoint(int index) {
    const offsets = [
      (0.0048, -0.0036),
      (-0.0034, 0.0042),
      (0.0026, 0.0054),
      (-0.0051, -0.0028),
    ];
    final offset = offsets[index % offsets.length];
    return LatLng(
      basePoint.latitude + offset.$1,
      basePoint.longitude + offset.$2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerMarkers = <Marker>[
      for (var i = 0; i < results.length; i++)
        Marker(
          point: _resultPoint(i),
          width: 118,
          height: 58,
          child: _ProviderMapMarker(result: results[i]),
        ),
    ];

    return Container(
      height: 232,
      width: double.infinity,
      color: AppColors.cardBackground,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: basePoint,
              initialZoom: 13.5,
              minZoom: 4,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.duckhat',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: basePoint,
                    radius: 850,
                    useRadiusInMeter: true,
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderColor: AppColors.accent.withValues(alpha: 0.32),
                    borderStrokeWidth: 1.4,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: basePoint,
                    width: 54,
                    height: 54,
                    child: const _UserMapMarker(),
                  ),
                  ...providerMarkers,
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            top: 12,
            right: 12,
            child: _MapStatusBadge(
              locating: locating,
              text: message ?? 'Buscando sua localizacao atual',
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: () {
                    final camera = mapController.camera;
                    mapController.move(camera.center, camera.zoom + 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () {
                    final camera = mapController.camera;
                    mapController.move(camera.center, camera.zoom - 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.my_location,
                  onTap: () => mapController.move(basePoint, 14.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapStatusBadge extends StatelessWidget {
  final bool locating;
  final String text;

  const _MapStatusBadge({required this.locating, required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            if (locating)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.near_me, color: AppColors.accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textBold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 38,
          height: 36,
          child: Icon(icon, color: AppColors.textBold, size: 20),
        ),
      ),
    );
  }
}

class _UserMapMarker extends StatelessWidget {
  const _UserMapMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55217CE5),
              blurRadius: 14,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderMapMarker extends StatelessWidget {
  final _ProviderResult result;

  const _ProviderMapMarker({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
              result.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const Icon(Icons.location_on, color: AppColors.accent, size: 28),
      ],
    );
  }
}

class _ResultsSummary extends StatelessWidget {
  final int count;

  const _ResultsSummary({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count resultados encontrados',
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Filtros'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _ProviderResult result;
  final VoidCallback onTap;

  const _ResultCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 82,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/ondas.jpg', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.96),
                          Colors.white.withValues(alpha: 0.72),
                          AppColors.accent.withValues(alpha: 0.06),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            result.image,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textBold,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${result.category} - Mais',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textRegular,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.star,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${result.rating.toStringAsFixed(1)}  ${result.reviews} avaliacoes',
                                    style: const TextStyle(
                                      color: AppColors.textRegular,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          result.distance,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.map_outlined,
                    child: Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: AppColors.textBold,
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(text: '${result.address}, '),
                            const TextSpan(
                              text: 'MAPA',
                              style: TextStyle(
                                color: AppColors.accent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: '\n${result.city}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.access_time,
                    child: Expanded(
                      child: Text(
                        '${result.weekdayHours}\n${result.weekendHours}',
                        style: const TextStyle(
                          color: AppColors.textBold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.phone_in_talk_outlined,
                    child: Expanded(
                      child: Text(
                        result.phone,
                        style: const TextStyle(
                          color: AppColors.textBold,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Servicos disponiveis',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _InfoRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textBold, size: 22),
        const SizedBox(width: 10),
        child,
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: AppColors.textMutedLight, size: 52),
            SizedBox(height: 12),
            Text(
              'Nenhum estabelecimento encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textBold,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tente alterar o termo, categoria ou localizacao.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textRegular, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderResult {
  final String name;
  final String category;
  final String image;
  final double rating;
  final int reviews;
  final String address;
  final String city;
  final String weekdayHours;
  final String weekendHours;
  final String phone;
  final String distance;
  final List<String> tags;

  const _ProviderResult({
    required this.name,
    required this.category,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.address,
    required this.city,
    required this.weekdayHours,
    required this.weekendHours,
    required this.phone,
    required this.distance,
    required this.tags,
  });
}
