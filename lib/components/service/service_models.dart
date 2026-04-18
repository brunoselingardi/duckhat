class ServiceOffer {
  final int serviceId;
  final int prestadorId;
  final String title;
  final String description;
  final int durationMin;
  final double priceValue;

  const ServiceOffer({
    required this.serviceId,
    required this.prestadorId,
    required this.title,
    required this.description,
    required this.durationMin,
    required this.priceValue,
  });

  String get duration {
    if (durationMin >= 60) {
      final hours = durationMin ~/ 60;
      final minutes = durationMin % 60;
      if (minutes == 0) return '${hours}h';
      return '${hours}h $minutes min';
    }

    return '$durationMin min';
  }

  String get price {
    final normalized = priceValue.toStringAsFixed(2).replaceAll('.', ',');
    final withoutCents = normalized.endsWith(',00')
        ? normalized.substring(0, normalized.length - 3)
        : normalized;

    return 'R\$ $withoutCents';
  }
}

class ServiceReview {
  final String name;
  final String rating;
  final String comment;
  final String date;

  const ServiceReview({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class ServiceFaq {
  final String question;
  final String answer;

  const ServiceFaq({required this.question, required this.answer});
}
