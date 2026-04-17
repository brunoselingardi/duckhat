import 'package:duckhat/components/service/service_data.dart';
import 'package:duckhat/components/service/service_hero.dart';
import 'package:duckhat/components/service/service_info_card.dart';
import 'package:duckhat/components/service/service_sections.dart';
import 'package:duckhat/pages/schedule_date.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final PageController _galleryController = PageController(
    viewportFraction: 0.42,
  );

  int _selectedTabIndex = 0;
  int _selectedGalleryIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      for (final image in serviceGalleryImages) {
        precacheImage(AssetImage(image), context);
      }
    });
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTabIndex = index);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
                    onTap: _onTabSelected,
                  ),
                  ServiceSections(
                    selectedIndex: _selectedTabIndex,
                    offers: serviceOffers,
                    reviews: serviceReviews,
                    faqs: serviceFaqs,
                    galleryImages: serviceGalleryImages,
                    selectedGalleryIndex: _selectedGalleryIndex,
                    galleryController: _galleryController,
                    onGalleryChanged: _onGalleryPageChanged,
                    onGallerySelected: _selectGalleryImage,
                    onOpenGallery: _openGalleryFullscreen,
                    onBookTap: (offer) {
                      Navigator.pushNamed(
                        context,
                        '/schedule-date',
                        arguments: {
                          'serviceName': offer.title,
                          'establishmentName': 'Barbie Dream Barber',
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/schedule-date',
            arguments: {
              'serviceName': serviceOffers.isNotEmpty
                  ? serviceOffers.first.title
                  : 'Servico',
              'establishmentName': 'Barbie Dream Barber',
            },
          );
        },
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Agendar'),
      ),
    );
  }
}
