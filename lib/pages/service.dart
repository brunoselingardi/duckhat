import 'package:duckhat/components/service/service_hero.dart';
import 'package:duckhat/components/service/service_info_card.dart';
import 'package:duckhat/components/service/service_image.dart';
import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/components/service/service_profile_fallbacks.dart';
import 'package:duckhat/components/service/service_sections.dart';
import 'package:duckhat/components/service/service_tab_menu.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/models/avaliacao.dart';
import 'package:duckhat/models/estabelecimento_catalogo.dart';
import 'package:duckhat/models/estabelecimento_publico.dart';
import 'package:duckhat/models/servico_catalogo.dart';
import 'package:duckhat/pages/chat_detail.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

typedef ServiceProfileLoader =
    Future<EstabelecimentoPublico> Function(int prestadorId);
typedef ServiceOffersLoader =
    Future<List<ServicoCatalogo>> Function(int prestadorId);
typedef ServiceReviewsLoader =
    Future<List<Avaliacao>> Function(int prestadorId);

class ServicePage extends StatefulWidget {
  final int prestadorId;
  final EstabelecimentoCatalogo? estabelecimento;
  final ServiceProfileLoader? profileLoader;
  final ServiceOffersLoader? servicesLoader;
  final ServiceReviewsLoader? reviewsLoader;

