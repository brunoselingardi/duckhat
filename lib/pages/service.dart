import 'package:duckhat/components/service/service_data.dart';
import 'package:duckhat/components/service/service_hero.dart';
import 'package:duckhat/components/service/service_info_card.dart';
import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/components/service/service_sections.dart';
import 'package:duckhat/components/service/service_tab_menu.dart';
import 'package:duckhat/models/servico_catalogo.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _galleryController = PageController(
    viewportFraction: 0.42,
  );
  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());

  int _selectedTabIndex = 0;
  int _selectedGalleryIndex = 0;
  bool _isAutoScrolling = false;
  bool _loadingServices = true;
  String? _servicesError;
  List<ServiceOffer> _offers = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    Future.microtask(() {
      if (!mounted) return;
      for (final image in serviceGalleryImages) {
        precacheImage(AssetImage(image), context);
      }
    });
    _loadServices();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_isAutoScrolling || !mounted) return;

    int nearestIndex = _selectedTabIndex;
    double nearestDistance = double.infinity;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final context = _sectionKeys[i].currentContext;
      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;

      final distance = (box.localToGlobal(Offset.zero).dy - 160).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestIndex != _selectedTabIndex) {
      setState(() => _selectedTabIndex = nearestIndex);
    }
  }

  Future<void> _scrollToSection(int index) async {
    final context = _sectionKeys[index].currentContext;
    if (context == null) return;

    setState(() {
      _selectedTabIndex = index;
      _isAutoScrolling = true;
    });

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      alignment: 0.04,
    );

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _isAutoScrolling = false;
    });
  }

  void _onGalleryPageChanged(int index) {
    if (index != _selectedGalleryIndex) {
      setState(() => _selectedGalleryIndex = index);
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _servicesError = null;
    });

    try {
      final services = await DuckHatApi.instance.listarServicosPorPrestador(
        servicePrestadorId,
      );
      if (!mounted) return;

      setState(() {
        _offers = services.map(_offerFromServico).toList();
        _loadingServices = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingServices = false;
        _servicesError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  ServiceOffer _offerFromServico(ServicoCatalogo service) {
    return ServiceOffer(
      serviceId: service.id,
      prestadorId: service.prestadorId,
      title: service.nome,
      description: service.descricao ?? '',
      durationMin: service.duracaoMin,
      priceValue: service.preco,
    );
  }

  Future<void> _selectGalleryImage(int index) async {
    setState(() => _selectedGalleryIndex = index);
    await _galleryController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _openGalleryFullscreen() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.asset(
                    serviceGalleryImages[_selectedGalleryIndex],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 24,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _bookOffer(ServiceOffer offer) async {
    final created = await Navigator.pushNamed(
      context,
      '/schedule-date',
      arguments: {
        'serviceId': offer.serviceId,
        'prestadorId': offer.prestadorId,
        'serviceName': offer.title,
        'establishmentName': serviceEstablishmentName,
        'durationMin': offer.durationMin,
      },
    );

    if (!mounted || created != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendamento de ${offer.title} criado com sucesso.'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceHero(onBack: () => Navigator.pop(context)),
            Container(
              transform: Matrix4.translationValues(0, -28, 0),
              child: Column(
                children: [
                  const ServiceInfoCard(),
                  const SizedBox(height: 8),
                  ServiceTabMenu(
                    tabs: serviceTabs,
                    selectedIndex: _selectedTabIndex,
                    onTap: _scrollToSection,
                  ),
                  ServiceSections(
                    sectionKeys: _sectionKeys,
                    offers: _offers,
                    isServicesLoading: _loadingServices,
                    servicesError: _servicesError,
                    onServicesRetry: _loadServices,
                    reviews: serviceReviews,
                    faqs: serviceFaqs,
                    galleryImages: serviceGalleryImages,
                    selectedGalleryIndex: _selectedGalleryIndex,
                    galleryController: _galleryController,
                    onGalleryChanged: _onGalleryPageChanged,
                    onGallerySelected: _selectGalleryImage,
                    onOpenGallery: _openGalleryFullscreen,
                    onBookTap: _bookOffer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _offers.isEmpty ? null : () => _bookOffer(_offers.first),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Agendar'),
      ),
    );
  }
}
