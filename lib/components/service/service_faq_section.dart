import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceFaqSection extends StatelessWidget {
  final List<ServiceFaq> faqs;

  const ServiceFaqSection({super.key, required this.faqs});

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
