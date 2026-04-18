import 'package:flutter/material.dart';
import 'package:duckhat/components/home/rebookcard.dart';
import 'package:duckhat/theme.dart' show AppColors;

class EmptyRebookState extends StatelessWidget {
  const EmptyRebookState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: AppColors.textMuted),
            const SizedBox(height: 6),
            Text(
              "Você ainda não possui serviços recentes",
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class RebookSection extends StatelessWidget {
  final List rebookServices;

  const RebookSection({super.key, required this.rebookServices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Agende novamente:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (rebookServices.isEmpty)
          const EmptyRebookState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: rebookServices.length,
            itemBuilder: (context, index) {
              final service = rebookServices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RebookCard(
                  name: service["name"],
                  image: service["image"],
                  rating: (service["rating"] ?? 0).toDouble(),
                  reviews: service["reviews"] ?? 0,
                ),
              );
            },
          ),
      ],
    );
  }
}
