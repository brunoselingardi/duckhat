class ServiceOffer {
  final String title;
  final String duration;
  final String price;
  final String description;

  const ServiceOffer({
    required this.title,
    required this.duration,
    required this.price,
    required this.description,
  });
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
