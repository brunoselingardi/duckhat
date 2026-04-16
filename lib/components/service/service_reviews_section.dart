import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceReviewsSection extends StatelessWidget {
  final List<ServiceReview> reviews;

  const ServiceReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avaliacoes',
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
    return RepaintBoundary(
      child: Container(
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
      ),
    );
  }
}
