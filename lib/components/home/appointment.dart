import 'package:flutter/material.dart';
import 'package:duckhat/components/home/appointmentcard.dart';

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
          children: const [
            Icon(Icons.schedule, color: Colors.black54),

            SizedBox(width: 8),

            Text(
              "Nenhum agendamento hoje",
              style: TextStyle(color: Colors.black54),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Agendamentos de hoje:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 12),

        /// estado vazio
        if (appointments.isEmpty)
          const EmptyAppointmentState()
        /// lista de agendamentos
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AppointmentCard(
                    time: appointment["time"],
                    service: appointment["service"],
                    place: appointment["place"],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
