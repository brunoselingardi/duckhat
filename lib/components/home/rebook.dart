import 'package:flutter/material.dart';
import 'package:duckhat/components/home/rebookcard.dart';
import 'package:duckhat/theme.dart' show AppColors;

class EmptyRebookState extends StatelessWidget {
  final String message;

  const EmptyRebookState({super.key, this.message = 'Você ainda não possui serviços recentes'});

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
              message,
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RebookSection extends StatelessWidget {
  final List rebookServices;
  final String title;
  final String emptyMessage;

  const RebookSection({
    super.key,
    required this.rebookServices,
    this.title = 'Agende novamente:',
    this.emptyMessage = 'Você ainda não possui serviços recentes',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (rebookServices.isEmpty)
          EmptyRebookState(message: emptyMessage)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final service in rebookServices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RebookCard(
                      name: service["name"],
                      image: service["image"],
                      rating: (service["rating"] ?? 0).toDouble(),
                      reviews: service["reviews"] ?? 0,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
