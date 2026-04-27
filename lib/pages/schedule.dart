import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../core/app_route.dart';
import '../pages/appointment_detail.dart';
import '../services/duckhat_api.dart';
import '../theme.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _api = DuckHatApi.instance;

  bool _loading = true;
  String? _error;
  List<Agendamento> _agendamentos = [];
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  int _lastSyncRevision = 0;

  bool get _isPrestador => _api.isPrestador;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _lastSyncRevision = _api.agendamentoSync.value.revision;
    _api.agendamentoSync.addListener(_handleAgendamentoSync);
    _carregarAgendamentos();
  }

  @override
  void dispose() {
    _api.agendamentoSync.removeListener(_handleAgendamentoSync);
    super.dispose();
  }

  Future<void> _carregarAgendamentos({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _error = null);
    }

    try {
      final items =
          await (_isPrestador
                ? _api.listarAgendamentosPrestador()
                : _api.listarAgendamentos())
            ..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));

      final initialDate = _pickInitialDate(items);

      if (!mounted) return;

      setState(() {
        _agendamentos = items;
        _selectedDate = _selectedDate == null
            ? initialDate
            : _normalizeSelection();
        _currentMonth = DateTime(
          (_selectedDate ?? initialDate).year,
          (_selectedDate ?? initialDate).month,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _prettyError(e);
        _loading = false;
      });
    }
  }

  void _handleAgendamentoSync() {
    final signal = _api.agendamentoSync.value;
    if (signal.revision == _lastSyncRevision || !mounted) return;
    _lastSyncRevision = signal.revision;

    if (signal.focusDate != null) {
      final focusDate = _dateOnly(signal.focusDate!);
      setState(() {
        _selectedDate = focusDate;
        _currentMonth = DateTime(focusDate.year, focusDate.month);
      });
    }

    _carregarAgendamentos(showLoader: false);
  }

  List<Agendamento> get _selectedDayAppointments {
    final selected = _selectedDate ?? _dateOnly(DateTime.now());

    return _agendamentos
        .where((item) => _isSameDay(item.inicioEm, selected))
        .toList()
      ..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));
  }

  int get _upcomingCount {
    final now = DateTime.now();
    return _agendamentos
        .where((item) => item.status != 'CANCELADO' && item.fimEm.isAfter(now))
        .length;
  }

  int get _currentMonthCount {
    return _agendamentos.where((item) {
      return item.inicioEm.year == _currentMonth.year &&
          item.inicioEm.month == _currentMonth.month &&
          item.status != 'CANCELADO';
    }).length;
  }

  Future<void> _abrirDetalheAgendamento(Agendamento agendamento) async {
    final changed = await Navigator.of(context).push<bool>(
      AppRoute(
        builder: (_) => AppointmentDetailPage(
          agendamento: agendamento,
          onCancel: !_isPrestador
              ? (item) async {
                  await _api.cancelarAgendamento(item.id);
                }
              : null,
        ),
      ),
    );

    if (changed == true && mounted) {
      _showSnackBar('Agendamento atualizado.');
    }
  }

  Future<void> _confirmarAgendamento(Agendamento agendamento) async {
    try {
      await _api.confirmarAgendamento(agendamento.id);
      if (!mounted) return;
      await _carregarAgendamentos();
      _showSnackBar('Agendamento confirmado com sucesso.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(_prettyError(e), isError: true);
    }
  }

  Future<void> _concluirAgendamento(Agendamento agendamento) async {
    try {
      await _api.concluirAgendamento(agendamento.id);
      if (!mounted) return;
      await _carregarAgendamentos();
      _showSnackBar('Agendamento concluído com sucesso.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(_prettyError(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _carregarAgendamentos,
          color: AppColors.accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                )
              else ...[
                SliverToBoxAdapter(child: _buildOverviewCard()),
                SliverToBoxAdapter(child: _buildCalendarCard()),
                SliverToBoxAdapter(child: _buildSelectedDaySection()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: _buildAppointmentsSliver(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agenda',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBold,
                  ),
                ),
                Text(
                  'Acompanhe seus horarios e toque no dia para ver os compromissos.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textRegular.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _carregarAgendamentos,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            tooltip: 'Atualizar',
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
      child: Row(
        children: [
          const Icon(Icons.event_note, color: AppColors.primary, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_upcomingCount compromisso${_upcomingCount == 1 ? '' : 's'} ativo${_upcomingCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_currentMonthCount neste mes',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.78),
                  ),
                ),
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
              _MonthButton(
                icon: Icons.chevron_left,
                onTap: () => _changeMonth(-1),
              ),
              const SizedBox(width: 8),
              _MonthButton(
                icon: Icons.chevron_right,
                onTap: () => _changeMonth(1),
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
    final today = _dateOnly(DateTime.now());
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
              : AppColors.primary.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(16),
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
                color: selected
                    ? AppColors.primary
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
    final selected = _selectedDate ?? _dateOnly(DateTime.now());
    final itemCount = _selectedDayAppointments.length;

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
                  '$itemCount compromisso${itemCount == 1 ? '' : 's'} nesta data',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Falha ao carregar agenda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _carregarAgendamentos,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  SliverList _buildAppointmentsSliver() {
    final items = _selectedDayAppointments;

    if (items.isEmpty) {
      return SliverList.list(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
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
                  'Escolha outro dia no calendario para consultar seus horarios.',
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
        final statusColor = _statusColor(item.status);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            elevation: 0,
            shadowColor: AppColors.cardShadow.withValues(alpha: 0.45),
            child: InkWell(
              onTap: () => _abrirDetalheAgendamento(item),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.16),
                  ),
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
                    _AppointmentVenuePhoto(
                      assetPath: _appointmentImageAsset(item),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.servicoNome ??
                                      'Servico #${item.servicoId}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textBold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusChip(status: item.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _AppointmentMeta(
                            icon: Icons.schedule,
                            value:
                                '${_formatTime(item.inicioEm)} - ${_formatTime(item.fimEm)}',
                            color: AppColors.accent,
                            strong: true,
                          ),
                          const SizedBox(height: 6),
                          _AppointmentMeta(
                            icon: Icons.storefront_outlined,
                            value:
                                item.prestadorNome ??
                                (item.prestadorId != null
                                    ? 'Prestador #${item.prestadorId}'
                                    : 'Prestador nao informado'),
                          ),
                          if (item.observacoes != null &&
                              item.observacoes!.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _AppointmentMeta(
                              icon: Icons.notes_outlined,
                              value: item.observacoes!,
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              if (_isPrestador && item.status == 'PENDENTE')
                                FilledButton.icon(
                                  onPressed: () => _confirmarAgendamento(item),
                                  icon: const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                  ),
                                  label: const Text('Confirmar'),
                                ),
                              if (_isPrestador && item.status == 'CONFIRMADO')
                                FilledButton.icon(
                                  onPressed: () => _concluirAgendamento(item),
                                  icon: const Icon(Icons.task_alt, size: 16),
                                  label: const Text('Concluir'),
                                ),
                              const Spacer(),
                              Text(
                                'Detalhes',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.accent,
      ),
    );
  }

  String _prettyError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _pickInitialDate(List<Agendamento> items) {
    final today = _dateOnly(DateTime.now());
    for (final item in items) {
      final itemDate = _dateOnly(item.inicioEm);
      if (!itemDate.isBefore(today) && item.status != 'CANCELADO') {
        return itemDate;
      }
    }

    if (items.isNotEmpty) {
      return _dateOnly(items.first.inicioEm);
    }

    return today;
  }

  DateTime _normalizeSelection() {
    if (_selectedDate == null) {
      return _pickInitialDate(_agendamentos);
    }

    return _dateOnly(_selectedDate!);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Agendamento> _appointmentsForDay(DateTime day) =>
      _agendamentos.where((item) => _isSameDay(item.inicioEm, day)).toList();

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
      );
      final lastDayOfMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        0,
      ).day;
      final desiredDay = (_selectedDate ?? DateTime.now()).day;
      final preferredSelection = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        desiredDay > lastDayOfMonth ? lastDayOfMonth : desiredDay,
      );
      _selectedDate = DateTime(
        preferredSelection.year,
        preferredSelection.month,
        preferredSelection.day,
      );
    });
  }

  List<DateTime?> get _visibleDays {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final totalDays = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final leadingEmpty = firstDayOfMonth.weekday % 7;
    final cells = <DateTime?>[];

    for (var i = 0; i < leadingEmpty; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= totalDays; day++) {
      cells.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  String _monthLabel(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _selectedDayLabel(DateTime date) {
    const weekdays = [
      'domingo',
      'segunda',
      'terca',
      'quarta',
      'quinta',
      'sexta',
      'sabado',
    ];
    const months = [
      'janeiro',
      'fevereiro',
      'marco',
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

  String _formatTime(DateTime date) =>
      '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _appointmentImageAsset(Agendamento item) {
    final lookup = '${item.prestadorNome ?? ''} ${item.servicoNome ?? ''}'
        .toLowerCase();

    if (lookup.contains('barbie')) {
      return 'assets/barbiesalon.jpg';
    }
    if (lookup.contains('james')) {
      return 'assets/jamessalon.jpg';
    }
    if (lookup.contains('mariano')) {
      return 'assets/mariano.jpg';
    }
    if (lookup.contains('silva') || lookup.contains('salao')) {
      return 'assets/salao.jpg';
    }

    return 'assets/icon.jpg';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMADO':
        return AppColors.success;
      case 'CANCELADO':
        return AppColors.error;
      case 'CONCLUIDO':
        return AppColors.textMuted;
      case 'PENDENTE':
      default:
        return AppColors.accent;
    }
  }

  static const List<String> _weekdayHeaders = [
    'D',
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
  ];
}

class _AppointmentVenuePhoto extends StatelessWidget {
  final String assetPath;

  const _AppointmentVenuePhoto({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 84,
        height: 84,
        color: AppColors.inputBackground,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.inputBackground,
            alignment: Alignment.center,
            child: const Icon(
              Icons.storefront,
              color: AppColors.accent,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentMeta extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final bool strong;

  const _AppointmentMeta({
    required this.icon,
    required this.value,
    this.color = AppColors.textMuted,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color.withValues(alpha: 0.9), size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'CONFIRMADO' => AppColors.success,
      'CANCELADO' => AppColors.error,
      'CONCLUIDO' => AppColors.textMuted,
      _ => AppColors.warning,
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

class _MonthButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.accent),
        ),
      ),
    );
  }
}
