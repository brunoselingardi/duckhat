import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/models/disponibilidade_catalogo.dart';
import 'package:duckhat/models/ocupacao_prestador.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart' show AppColors;
import 'package:flutter/material.dart';

class ScheduleDatePage extends StatefulWidget {
  final int prestadorId;
  final String establishmentName;
  final List<ServiceOffer> serviceOffers;
  final int? initialServiceId;

  const ScheduleDatePage({
    super.key,
    required this.prestadorId,
    required this.establishmentName,
    required this.serviceOffers,
    this.initialServiceId,
  });

  @override
  State<ScheduleDatePage> createState() => _ScheduleDatePageState();
}

class _ScheduleDatePageState extends State<ScheduleDatePage> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  TimeSlot? _selectedTime;
  ServiceOffer? _selectedOffer;

  bool _loadingSlots = true;
  bool _saving = false;
  String? _slotsError;
  List<DisponibilidadeCatalogo> _disponibilidades = [];
  List<OcupacaoPrestador> _ocupacoes = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedOffer = _pickInitialOffer();
    _loadDisponibilidades();
  }

  ServiceOffer? _pickInitialOffer() {
    if (widget.serviceOffers.isEmpty || widget.initialServiceId == null) {
      return null;
    }

    for (final offer in widget.serviceOffers) {
      if (offer.serviceId == widget.initialServiceId) return offer;
    }
    return null;
  }

  Future<void> _loadDisponibilidades() async {
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
    });

    try {
      final results = await Future.wait([
        DuckHatApi.instance.listarDisponibilidadesPorPrestador(
          widget.prestadorId,
        ),
        DuckHatApi.instance.listarOcupacoesPorPrestador(widget.prestadorId),
      ]);
      if (!mounted) return;

      setState(() {
        _disponibilidades = results[0] as List<DisponibilidadeCatalogo>;
        _ocupacoes = results[1] as List<OcupacaoPrestador>;
        _loadingSlots = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingSlots = false;
        _slotsError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  void _selectOffer(ServiceOffer offer) {
    setState(() {
      _selectedOffer = offer;
      _selectedDate = null;
      _selectedTime = null;
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

  Future<void> _confirmAppointment() async {
    if (_selectedOffer == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _saving) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar agendamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.establishmentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_selectedOffer!.title),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} às ${_selectedTime!.time}',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final start = _selectedTime!.dateTimeFor(_selectedDate!);
    final end = start.add(Duration(minutes: _selectedOffer!.durationMin));

    setState(() => _saving = true);
    try {
      await DuckHatApi.instance.criarAgendamento(
        servicoId: _selectedOffer!.serviceId,
        inicioEm: start,
        fimEm: end,
        observacoes: 'Agendado pelo app DuckHat',
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBold),
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Agendar',
          style: TextStyle(
            color: AppColors.textBold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildServicePicker(),
              const SizedBox(height: 16),
              _buildServiceInfo(),
              const SizedBox(height: 16),
              _buildCalendar(),
              const SizedBox(height: 16),
              _buildTimeSlots(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  Widget _buildServicePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha o serviço',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecione primeiro o serviço desejado para liberar os horários disponíveis.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          if (widget.serviceOffers.isEmpty)
            const Text(
              'Nenhum serviço disponível para agendamento.',
              style: TextStyle(color: AppColors.textRegular),
            )
          else
            for (var index = 0; index < widget.serviceOffers.length; index++) ...[
              _ServiceOptionTile(
                offer: widget.serviceOffers[index],
                selected:
                    _selectedOffer?.serviceId ==
                    widget.serviceOffers[index].serviceId,
                onTap: _saving
                    ? null
                    : () => _selectOffer(widget.serviceOffers[index]),
              ),
              if (index != widget.serviceOffers.length - 1)
                const Divider(height: 18, color: Color(0xFFE8EDF6)),
            ],
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
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
            child: const Icon(Icons.content_cut, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedOffer?.title ?? 'Escolha um serviço',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBold,
                  ),
                ),
                Text(
                  widget.establishmentName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    if (_selectedOffer == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.touch_app, color: AppColors.accent),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Escolha um serviço acima para continuar com a data e o horário.',
                style: TextStyle(
                  color: AppColors.textRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textBold),
                onPressed: _saving ? null : _previousMonth,
              ),
              Text(
                _monthYearString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textBold,
                ),
                onPressed: _saving ? null : _nextMonth,
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
      'Janeiro',
      'Fevereiro',
      'Marco',
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
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  Widget _buildWeekDayHeaders() {
    const days = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map(
            (day) => SizedBox(
              width: 36,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
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

    final dayWidgets = <Widget>[];

    for (var i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 36));
    }

    for (var day = 1; day <= daysInMonth; day++) {
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
      final hasAvailability = _slotsForDate(date).any((slot) => slot.available);

      dayWidgets.add(
        GestureDetector(
          onTap: isPast || !hasAvailability || _saving
              ? null
              : () => _selectDate(date),
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
                      ? AppColors.primary
                      : (isPast || !hasAvailability
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
    if (_loadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_selectedOffer == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Icon(Icons.content_cut, size: 20, color: AppColors.textMuted),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Escolha um serviço para ver os horários.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (_slotsError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _slotsError!,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadDisponibilidades,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_selectedDate == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: AppColors.textMuted),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Selecione uma data para ver os horários.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    final slots = _slotsForDate(_selectedDate!);
    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          'Nenhum horário disponível',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios disponiveis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textBold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final isSelected = _selectedTime?.time == slot.time;
              final isAvailable = slot.available;

              return GestureDetector(
                onTap: isAvailable && !_saving
                    ? () => _selectTime(slot)
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent
                        : (isAvailable ? AppColors.primary : AppColors.inputFill),
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
                            ? AppColors.primary
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
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final canConfirm =
        _selectedOffer != null && _selectedDate != null && _selectedTime != null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canConfirm && !_saving ? _confirmAppointment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor: AppColors.textMutedLight,
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Text(
                  canConfirm
                      ? 'Confirmar Agendamento'
                      : 'Selecione serviço, data e horário',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  List<TimeSlot> _slotsForDate(DateTime date) {
    final daySlots = _disponibilidades
        .where((item) => item.ativo && item.diaSemana == date.weekday)
        .expand((item) => _slotsFromDisponibilidade(date, item))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return daySlots;
  }

  List<TimeSlot> _slotsFromDisponibilidade(
    DateTime date,
    DisponibilidadeCatalogo disponibilidade,
  ) {
    final selectedOffer = _selectedOffer;
    if (selectedOffer == null) return [];

    final start = _dateTimeWithTime(date, disponibilidade.horaInicio);
    final end = _dateTimeWithTime(date, disponibilidade.horaFim);
    final lastStart = end.subtract(Duration(minutes: selectedOffer.durationMin));
    final today = DateTime.now();

    if (lastStart.isBefore(start)) return [];

    final slots = <TimeSlot>[];
    var cursor = start;
    while (!cursor.isAfter(lastStart)) {
      final slotEnd = cursor.add(Duration(minutes: selectedOffer.durationMin));
      final hasConflict = _ocupacoes.any(
        (ocupacao) => ocupacao.overlaps(cursor, slotEnd),
      );
      final available = cursor.isAfter(today) && !hasConflict;
      slots.add(TimeSlot(start: cursor, available: available));
      cursor = cursor.add(const Duration(hours: 1));
    }

    return slots;
  }

  DateTime _dateTimeWithTime(DateTime date, String time) {
    final parts = time.split(':').map(int.parse).toList();
    return DateTime(date.year, date.month, date.day, parts[0], parts[1]);
  }
}

class TimeSlot {
  final DateTime start;
  final bool available;

  TimeSlot({required this.start, required this.available});

  String get time {
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime dateTimeFor(DateTime date) {
    return DateTime(date.year, date.month, date.day, start.hour, start.minute);
  }
}

class _ServiceOptionTile extends StatelessWidget {
  final ServiceOffer offer;
  final bool selected;
  final VoidCallback? onTap;

  const _ServiceOptionTile({
    required this.offer,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.accent.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.content_cut,
                  color: selected ? AppColors.accent : AppColors.textBold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${offer.duration} • ${offer.price}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.accent : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
