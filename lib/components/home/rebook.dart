import 'package:flutter/material.dart';
import 'package:duckhat/components/home/rebookcard.dart';
import 'package:duckhat/theme.dart' show AppThemeColors;

class EmptyRebookState extends StatelessWidget {
  final String message;

  const EmptyRebookState({
    super.key,
    this.message = 'Você ainda não possui serviços recentes',
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: themeColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: themeColors.mutedText),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(color: themeColors.mutedText),
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
    final themeColors = AppThemeColors.of(context);

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
              color: themeColors.primaryText,
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
                      prestadorId: service["prestadorId"],
                      image: service["image"],
                      rating: service["rating"] == null
                          ? null
                          : (service["rating"] as num).toDouble(),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
