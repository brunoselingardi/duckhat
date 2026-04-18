import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceServicesSection extends StatelessWidget {
  final List<ServiceOffer> offers;
  final void Function(ServiceOffer offer)? onBookTap;

  const ServiceServicesSection({
    super.key,
    required this.offers,
    this.onBookTap,
  });

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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: offers.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 28, color: Color(0xFFE8EDF6)),
            itemBuilder: (context, index) => _ServiceRow(
              offer: offers[index],
              onBookTap: onBookTap != null
                  ? () => onBookTap!(offers[index])
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final ServiceOffer offer;
  final VoidCallback? onBookTap;

  const _ServiceRow({required this.offer, this.onBookTap});

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
              onPressed: onBookTap,
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
