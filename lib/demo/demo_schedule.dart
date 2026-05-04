import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class DemoSchedulePage extends StatefulWidget {
  const DemoSchedulePage({super.key});

  @override
  State<DemoSchedulePage> createState() => _DemoSchedulePageState();
}

class _DemoSchedulePageState extends State<DemoSchedulePage> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  final List<String> _weekdayHeaders = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
  List<DateTime?> _visibleDays = [];

  final Map<DateTime, List<_DemoAppointment>> _appointmentsByDay = {};

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
      _DemoAppointment(
        time: '09:00',
        service: 'Corte de cabelo',
        place: 'Barbie\'s Salon',
        status: 'CONFIRMADO',
      ),
      _DemoAppointment(
        time: '14:30',
        service: 'Manicure',
        place: 'Salão Beleza',
        status: 'PENDENTE',
      ),
    ];

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _appointmentsByDay[tomorrow] = [
      _DemoAppointment(
        time: '10:00',
        service: 'Barba',
        place: 'James Salon',
        status: 'CONFIRMADO',
      ),
    ];
  }

  List<_DemoAppointment> _appointmentsForDay(DateTime day) {
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

  String _selectedDayLabel(DateTime date) {
    const weekdays = [
      'domingo',
      'segunda',
      'terça',
      'quarta',
      'quinta',
      'sexta',
      'sábado',
    ];
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return '${weekdays[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildOverviewCard()),
            SliverToBoxAdapter(child: _buildCalendarCard()),
            if (_selectedDate != null)
              SliverToBoxAdapter(child: _buildSelectedDaySection()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: _buildAppointmentsSliver(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textBold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Acompanhe seus horários e toque no dia para ver os compromissos.',
            style: TextStyle(fontSize: 13, color: AppColors.textRegular),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowAccent,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.event_note, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 compromissos ativos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text('2 neste mês', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        style: const TextStyle(
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
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
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
    final hasActiveItems = dayItems.any((item) => item.status != 'CANCELADO');

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent
              : hasActiveItems
              ? AppColors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : isToday
                ? AppColors.accentLight
                : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : isCurrentMonth
                    ? AppColors.textBold
                    : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: hasItems
                    ? (selected ? Colors.white : AppColors.accent)
                    : Colors.transparent,
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
    final itemCount = _appointmentsForDay(selected).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
            '$itemCount compromisso${itemCount == 1 ? '' : 's'} nesta data',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildAppointmentsSliver() {
    final items = _selectedDate != null
        ? _appointmentsForDay(_selectedDate!)
        : [];

    if (items.isEmpty) {
      return SliverList.list(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 54,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 14),
                Text(
                  'Nenhum agendamento nesta data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textBold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Escolha outro dia no calendário para consultar seus horários.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: AppColors.textBold,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.service,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.place,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusChip(status: item.status),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DemoAppointment {
  final String time;
  final String service;
  final String place;
  final String status;

  _DemoAppointment({
    required this.time,
    required this.service,
    required this.place,
    required this.status,
  });
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'CONFIRMADO' => Colors.green,
      'CANCELADO' => Colors.redAccent,
      'CONCLUIDO' => Colors.grey,
      _ => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
