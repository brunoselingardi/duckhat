import 'package:duckhat/components/service/service_data.dart';
import 'package:duckhat/components/service/service_hero.dart';
import 'package:duckhat/components/service/service_info_card.dart';
import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/components/service/service_sections.dart';
import 'package:duckhat/components/service/service_tab_menu.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/models/estabelecimento_catalogo.dart';
import 'package:duckhat/models/servico_catalogo.dart';
import 'package:duckhat/pages/chat_detail.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  final int prestadorId;
  final EstabelecimentoCatalogo? estabelecimento;

  const ServicePage({
    super.key,
    this.prestadorId = servicePrestadorId,
    this.estabelecimento,
  });

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
  EstabelecimentoCatalogo? _estabelecimento;
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
    _loadEstablishment();
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

  Future<void> _loadEstablishment() async {
    setState(() {
      _loadingServices = true;
      _servicesError = null;
    });

    try {
      final estabelecimento =
          widget.estabelecimento ??
          await DuckHatApi.instance.buscarEstabelecimentoCatalogo(
            widget.prestadorId,
          );
      if (!mounted) return;

      setState(() {
        _estabelecimento = estabelecimento;
        _offers = estabelecimento.servicos.map(_offerFromServico).toList();
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

  int get _prestadorId => _estabelecimento?.prestadorId ?? widget.prestadorId;

  String get _establishmentName =>
      _estabelecimento?.nome ?? serviceEstablishmentName;

  String get _establishmentAddress =>
      _estabelecimento?.enderecoPublico ?? 'Dream Avenue, 808 - Centro Fashion';

  String get _establishmentSchedule =>
      _estabelecimento?.horarioPublico ??
      'Segunda a sexta 9h - 20h | Sabado 9h - 18h';

  String get _establishmentDescription =>
      _estabelecimento?.descricaoPublica ??
      'Uma barbearia com atendimento caloroso e uma experiencia pensada para quem quer sair com mais estilo e personalidade.';

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

  Future<void> _openBookingFlow({int? initialServiceId}) async {
    final created = await Navigator.pushNamed(
      context,
      '/schedule-date',
      arguments: {
        'prestadorId': _prestadorId,
        'establishmentName': _establishmentName,
        'serviceOffers': _offers,
        'initialServiceId': initialServiceId,
      },
    );

    if (!mounted || created != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Agendamento criado com sucesso.'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Future<void> _openChat() async {
    try {
      final conversa = await DuckHatApi.instance.criarOuBuscarConversaChat(
        _prestadorId,
      );
      if (!mounted) return;

      await Navigator.push(
        context,
        AppRoute(
          builder: (context) => ChatDetailPage(
            conversaId: conversa.id,
            participanteNome: conversa.participanteNome,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        key: const PageStorageKey('service-scroll'),
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceHero(
              onBack: () => Navigator.pop(context),
              bannerImagemBase64: _estabelecimento?.bannerImagemBase64,
            ),
            Container(
              transform: Matrix4.translationValues(0, -28, 0),
              child: Column(
                children: [
                  ServiceInfoCard(
                    establishmentName: _establishmentName,
                    address: _establishmentAddress,
                    schedule: _establishmentSchedule,
                    description: _establishmentDescription,
                    onMessageTap: _openChat,
                  ),
                  const SizedBox(height: 8),
                  ServiceTabMenu(
                    tabs: serviceTabs,
                    selectedIndex: _selectedTabIndex,
                    onTap: _scrollToSection,
                  ),
                  ServiceSections(
                    sectionKeys: _sectionKeys,
                    offers: _offers,
                    establishmentName: _establishmentName,
                    experienceDescription: _establishmentDescription,
                    isServicesLoading: _loadingServices,
                    servicesError: _servicesError,
                    onServicesRetry: _loadEstablishment,
                    onBookOffer: (offer) =>
                        _openBookingFlow(initialServiceId: offer.serviceId),
                    reviews: serviceReviews,
                    faqs: serviceFaqs,
                    galleryImages: serviceGalleryImages,
                    selectedGalleryIndex: _selectedGalleryIndex,
                    galleryController: _galleryController,
                    onGalleryChanged: _onGalleryPageChanged,
                    onGallerySelected: _selectGalleryImage,
                    onOpenGallery: _openGalleryFullscreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _offers.isEmpty ? null : () => _openBookingFlow(),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Agendar'),
      ),
    );
  }
}