  const ServicePage({
    super.key,
    required this.prestadorId,
    this.estabelecimento,
    this.profileLoader,
    this.servicesLoader,
    this.reviewsLoader,
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
  bool _loadingProfile = true;
  bool _loadingServices = true;
  String? _profileError;
  String? _servicesError;
  EstabelecimentoCatalogo? _catalog;
  EstabelecimentoPublico? _profile;
  ServicePublicPageFallback? _fallback;
  List<ServiceOffer> _offers = const [];
  List<Avaliacao> _publicReviews = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadPageData();
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

  Future<void> _loadPageData() async {
    final fallback = fallbackForPrestador(widget.prestadorId);
    setState(() {
      _fallback = fallback;
      _catalog = widget.estabelecimento;
      _loadingProfile = true;
      _loadingServices = true;
      _profileError = null;
      _servicesError = null;
      _publicReviews = const [];
    });

    await Future.wait([
      _loadProfile(fallback),
      _loadServices(),
      _loadReviews(),
    ]);
  }

  Future<void> _loadProfile(ServicePublicPageFallback? fallback) async {
    try {
      final loader =
          widget.profileLoader ??
          DuckHatApi.instance.carregarEstabelecimentoPublico;
      final loaded = await loader(widget.prestadorId);
      if (!mounted) return;

      setState(() {
        _profile = fallback == null
            ? loaded
            : loaded.mergeFallback(fallback.profile);
        _loadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingProfile = false;
        _profile = _profileFromCatalog(_catalog) ?? fallback?.profile;
        _profileError = fallback == null && _profile == null
            ? error.toString().replaceFirst('Exception: ', '')
            : null;
      });
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _servicesError = null;
    });

    try {
      final catalog =
          widget.estabelecimento ??
          await DuckHatApi.instance.buscarEstabelecimentoCatalogo(
            widget.prestadorId,
          );
      if (!mounted) return;

      setState(() {
        _catalog = catalog;
        _profile ??= _profileFromCatalog(catalog);
        _offers = catalog.servicos.map(_offerFromServico).toList();
        _loadingServices = false;
      });
    } catch (catalogError) {
      try {
        final loader =
            widget.servicesLoader ??
            DuckHatApi.instance.listarServicosPorPrestador;
        final services = await loader(widget.prestadorId);
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
  }

  Future<void> _loadReviews() async {
    try {
      final loader =
          widget.reviewsLoader ??
          DuckHatApi.instance.listarAvaliacoesPublicasPorPrestador;
      final reviews = await loader(widget.prestadorId);
      if (!mounted) return;

      setState(() => _publicReviews = reviews);
    } catch (_) {
      if (!mounted) return;
      setState(() => _publicReviews = const []);
    }
  }

  EstabelecimentoPublico? get _effectiveProfile =>
      _profile ?? _profileFromCatalog(_catalog) ?? _fallback?.profile;

  int get _prestadorId =>
      _catalog?.prestadorId ?? _effectiveProfile?.id ?? widget.prestadorId;

  List<String> get _galleryImages => _fallback?.galleryImages ?? const [];

  List<ServiceReview> get _reviews => _publicReviews
      .where((review) => review.comentario?.trim().isNotEmpty ?? false)
      .map(_reviewFromAvaliacao)
      .toList();

  List<ServiceFaq> get _faqs => const [];

  ServiceExperienceData get _experience =>
      _fallback?.experience ??
      ServiceExperienceData(
        summary:
            _effectiveProfile?.descricaoPublica ??
            'Este estabelecimento ainda está ajustando sua experiência pública.',
        highlights: const [
          'Serviços, preços e duração visíveis antes do agendamento',
          'Agenda conectada aos horários disponíveis do estabelecimento',
          'Contato direto por mensagem dentro do DuckHat',
        ],
      );

  double get _averageRating {
    if (_publicReviews.isEmpty) return 0;
    final total = _publicReviews.fold<int>(0, (sum, item) => sum + item.nota);
    return total / _publicReviews.length;
  }

  EstabelecimentoPublico? _profileFromCatalog(
    EstabelecimentoCatalogo? catalog,
  ) {
    if (catalog == null) return null;
    final fallback = fallbackForPrestador(catalog.prestadorId)?.profile;

    return EstabelecimentoPublico(
      id: catalog.prestadorId,
      nome: catalog.nome,
      telefone: catalog.telefone,
      endereco: catalog.endereco,
      descricaoPublica: catalog.descricao,
      horarioAtendimento: catalog.horarioAtendimento,
      imagemCapa: fallback?.imagemCapa,
      imagemLogo: fallback?.imagemLogo,
      fotoPerfilBase64: catalog.fotoPerfilBase64,
    );
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

  ServiceReview _reviewFromAvaliacao(Avaliacao review) {
    return ServiceReview(
      name: review.clienteNome?.trim().isNotEmpty == true
          ? review.clienteNome!.trim()
          : 'Cliente DuckHat',
      rating: review.nota,
      comment: review.comentario!.trim(),
      date: _formatReviewDate(review.criadoEm),
    );
  }

  String _formatReviewDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
    if (_galleryImages.isEmpty) return;
    final safeIndex = _selectedGalleryIndex < _galleryImages.length
        ? _selectedGalleryIndex
        : 0;
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
                  child: ServiceImage(
                    source: _galleryImages[safeIndex],
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
    final profile = _effectiveProfile;
    final created = await Navigator.pushNamed(
      context,
      '/schedule-date',
      arguments: {
        'prestadorId': _prestadorId,
        'establishmentName': profile?.nome ?? '',
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
    final profile = _effectiveProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loadingProfile && profile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : profile == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _profileError ?? 'Não foi possível carregar a página.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadPageData,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              key: const PageStorageKey('service-scroll'),
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ServiceHero(
                    onBack: () => Navigator.pop(context),
                    imageSource: profile.imagemCapa,
                    bannerImagemBase64: _catalog?.bannerImagemBase64,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Column(
                      children: [
                        ServiceInfoCard(
                          onMessageTap: _openChat,
                          name: profile.nome,
                          ratingValue: _averageRating,
                          reviewCount: _publicReviews.length,
                          logoSource: profile.imagemLogo,
                          logoBase64: profile.fotoPerfilBase64,
                          address: profile.endereco,
                          schedule: profile.horarioAtendimento,
                          description: profile.descricaoPublica,
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
                          establishmentName: profile.nome,
                          experienceDescription:
                              profile.descricaoPublica ?? _experience.summary,
                          isServicesLoading: _loadingServices,
                          servicesError: _servicesError,
                          onServicesRetry: _loadPageData,
                          onBookOffer: (offer) => _openBookingFlow(
                            initialServiceId: offer.serviceId,
                          ),
                          reviews: _reviews,
                          faqs: _faqs,
                          galleryImages: _galleryImages,
                          selectedGalleryIndex: _selectedGalleryIndex,
                          galleryController: _galleryController,
                          onGalleryChanged: _onGalleryPageChanged,
                          onGallerySelected: _selectGalleryImage,
                          onOpenGallery: _openGalleryFullscreen,
                          experience: _experience,
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
