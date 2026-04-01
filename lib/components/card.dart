import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String name;
  final double rating;
  final String image;
  final double distance;
  final List<String> tags;

  const ServiceCard({
    super.key,
    required this.name,
    required this.rating,
    required this.image,
    required this.distance,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Color.fromRGBO(58, 127, 213, 0.5),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGEM + RATING
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  image,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),

              Positioned(top: 12, right: 12, child: _ratingBadge()),
            ],
          ),

          /// INFORMAÇÕES
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text("${distance.toStringAsFixed(1)} km"),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: tags.map((tag) => _tag(tag)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Color.fromRGBO(45, 34, 91, 0.3)),
        ],
      ),

      child: Row(
        children: [
          Image.asset("assets/niceduck.png", height: 18),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(223, 236, 255, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(74, 111, 165, 1),
        ),
      ),
    );
  }
}
