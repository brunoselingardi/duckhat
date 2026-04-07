import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String time;
  final String service;
  final String place;

  const AppointmentCard({
    super.key,
    required this.time,
    required this.service,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(128, 194, 248, 0.4),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// horário
          Text(
            time,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          /// serviço
          Text(service, style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 4),

          /// estabelecimento
          Text(
            place,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
