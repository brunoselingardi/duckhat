import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<Map<String, dynamic>> appointments = [
    {
      "day": "SÁB",
      "date": "12",
      "services": [
        {"time": "14:00", "service": "Corte de Cabelo", "place": "Barbearia"},
      ],
    },
    {
      "day": "DOM",
      "date": "13",
      "services": [
        {"time": "10:00", "service": "Manicure", "place": "Salão"},
        {"time": "14:30", "service": "Pedicure", "place": "Salão"},
      ],
    },
    {
      "day": "SEG",
      "date": "14",
      "services": [
        {"time": "09:00", "service": "Massagem", "place": "Spa Zen"},
      ],
    },
    {"day": "TER", "date": "15", "services": []},
    {"day": "QUA", "date": "16", "services": []},
    {"day": "QUI", "date": "17", "services": []},
    {"day": "SEX", "date": "18", "services": []},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildCalendar(),
            const SizedBox(height: 16),
            Expanded(child: _buildAppointmentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          const Text(
            "Agenda",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final apt = appointments[index];
          final hasServices = apt["services"].isNotEmpty;
          final isSelected = index == 1;

          return Container(
            width: 50,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasServices
                    ? (isSelected ? AppColors.accent : AppColors.accentLight)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: hasServices
                  ? [
                      BoxShadow(
                        color: AppColors.accentLight.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  apt["day"],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.grayField,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  apt["date"],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.secondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final selectedDate = appointments[1];
    final services = selectedDate["services"] as List;

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: AppColors.grayField.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Nenhum agendamento",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grayField.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Clique no + para agendamento",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grayField.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service["time"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service["service"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      service["place"],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grayField,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_vert, color: AppColors.accent, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
