import 'package:duckhat/components/service/service_data.dart';
import 'package:duckhat/components/service/service_experience_section.dart';
import 'package:duckhat/components/service/service_faq_section.dart';
import 'package:duckhat/components/service/service_gallery_section.dart';
import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/components/service/service_reviews_section.dart';
import 'package:duckhat/components/service/service_services_section.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceTabMenu extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const ServiceTabMenu({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return InkWell(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textBold
                              : AppColors.textRegular,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8EDF6)),
        ],
      ),
    );
  }
}

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
  final void Function(ServiceOffer offer)? onBookTap;

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
    this.onBookTap,
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
        children: [
          ServiceExperienceSection(key: sectionKeys[0]),
          const Divider(height: 1, color: Color(0xFFE8EDF6)),
          ServiceServicesSection(
            key: sectionKeys[1],
            offers: offers,
            onBookTap: onBookTap,
          ),
          const Divider(height: 1, color: Color(0xFFE8EDF6)),
          ServiceGallerySection(
            key: sectionKeys[2],
            images: galleryImages,
            selectedIndex: selectedGalleryIndex,
            controller: galleryController,
            onChanged: onGalleryChanged,
            onSelected: onGallerySelected,
            onOpenGallery: onOpenGallery,
          ),
          const Divider(height: 1, color: Color(0xFFE8EDF6)),
          ServiceReviewsSection(key: sectionKeys[3], reviews: reviews),
          const Divider(height: 1, color: Color(0xFFE8EDF6)),
          ServiceFaqSection(key: sectionKeys[4], faqs: faqs),
        ],
      ),
    );
  }
}
