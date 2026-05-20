import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/models/agendamento.dart';
import 'package:duckhat/pages/appointment_detail.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopSchedulePage extends StatefulWidget {
  const ShopSchedulePage({super.key});

  @override
  State<ShopSchedulePage> createState() => _ShopSchedulePageState();
}

class _ShopSchedulePageState extends State<ShopSchedulePage> {
  final _api = DuckHatApi.instance;

  bool _loading = true;
  String? _error;
  List<Agendamento> _agendamentos = [];
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  int _lastSyncRevision = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = _dateOnly(now);
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
      final items = await _api.listarAgendamentosPrestador()
        ..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));
      final initialDate = _pickInitialDate(items);

      if (!mounted) return;
      setState(() {
        _agendamentos = items;
        _selectedDate = _selectedDate == null
            ? initialDate
            : _dateOnly(_selectedDate!);
        _currentMonth = DateTime(
          (_selectedDate ?? initialDate).year,
          (_selectedDate ?? initialDate).month,
        );
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _prettyError(error);
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

  int get _activeCount {
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

  Future<void> _abrirDetalhe(Agendamento agendamento) async {
    final changed = await Navigator.of(context).push<bool>(
      AppRoute(builder: (_) => AppointmentDetailPage(agendamento: agendamento)),
    );

    if (changed == true && mounted) {
      await _carregarAgendamentos(showLoader: false);
    }
  }

  Future<void> _confirmarAgendamento(Agendamento agendamento) async {
    try {
      await _api.confirmarAgendamento(agendamento.id);
      if (!mounted) return;
      await _carregarAgendamentos();
      _showSnackBar('Agendamento confirmado com sucesso.');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_prettyError(error), isError: true);
    }
  }

  Future<void> _concluirAgendamento(Agendamento agendamento) async {
    try {
      await _api.concluirAgendamento(agendamento.id);
      if (!mounted) return;
      await _carregarAgendamentos();
      _showSnackBar('Agendamento concluído com sucesso.');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_prettyError(error), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.of(context).background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _carregarAgendamentos,
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda',
                  style: TextStyle(
                    color: AppColors.textBold,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Veja os clientes que agendaram serviços no seu estabelecimento.',
                  style: TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _carregarAgendamentos,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            tooltip: 'Atualizar agenda',
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowAccent,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.groups_2_outlined,
            color: AppColors.primary,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_activeCount agendamento${_activeCount == 1 ? '' : 's'} ativo${_activeCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_currentMonthCount neste mes',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.78),
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

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: buildShopCardDecoration(radius: 20),
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
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              childAspectRatio: 0.9,
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
    final dayItems = _appointmentsForDay(day);
    final hasActiveItems = dayItems.any((item) => item.status != 'CANCELADO');

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent
              : hasActiveItems
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.primary.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : isToday
                ? AppColors.accentLight
                : AppColors.primary.withValues(alpha: 0),
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textBold,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: hasActiveItems
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
    final count = _selectedDayAppointments.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDayLabel(selected),
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count cliente${count == 1 ? '' : 's'} agendado${count == 1 ? '' : 's'} nesta data',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
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
            'Não foi possível carregar a agenda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textBold,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
            decoration: buildShopCardDecoration(radius: 20),
            child: const Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 54,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 14),
                Text(
                  'Nenhum cliente agendado nesta data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBold,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Quando um cliente agendar um servico deste estabelecimento, ele aparecera aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ShopAppointmentCard(
            agendamento: item,
            onTap: () => _abrirDetalhe(item),
            onConfirm: item.status == 'PENDENTE'
                ? () => _confirmarAgendamento(item)
                : null,
            onComplete: item.status == 'CONFIRMADO'
                ? () => _concluirAgendamento(item)
                : null,
          ),
        );
      },
    );
  }

  List<Agendamento> _appointmentsForDay(DateTime day) =>
      _agendamentos.where((item) => _isSameDay(item.inicioEm, day)).toList();

  DateTime _pickInitialDate(List<Agendamento> items) {
    final today = _dateOnly(DateTime.now());
    for (final item in items) {
      final itemDate = _dateOnly(item.inicioEm);
      if (!itemDate.isBefore(today) && item.status != 'CANCELADO') {
        return itemDate;
      }
    }

    if (items.isNotEmpty) return _dateOnly(items.first.inicioEm);

    return today;
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

    for (var index = 0; index < leadingEmpty; index++) {
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
      _selectedDate = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        desiredDay > lastDayOfMonth ? lastDayOfMonth : desiredDay,
      );
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.accent,
      ),
    );
  }

  String _prettyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

class _ShopAppointmentCard extends StatelessWidget {
  final Agendamento agendamento;
  final VoidCallback onTap;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;

  const _ShopAppointmentCard({
    required this.agendamento,
    required this.onTap,
    this.onConfirm,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(agendamento.status);
    final themeColors = AppThemeColors.of(context);

    return Material(
      color: themeColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: buildShopCardDecorationFor(
            context,
            radius: 18,
            borderColor: statusColor.withValues(alpha: 0.16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: themeColors.inputFill,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _formatTime(agendamento.inicioEm),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agendamento.clienteNome ??
                              'Cliente #${agendamento.clienteId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textBold,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agendamento.servicoNome ??
                              'Servico #${agendamento.servicoId}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatTime(agendamento.inicioEm)} - ${_formatTime(agendamento.fimEm)}',
                          style: const TextStyle(
                            color: AppColors.textRegular,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: agendamento.status),
                ],
              ),
              if (agendamento.observacoes != null &&
                  agendamento.observacoes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  agendamento.observacoes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (onConfirm != null || onComplete != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onConfirm ?? onComplete,
                    icon: Icon(
                      onConfirm != null
                          ? Icons.check_circle_outline
                          : Icons.task_alt,
                      size: 16,
                    ),
                    label: Text(onConfirm != null ? 'Confirmar' : 'Concluir'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Color _statusColor(String status) {
    return switch (status) {
      'CONFIRMADO' => AppColors.success,
      'CANCELADO' => AppColors.error,
      'CONCLUIDO' => AppColors.textMuted,
      _ => AppColors.warning,
    };
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

    final label = switch (status) {
      'CONFIRMADO' => 'Confirmado',
      'CANCELADO' => 'Cancelado',
      'CONCLUIDO' => 'Concluído',
      _ => 'Pendente',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
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
