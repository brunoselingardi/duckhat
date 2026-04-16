import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/theme.dart';
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
          _ExperienceSection(key: sectionKeys[0]),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          _ServicesSection(key: sectionKeys[1], offers: offers),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          _GallerySection(
            key: sectionKeys[2],
            images: galleryImages,
            selectedIndex: selectedGalleryIndex,
            controller: galleryController,
            onChanged: onGalleryChanged,
            onSelected: onGallerySelected,
            onOpenGallery: onOpenGallery,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          _ReviewsSection(key: sectionKeys[3], reviews: reviews),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF6)),
          _FaqSection(key: sectionKeys[4], faqs: faqs),
        ],
      ),
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Experiencia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Um espaco criativo com energia pop e atendimento premium para quem quer um visual impecavel, moderno e cheio de presenca.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Destaques',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 14),
          const _BulletLine(
            'Visual Barbiecore reinterpretado para o universo masculino',
          ),
          const _BulletLine('Equipe focada em imagem, acabamento e identidade'),
          const _BulletLine('Ambiente instagramavel com experiencia premium'),
          const SizedBox(height: 22),
          const Text(
            'Formatos de atendimento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 14),
          const _InfoLine(
            icon: Icons.storefront_outlined,
            title: 'Presencial',
            subtitle: 'Atendimento na unidade conceito com estrutura completa.',
          ),
          const SizedBox(height: 12),
          const _InfoLine(
            icon: Icons.chat_outlined,
            title: 'Curadoria por mensagem',
            subtitle:
                'Converse antes e alinhe o look ideal para o seu horario.',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF3EFE8),
                foregroundColor: AppColors.textBold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mostrar mais detalhes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final List<ServiceOffer> offers;

  const _ServicesSection({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servicos e precos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 18),
          for (int index = 0; index < offers.length; index++) ...[
            _ServiceRow(offer: offers[index]),
            if (index != offers.length - 1)
              const Divider(height: 28, color: Color(0xFFE8EDF6)),
          ],
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final ServiceOffer offer;

  const _ServiceRow({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  offer.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textRegular,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.duration,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 136,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF3EFE8),
                foregroundColor: AppColors.textBold,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Agendar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final PageController controller;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenGallery;

  const _GallerySection({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.controller,
    required this.onChanged,
    required this.onSelected,
    required this.onOpenGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Galeria',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onOpenGallery,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 1.35,
                child: Image.asset(images[selectedIndex], fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: PageView.builder(
              controller: controller,
              onPageChanged: onChanged,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(images[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final List<ServiceReview> reviews;

  const _ReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avaliações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) =>
                  _ReviewCard(review: reviews[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ServiceReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB547),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                review.rating,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBold,
                ),
              ),
              const Spacer(),
              Text(
                review.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textRegular,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            review.comment,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textBold,
            ),
          ),
          const Spacer(),
          Text(
            review.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textRegular,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final List<ServiceFaq> faqs;

  const _FaqSection({super.key, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perguntas frequentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 12),
          ...faqs.map((faq) => _FaqItem(faq: faq)),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final ServiceFaq faq;

  const _FaqItem({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8EDF6)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: AppColors.accent,
        collapsedIconColor: AppColors.textRegular,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textBold,
          ),
        ),
        children: [
          Text(
            faq.answer,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textRegular,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: AppColors.textBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.textRegular,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
