import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopSchedulePage extends StatefulWidget {
  const ShopSchedulePage({super.key});

  @override
  State<ShopSchedulePage> createState() => _ShopSchedulePageState();
}

class _ShopSchedulePageState extends State<ShopSchedulePage> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  final List<String> _weekdayHeaders = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
  ];

  List<DateTime?> _visibleDays = [];
  final Map<DateTime, List<_Appointment>> _appointmentsByDay = {};
  final Set<DateTime> _blockedTimes = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = now;
    _generateVisibleDays();
    _loadMockAppointments();
  }

  void _generateVisibleDays() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7;

    _visibleDays = [];
    for (int i = 0; i < startOffset; i++) {
      _visibleDays.add(null);
    }
    for (int i = 1; i <= lastDay.day; i++) {
      _visibleDays.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
  }

  void _loadMockAppointments() {
    final now = DateTime.now();
    _appointmentsByDay[DateTime(now.year, now.month, now.day)] = [
      _Appointment(
        time: '09:00',
        client: 'João Silva',
        service: 'Corte + Barba',
        status: 'confirmed',
      ),
      _Appointment(
        time: '10:30',
        client: 'Pedro Santos',
        service: 'Corte',
        status: 'confirmed',
      ),
      _Appointment(
        time: '14:00',
        client: 'Maria Costa',
        service: 'Manicure',
        status: 'pending',
      ),
    ];

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _appointmentsByDay[tomorrow] = [
      _Appointment(
        time: '09:00',
        client: 'Carlos Lima',
        service: 'Barba',
        status: 'confirmed',
      ),
      _Appointment(
        time: '11:00',
        client: 'Ana Paula',
        service: 'Pedicure',
        status: 'confirmed',
      ),
    ];
  }

  List<_Appointment> _appointmentsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _appointmentsByDay[normalized] ?? [];
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _generateVisibleDays();
    });
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildCalendarCard(),
            if (_selectedDate != null) _buildSelectedDaySection(),
            Expanded(child: _buildTimeSlots()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _monthLabel(_currentMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.accent),
                onPressed: () => _changeMonth(-1),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.accent),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _weekdayHeaders
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemCount: _visibleDays.length,
            itemBuilder: (context, index) {
              final day = _visibleDays[index];
              if (day == null) return const SizedBox.shrink();
              return _buildDayCell(day);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    final selected = _selectedDate != null && _isSameDay(day, _selectedDate!);
    final today = DateTime.now();
    final isToday = _isSameDay(day, today);
    final isCurrentMonth = day.month == _currentMonth.month;
    final dayItems = _appointmentsForDay(day);
    final hasItems = dayItems.isNotEmpty;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent
              : hasItems
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.primary.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : isToday
                ? AppColors.accentLight
                : AppColors.primary.withValues(alpha: 0),
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? AppColors.primary
                    : isCurrentMonth
                    ? AppColors.textBold
                    : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: hasItems
                    ? (selected ? AppColors.primary : AppColors.accent)
                    : AppColors.primary.withValues(alpha: 0),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDaySection() {
    final selected = _selectedDate ?? DateTime.now();
    final dayAppointments = _appointmentsForDay(selected);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDayLabel(selected),
                  style: const TextStyle(
                    color: AppColors.textBold,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${dayAppointments.length} agendamento${dayAppointments.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showBlockDialog(context),
            icon: const Icon(Icons.block, size: 18),
            label: const Text('Bloquear'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    final hours = [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
    ];
    final dayAppointments = _selectedDate != null
        ? _appointmentsForDay(_selectedDate!)
        : [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final time = hours[index];
        final appointment = dayAppointments
            .where((a) => a.time == time)
            .firstOrNull;
        final isBlocked = _blockedTimes.contains(
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            index + 8,
          ),
        );

        return _TimeSlotCard(
          time: time,
          appointment: appointment,
          isBlocked: isBlocked,
          onBlockToggle: () => _toggleBlock(
            DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              index + 8,
            ),
          ),
          onReschedule: () => _showRescheduleDialog(context, appointment!),
        );
      },
    );
  }

  void _showRescheduleDialog(BuildContext context, _Appointment appointment) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    int selectedHour = 9;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Remarcar Agendamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${appointment.client}'),
              Text('Serviço: ${appointment.service}'),
              const SizedBox(height: 16),
              const Text(
                'Selecione a nova data e horário:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (date != null) {
                            setDialogState(() => selectedDate = date);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedHour,
                          isExpanded: true,
                          items: List.generate(11, (i) => i + 8)
                              .map(
                                (h) => DropdownMenuItem(
                                  value: h,
                                  child: Text(
                                    '${h.toString().padLeft(2, '0')}:00',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => selectedHour = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'O cliente receberá uma notificação e precisará aceitar a nova data.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Agendamento remarcado para ${selectedDate.day}/${selectedDate.month} às ${selectedHour.toString().padLeft(2, '0')}:00',
                    ),
                  ),
                );
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _blockEntireDay() {
    if (_selectedDate == null) return;
    final hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
    setState(() {
      for (final hour in hours) {
        _blockedTimes.add(
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            hour,
          ),
        );
      }
    });
  }

  void _toggleBlock(DateTime time) {
    setState(() {
      if (_blockedTimes.contains(time)) {
        _blockedTimes.remove(time);
      } else {
        _blockedTimes.add(time);
      }
    });
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bloquear Dia'),
        content: const Text(
          'Deseja bloquear este dia para novos agendamentos? Todos os horários ficarão bloqueados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _blockEntireDay();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Dia bloqueado')));
            },
            child: const Text(
              'Bloquear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _selectedDayLabel(DateTime date) {
    const weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _Appointment {
  final String time;
  final String client;
  final String service;
  final String status;

  _Appointment({
    required this.time,
    required this.client,
    required this.service,
    required this.status,
  });
}

class _TimeSlotCard extends StatelessWidget {
  final String time;
  final _Appointment? appointment;
  final bool isBlocked;
  final VoidCallback onBlockToggle;
  final VoidCallback? onReschedule;

  const _TimeSlotCard({
    required this.time,
    this.appointment,
    required this.isBlocked,
    required this.onBlockToggle,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlocked) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Bloqueado',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.lock_open),
              color: AppColors.error,
              onPressed: onBlockToggle,
            ),
          ],
        ),
      );
    }

    if (appointment == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAlt,
              ),
            ),
            const SizedBox(width: 16),
            Text('Disponível', style: TextStyle(color: AppColors.success)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.block),
              color: AppColors.textMuted,
              onPressed: onBlockToggle,
            ),
          ],
        ),
      );
    }

    final isConfirmed = appointment!.status == 'confirmed';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment!.client,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkAlt,
                  ),
                ),
                Text(
                  appointment!.service,
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
          if (appointment != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_calendar, size: 20),
              color: AppColors.accent,
              onPressed: onReschedule,
              tooltip: 'Remarcar',
            ),
          ],
        ],
      ),
    );
  }
}
