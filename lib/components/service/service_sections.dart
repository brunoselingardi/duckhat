import 'package:duckhat/components/service/service_experience_section.dart';
import 'package:duckhat/components/service/service_faq_section.dart';
import 'package:duckhat/components/service/service_gallery_section.dart';
import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/components/service/service_profile_fallbacks.dart';
import 'package:duckhat/components/service/service_reviews_section.dart';
import 'package:duckhat/components/service/service_services_section.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceSections extends StatelessWidget {
  final List<GlobalKey> sectionKeys;
  final List<ServiceOffer> offers;
  final String establishmentName;
  final String experienceDescription;
  final bool isServicesLoading;
  final String? servicesError;
  final VoidCallback? onServicesRetry;
  final ValueChanged<ServiceOffer>? onBookOffer;
  final List<ServiceReview> reviews;
  final List<ServiceFaq> faqs;
  final List<String> galleryImages;
  final int selectedGalleryIndex;
  final PageController galleryController;
  final ValueChanged<int> onGalleryChanged;
  final ValueChanged<int> onGallerySelected;
  final VoidCallback onOpenGallery;
  final ServiceExperienceData experience;

  const ServiceSections({
    super.key,
    required this.sectionKeys,
    required this.offers,
    required this.establishmentName,
    required this.experienceDescription,
    this.isServicesLoading = false,
    this.servicesError,
    this.onServicesRetry,
    this.onBookOffer,
    required this.reviews,
    required this.faqs,
    required this.galleryImages,
    required this.selectedGalleryIndex,
    required this.galleryController,
    required this.onGalleryChanged,
    required this.onGallerySelected,
    required this.onOpenGallery,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          ServiceExperienceSection(
            key: sectionKeys[0],
            summary: experience.summary,
            highlights: experience.highlights,
          ),
          Divider(height: 1, color: themeColors.border),
          ServiceServicesSection(
            key: sectionKeys[1],
            offers: offers,
            isLoading: isServicesLoading,
            error: servicesError,
            onRetry: onServicesRetry,
            onBookOffer: onBookOffer,
          ),
          Divider(height: 1, color: themeColors.border),
          ServiceGallerySection(
            key: sectionKeys[2],
            images: galleryImages,
            selectedIndex: selectedGalleryIndex,
            controller: galleryController,
            onChanged: onGalleryChanged,
            onSelected: onGallerySelected,
            onOpenGallery: onOpenGallery,
          ),
          Divider(height: 1, color: themeColors.border),
          ServiceReviewsSection(key: sectionKeys[3], reviews: reviews),
          Divider(height: 1, color: themeColors.border),
          ServiceFaqSection(key: sectionKeys[4], faqs: faqs),
        ],
      ),
    );
  }
}
