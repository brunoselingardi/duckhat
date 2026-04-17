import 'package:duckhat/theme.dart' show AppColors;
import 'package:flutter/material.dart';

class ScheduleDatePage extends StatefulWidget {
  final String serviceName;
  final String establishmentName;

  const ScheduleDatePage({
    super.key,
    required this.serviceName,
    required this.establishmentName,
  });

  @override
  State<ScheduleDatePage> createState() => _ScheduleDatePageState();
}

class _ScheduleDatePageState extends State<ScheduleDatePage> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  TimeSlot? _selectedTime;

  final List<TimeSlot> _availableSlots = [
    TimeSlot(time: '08:00', available: true),
    TimeSlot(time: '09:00', available: true),
    TimeSlot(time: '10:00', available: true),
    TimeSlot(time: '11:00', available: false),
    TimeSlot(time: '12:00', available: true),
    TimeSlot(time: '13:00', available: true),
    TimeSlot(time: '14:00', available: true),
    TimeSlot(time: '15:00', available: true),
    TimeSlot(time: '16:00', available: false),
    TimeSlot(time: '17:00', available: true),
    TimeSlot(time: '18:00', available: true),
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });
  }

  void _selectTime(TimeSlot slot) {
    if (slot.available) {
      setState(() => _selectedTime = slot);
    }
  }

  void _confirmAppointment() {
    if (_selectedDate == null || _selectedTime == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirmar Agendamento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.establishmentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.serviceName),
            const SizedBox(height: 8),
            Text(
              "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} às ${_selectedTime!.time}",
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancelar",
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Agendar",
          style: TextStyle(
            color: AppColors.textBold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildServiceInfo(),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 16),
          Expanded(child: _buildTimeSlots()),
        ],
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.content_cut, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBold,
                  ),
                ),
                Text(
                  widget.establishmentName,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.textBold),
                onPressed: _previousMonth,
              ),
              Text(
                _monthYearString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.textBold),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildWeekDayHeaders(),
          const SizedBox(height: 4),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  String _monthYearString() {
    const months = [
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro",
    ];
    return "${months[_currentMonth.month - 1]} ${_currentMonth.year}";
  }

  Widget _buildWeekDayHeaders() {
    const days = ["D", "S", "T", "Q", "Q", "S", "S"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map(
            (day) => SizedBox(
              width: 36,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 36));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected =
          _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;
      final isPast = date.isBefore(todayMidnight);
      final isToday =
          date.year == todayMidnight.year &&
          date.month == todayMidnight.month &&
          date.day == todayMidnight.day;

      dayWidgets.add(
        GestureDetector(
          onTap: isPast ? null : () => _selectDate(date),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent
                  : (isToday
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.accent, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isPast
                            ? AppColors.textMutedLight
                            : AppColors.textBold),
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 4, children: dayWidgets);
  }

  Widget _buildTimeSlots() {
    if (_selectedDate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              "Selecione uma data",
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final availableSlots = _availableSlots.where((s) => s.available).toList();
    if (availableSlots.isEmpty) {
      return Center(
        child: Text(
          "Nenhum horário disponível",
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horarios disponiveis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textBold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _availableSlots.length,
              itemBuilder: (context, index) {
                final slot = _availableSlots[index];
                final isSelected = _selectedTime?.time == slot.time;
                final isAvailable = slot.available;

                return GestureDetector(
                  onTap: isAvailable ? () => _selectTime(slot) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent
                          : (isAvailable ? Colors.white : AppColors.inputFill),
                      borderRadius: BorderRadius.circular(8),
                      border: isAvailable && !isSelected
                          ? Border.all(color: AppColors.border)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        slot.time,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isAvailable
                                    ? AppColors.textBold
                                    : AppColors.textMuted),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final canConfirm = _selectedDate != null && _selectedTime != null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canConfirm ? _confirmAppointment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor: AppColors.textMutedLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            canConfirm ? "Confirmar Agendamento" : "Selecione data e horário",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class TimeSlot {
  final String time;
  final bool available;

  TimeSlot({required this.time, required this.available});
}
