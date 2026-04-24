import 'package:duckhat/services/geo_search_service.dart';
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
  final bool useCurrentLocation;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.location,
    this.category,
    this.useCurrentLocation = true,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  static const _fallbackPoint = LatLng(-16.6869, -49.2648);

  final _search = GeoSearchService.instance;
  final _mapController = MapController();
  final _distance = const Distance();

  late final TextEditingController _queryController;
  late final TextEditingController _locationController;

  LatLng _basePoint = _fallbackPoint;
  bool _usingCurrentLocation = true;
  bool _loading = true;
  String? _error;
  String? _locationMessage;
  List<_PlaceCardModel> _results = const [];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: _displayQuery);
    _locationController = TextEditingController(text: _displayLocation);
    _usingCurrentLocation = widget.useCurrentLocation || widget.location.isEmpty;
    _runSearch();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String get _displayQuery {
    if (widget.query.trim().isNotEmpty) return widget.query.trim();
    if (widget.category != null && widget.category!.trim().isNotEmpty) {
      return widget.category!.trim();
    }
    return 'estabelecimentos';
  }

  String get _displayLocation {
    if (widget.location.trim().isNotEmpty) return widget.location.trim();
    return 'Minha localizacao atual';
  }

  Future<void> _runSearch() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _locationMessage = _usingCurrentLocation
          ? 'Buscando sua localizacao atual'
          : 'Resolvendo endereco ou CEP';
    });

    try {
      final origin = _usingCurrentLocation
          ? await _loadCurrentPosition()
          : await _search.geocode(_locationController.text);

      if (!mounted) return;

      setState(() {
        _basePoint = origin.point;
        _locationController.text = _usingCurrentLocation
            ? 'Minha localizacao atual'
            : origin.formattedAddress;
        _locationMessage = _usingCurrentLocation
            ? 'Usando sua localizacao atual'
            : 'Usando ${origin.formattedAddress}';
      });
      _moveMap(origin.point, 13.8);

      final places = await _search.searchText(
        center: origin.point,
        query: _queryController.text,
      );

      if (!mounted) return;

      final items = places
          .map((item) => _PlaceCardModel.fromGoogle(item, origin.point, _distance))
          .toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      setState(() {
        _results = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    }
  }

  Future<GeocodedLocation> _loadCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Ative o GPS para usar a localizacao atual.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Permita o acesso a localizacao para usar essa opcao.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return GeocodedLocation(
      point: LatLng(position.latitude, position.longitude),
      formattedAddress: 'Minha localizacao atual',
    );
  }

  void _moveMap(LatLng point, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapController.move(point, zoom);
    });
  }

  void _switchToManualLocation() {
    setState(() {
      _usingCurrentLocation = false;
      if (_locationController.text == 'Minha localizacao atual') {
        _locationController.clear();
      }
      _locationMessage = 'Digite um endereco ou CEP para pesquisar.';
    });
  }

  void _openProvider(_PlaceCardModel result) {
    if (!result.hasInternalPage) return;
    Navigator.of(context).push(AppRoute(builder: (_) => const ServicePage()));
  }

  @override
  Widget build(BuildContext context) {
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
                    usingCurrentLocation: _usingCurrentLocation,
                    onBack: () => Navigator.of(context).pop(),
                    onUseCurrentLocation: () {
                      setState(() => _usingCurrentLocation = true);
                      _runSearch();
                    },
                    onUseManualLocation: _switchToManualLocation,
                    onSubmit: _runSearch,
                  ),
                  _MapPreview(
                    mapController: _mapController,
                    basePoint: _basePoint,
                    results: _results,
                    loading: _loading,
                    message: _error ?? _locationMessage,
                  ),
                  _ResultsSummary(
                    count: _results.length,
                    loading: _loading,
                  ),
                ],
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SearchErrorState(
                  message: _error!,
                  onRetry: _runSearch,
                ),
              )
            else if (_results.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _NoResults(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                sliver: SliverList.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return _ResultCard(
                      result: result,
                      onOpenPage: result.hasInternalPage
                          ? () => _openProvider(result)
                          : null,
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
  final bool usingCurrentLocation;
  final VoidCallback onBack;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onUseManualLocation;
  final VoidCallback onSubmit;

  const _ResultsSearchBar({
    required this.queryController,
    required this.locationController,
    required this.usingCurrentLocation,
    required this.onBack,
    required this.onUseCurrentLocation,
    required this.onUseManualLocation,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  hint: usingCurrentLocation
                      ? 'Minha localizacao atual'
                      : 'Digite endereco ou CEP',
                  readOnly: usingCurrentLocation,
                  onTap: usingCurrentLocation ? onUseManualLocation : null,
                  onSubmitted: onSubmit,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _LocationChip(
                        selected: usingCurrentLocation,
                        icon: Icons.my_location,
                        label: 'Atual',
                        onTap: onUseCurrentLocation,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _LocationChip(
                        selected: !usingCurrentLocation,
                        icon: Icons.pin_drop_outlined,
                        label: 'Endereco/CEP',
                        onTap: onUseManualLocation,
                      ),
                    ),
                  ],
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
  final bool readOnly;
  final VoidCallback? onTap;
  final VoidCallback onSubmitted;

  const _CompactSearchField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.readOnly = false,
    this.onTap,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
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

class _LocationChip extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LocationChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.inputFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.accent,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textBold,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final MapController mapController;
  final LatLng basePoint;
  final List<_PlaceCardModel> results;
  final bool loading;
  final String? message;

  const _MapPreview({
    required this.mapController,
    required this.basePoint,
    required this.results,
    required this.loading,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
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
              MarkerLayer(
                markers: [
                  Marker(
                    point: basePoint,
                    width: 54,
                    height: 54,
                    child: const _UserMapMarker(),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            top: 12,
            right: 12,
            child: _MapStatusBadge(
              loading: loading,
              text: message ?? 'Mapa da regiao pesquisada',
            ),
          ),
        ],
      ),
    );
  }
}

class _MapStatusBadge extends StatelessWidget {
  final bool loading;
  final String text;

  const _MapStatusBadge({required this.loading, required this.text});

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
            if (loading)
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
                maxLines: 2,
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

class _ResultsSummary extends StatelessWidget {
  final int count;
  final bool loading;

  const _ResultsSummary({
    required this.count,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final text = loading ? 'Pesquisando estabelecimentos...' : '$count resultados encontrados';
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Icons.travel_explore, color: AppColors.accent, size: 18),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _PlaceCardModel result;
  final VoidCallback? onOpenPage;

  const _ResultCard({
    required this.result,
    this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  result.hasInternalPage
                      ? AppColors.accent.withValues(alpha: 0.10)
                      : AppColors.secondary.withValues(alpha: 0.12),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: result.hasInternalPage
                        ? AppColors.accent.withValues(alpha: 0.14)
                        : AppColors.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    result.hasInternalPage
                        ? Icons.storefront
                        : Icons.location_city_outlined,
                    color: AppColors.textBold,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textBold,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.categoryLabel,
                        style: const TextStyle(
                          color: AppColors.textRegular,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Badge(text: result.distanceLabel, icon: Icons.near_me),
                          _Badge(
                            text: result.hasInternalPage
                                ? 'Pagina no app'
                                : 'Sem pagina no app',
                            icon: result.hasInternalPage
                                ? Icons.check_circle
                                : Icons.info_outline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailLine(
                  icon: Icons.map_outlined,
                  text: result.address,
                ),
                if (!result.hasInternalPage) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Este estabelecimento foi encontrado na busca externa, mas ainda nao tem pagina cadastrada no app.',
                      style: TextStyle(
                        color: AppColors.textBold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (onOpenPage != null)
                      FilledButton.icon(
                        onPressed: onOpenPage,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                        label: const Text('Abrir pagina no app'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Badge({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textBold),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            text,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SearchErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 52),
            const SizedBox(height: 12),
            const Text(
              'Nao foi possivel concluir a busca',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textBold,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textRegular,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
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
              'Tente ajustar o termo de busca ou o CEP/endereco informado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textRegular, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCardModel {
  final String name;
  final String categoryLabel;
  final String address;
  final LatLng location;
  final double distanceMeters;
  final String distanceLabel;
  final bool hasInternalPage;

  const _PlaceCardModel({
    required this.name,
    required this.categoryLabel,
    required this.address,
    required this.location,
    required this.distanceMeters,
    required this.distanceLabel,
    required this.hasInternalPage,
  });

  factory _PlaceCardModel.fromGoogle(
    PlaceSearchResult item,
    LatLng origin,
    Distance distance,
  ) {
    final meters = distance.as(LengthUnit.Meter, origin, item.location);
    final hasInternalPage = _hasInternalPage(item.name);

    return _PlaceCardModel(
      name: item.name,
      categoryLabel: 'Estabelecimento',
      address: item.formattedAddress,
      location: item.location,
      distanceMeters: meters,
      distanceLabel: _formatDistance(meters),
      hasInternalPage: hasInternalPage,
    );
  }

  static bool _hasInternalPage(String name) {
    final normalized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
    return normalized.contains('barbie dream barber') ||
        normalized.contains('barbie salon') ||
        normalized.contains('barbies salon');
  }

  static String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
    }
    return '${meters.round()} m';
  }
}
