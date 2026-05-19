import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceFaqSection extends StatelessWidget {
  final List<ServiceFaq> faqs;

  const ServiceFaqSection({super.key, required this.faqs});

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perguntas frequentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: themeColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          if (faqs.isEmpty)
            const _EmptyFaqs()
          else
            RepaintBoundary(
              child: Column(
                children: faqs.map((faq) => _FaqItem(faq: faq)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyFaqs extends StatelessWidget {
  const _EmptyFaqs();

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors.elevatedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: themeColors.border),
      ),
      child: Text(
        'Nenhuma pergunta frequente cadastrada.',
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: themeColors.secondaryText,
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final ServiceFaq faq;

  const _FaqItem({required this.faq});

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: themeColors.elevatedSurface,
        border: Border.all(color: themeColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: themeColors.accent,
        collapsedIconColor: themeColors.secondaryText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          faq.question,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: themeColors.primaryText,
          ),
        ),
        children: [
          Text(
            faq.answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: themeColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
