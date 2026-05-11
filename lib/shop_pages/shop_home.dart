import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopHomePage extends StatefulWidget {
  final VoidCallback? onNavigateToSchedule;

  const ShopHomePage({super.key, this.onNavigateToSchedule});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildAppointmentsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    final weekdays = [
      'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá,',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          const Text(
            'Barbearia Silva',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weekdays[_selectedDate.weekday - 1]}, ${_selectedDate.day} de ${months[_selectedDate.month - 1]}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Selecione o dia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = _isSameDay(day, _selectedDate);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? null : Border.all(color: AppColors.border),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        [
                          'Seg',
                          'Ter',
                          'Qua',
                          'Qui',
                          'Sex',
                          'Sáb',
                          'Dom',
                        ][day.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.darkAlt,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildAppointmentsList() {
    final appointments = [
      {
        'time': '09:00',
        'client': 'João Silva',
        'service': 'Corte + Barba',
        'status': 'confirmed',
      },
      {
        'time': '10:30',
        'client': 'Pedro Santos',
        'service': 'Corte Masculino',
        'status': 'confirmed',
      },
      {
        'time': '11:00',
        'client': 'Maria Costa',
        'service': 'Manicure',
        'status': 'pending',
      },
      {
        'time': '14:00',
        'client': 'Carlos Lima',
        'service': 'Barba',
        'status': 'confirmed',
      },
      {
        'time': '15:30',
        'client': 'Ana Paula',
        'service': 'Pedicure',
        'status': 'pending',
      },
      {
        'time': '16:30',
        'client': 'Roberto Alves',
        'service': 'Corte + Barba',
        'status': 'confirmed',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agendamentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAlt,
                ),
              ),
              Text(
                '${appointments.length} hoje',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...appointments.map(
            (apt) => _AppointmentCard(
              time: apt['time']!,
              client: apt['client']!,
              service: apt['service']!,
              status: apt['status']!,
              onReschedule: widget.onNavigateToSchedule,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String time;
  final String client;
  final String service;
  final String status;
  final VoidCallback? onReschedule;

  const _AppointmentCard({
    required this.time,
    required this.client,
    required this.service,
    required this.status,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == 'confirmed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkAlt,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service,
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isConfirmed ? 'Confirmado' : 'Pendente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isConfirmed ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          if (!isConfirmed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Confirmar',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                    onTap: () => _onConfirm(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Remarcar',
                    icon: Icons.schedule,
                    color: AppColors.accent,
                    onTap: () => _onReschedule(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _onConfirm(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendamento de $client confirmado!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onReschedule(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Toque no horário desejado na Agenda para remarcar o agendamento de $client'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'IR PARA AGENDA',
          textColor: Colors.white,
          onPressed: onReschedule ?? () {},
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RescheduleSheet extends StatefulWidget {
  final String client;

  const _RescheduleSheet({required this.client});

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  final Map<String, List<String>> _availableSchedule = {
    'segunda': ['09:00', '10:00', '14:00', '15:00', '16:00'],
    'terça': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'],
    'quarta': ['09:00', '10:00', '14:00', '15:00'],
    'quinta': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'],
    'sexta': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00', '18:00'],
    'sábado': ['09:00', '10:00', '11:00'],
  };

  int? _selectedDayIndex;
  String? _selectedTime;
  final List<int> _workingDays = [1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final weekdays = ['segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'];
    final months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final today = DateTime.now();
    final nextDays = <Map<String, dynamic>>[];

    for (int i = 1; i <= 30; i++) {
      final date = today.add(Duration(days: i));
      if (_workingDays.contains(date.weekday)) {
        nextDays.add({
          'date': date,
          'weekday': weekdays[date.weekday - 1],
          'day': date.day,
          'month': months[date.month - 1],
        });
      }
    }

    final availableDays = nextDays.toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Remarcar para ${widget.client}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAlt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Selecione o dia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableDays.length,
              itemBuilder: (context, index) {
                final day = availableDays[index];
                final isSelected = _selectedDayIndex == index;
                final weekdayName = day['weekday'] as String;
                final times = _availableSchedule[weekdayName] ?? [];
                final monthName = day['month'] as String;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                      _selectedTime = null;
                    });
                  },
                  child: Container(
                    width: 56,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdayName.substring(0, 3),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day['day']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.darkAlt,
                          ),
                        ),
                        Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedDayIndex != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Selecione o horário',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_availableSchedule[availableDays[_selectedDayIndex!]['weekday']] ?? [])
                  .map((time) => _TimeChip(
                        time: time,
                        isSelected: _selectedTime == time,
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedDayIndex != null && _selectedTime != null
                  ? () {
                      final day = availableDays[_selectedDayIndex!];
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agendamento remarcado para ${day['day']} de ${day['month']} às $_selectedTime'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirmar remarcação',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.darkAlt,
          ),
        ),
      ),
    );
  }
}
