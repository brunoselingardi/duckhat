import 'package:duckhat/components/bottomnav.dart';
import 'package:duckhat/components/service/service_data.dart';
import 'package:duckhat/components/service/service_hero.dart';
import 'package:duckhat/components/service/service_info_card.dart';
import 'package:duckhat/components/service/service_sections.dart';
import 'package:duckhat/components/service/service_tab_menu.dart';
import 'package:duckhat/pages/chat.dart';
import 'package:duckhat/pages/home.dart';
import 'package:duckhat/pages/schedule.dart';
import 'package:duckhat/pages/user.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_isAutoScrolling || !mounted) {
      return;
    }

    int nearestIndex = _selectedTabIndex;
    double nearestDistance = double.infinity;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final context = _sectionKeys[i].currentContext;
      if (context == null) {
        continue;
      }

      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) {
        continue;
      }

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
    if (context == null) {
      return;
    }

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

    if (!mounted) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        _isAutoScrolling = false;
      }
    });
  }

  void _onGalleryPageChanged(int index) {
    if (index != _selectedGalleryIndex) {
      setState(() => _selectedGalleryIndex = index);
    }
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
      builder: (context) {
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
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
      return;
    }

    final page = switch (index) {
      1 => const SchedulePage(),
      2 => const ChatPage(),
      3 => const PerfilPage(),
      _ => const Home(),
    };

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: DuckHatBottomNav(
        selectedIndex: 0,
        onTap: _onBottomNavTap,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceHero(onBack: () => Navigator.pop(context)),
            Transform.translate(
              offset: const Offset(0, -28),
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
                    offers: serviceOffers,
                    reviews: serviceReviews,
                    faqs: serviceFaqs,
                    galleryImages: serviceGalleryImages,
                    selectedGalleryIndex: _selectedGalleryIndex,
                    galleryController: _galleryController,
                    onGalleryChanged: _onGalleryPageChanged,
                    onGallerySelected: (index) {
                      _selectGalleryImage(index);
                    },
                    onOpenGallery: _openGalleryFullscreen,
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
