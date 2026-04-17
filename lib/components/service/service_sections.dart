import 'package:duckhat/components/service/service_experience_section.dart';
import 'package:duckhat/components/service/service_faq_section.dart';
import 'package:duckhat/components/service/service_gallery_section.dart';
import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/components/service/service_reviews_section.dart';
import 'package:duckhat/components/service/service_services_section.dart';
import 'package:flutter/material.dart';

class ServiceSections extends StatelessWidget {
  final List<GlobalKey> sectionKeys;
  final List<ServiceOffer> offers;
  final List<ServiceReview> reviews;
  final List<ServiceFaq> faqs;
  final List<String> galleryImages;
  final int selectedGalleryIndex;
  final PageController galleryController;
  final ValueChanged<int> onGalleryChanged;
  final ValueChanged<int> onGallerySelected;
  final VoidCallback onOpenGallery;

  const ServiceSections({
    super.key,
    required this.sectionKeys,
    required this.offers,
    required this.reviews,
    required this.faqs,
    required this.galleryImages,
    required this.selectedGalleryIndex,
    required this.galleryController,
    required this.onGalleryChanged,
    required this.onGallerySelected,
    required this.onOpenGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceExperienceSection(key: sectionKeys[0]),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          ServiceServicesSection(key: sectionKeys[1], offers: offers),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          ServiceGallerySection(
            key: sectionKeys[2],
            images: galleryImages,
            selectedIndex: selectedGalleryIndex,
            controller: galleryController,
            onChanged: onGalleryChanged,
            onSelected: onGallerySelected,
            onOpenGallery: onOpenGallery,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          ServiceReviewsSection(key: sectionKeys[3], reviews: reviews),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          ServiceFaqSection(key: sectionKeys[4], faqs: faqs),
        ],
      ),
    );
  }
}
