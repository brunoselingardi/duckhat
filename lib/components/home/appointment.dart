import 'package:flutter/material.dart';
import 'package:duckhat/components/home/appointmentcard.dart';
import 'package:duckhat/theme.dart' show AppColors;

class EmptyAppointmentState extends StatelessWidget {
  const EmptyAppointmentState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              "Nenhum agendamento hoje",
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentSection extends StatelessWidget {
  final List appointments;

  const AppointmentSection({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Agendamentos de hoje:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (appointments.isEmpty)
          const EmptyAppointmentState()
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final appointment in appointments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppointmentCard(
                      time: appointment["time"],
                      service: appointment["service"],
                      place: appointment["place"],
                      image: appointment["image"],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
