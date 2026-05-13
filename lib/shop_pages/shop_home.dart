import 'package:duckhat/models/agendamento.dart';
import 'package:flutter/material.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';
import 'shop_establishment_data.dart';
import 'shop_service_duration.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  final _api = DuckHatApi.instance;

  bool _loading = true;
  String? _error;
  List<Agendamento> _agendamentos = [];
  int _lastSyncRevision = 0;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
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

      if (!mounted) return;
      setState(() {
        _agendamentos = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
        _loading = false;
      });
    }
  }

  void _handleAgendamentoSync() {
    final signal = _api.agendamentoSync.value;
    if (signal.revision == _lastSyncRevision || !mounted) return;
    _lastSyncRevision = signal.revision;
    _carregarAgendamentos(showLoader: false);
  }

  List<Agendamento> get _selectedDayAppointments {
    final today = _dateOnly(DateTime.now());
    final selectedDate = today.add(Duration(days: _selectedDayIndex));
    return _agendamentos
        .where(
          (item) =>
              _isSameDay(item.inicioEm, selectedDate) && item.status != 'CANCELADO',
        )
        .toList()
      ..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));
  }

  List<Agendamento> get _todayAppointments => _selectedDayAppointments;

  int get _pendingCount =>
      _agendamentos.where((item) => item.status == 'PENDENTE').length;

  int get _activeCount {
    final now = DateTime.now();
    return _agendamentos
        .where((item) => item.status != 'CANCELADO' && item.fimEm.isAfter(now))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _carregarAgendamentos,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _buildHeader(),
              _buildVitrineActions(context),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá,',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                ValueListenableBuilder<LoginSession?>(
                  valueListenable: DuckHatApi.instance.sessionNotifier,
                  builder: (context, session, _) {
                    return Text(
                      session?.nome ?? 'Estabelecimento',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  '$_activeCount compromisso${_activeCount == 1 ? '' : 's'} ativo${_activeCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _carregarAgendamentos,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            tooltip: 'Atualizar agendamentos',
          ),
        ],
      ),
    );
  }

  Widget _buildVitrineActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: buildShopCardDecoration(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vitrine do estabelecimento',
              style: TextStyle(
                color: AppColors.textBold,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mantenha sua descricao, banner e servicos atualizados para os clientes.',
              style: TextStyle(
                color: AppColors.textRegular,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.notes_rounded,
                    label: 'Descricao',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShopEstablishmentDataPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.design_services_outlined,
                    label: 'Servicos',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShopServiceDurationPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final today = _dateOnly(DateTime.now());
    final days = List.generate(7, (index) => today.add(Duration(days: index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Próximos dias',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = _selectedDayIndex == index;
              final isToday = _isSameDay(day, today);
              final count = _agendamentos
                  .where(
                    (item) =>
                        _isSameDay(item.inicioEm, day) &&
                        item.status != 'CANCELADO',
                  )
                  .length;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 58,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent
                        : isToday
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.accent, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayLabel(day.weekday),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkAlt,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.85)
                              : AppColors.accent,
                          fontWeight: FontWeight.w800,
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

  Widget _buildAppointmentsList() {
    final appointments = _todayAppointments;
    final today = _dateOnly(DateTime.now());
    final selectedDate = today.add(Duration(days: _selectedDayIndex));
    final dayLabel = _isSameDay(selectedDate, today)
        ? 'hoje'
        : _dateLabel(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _isSameDay(selectedDate, today)
                      ? 'Agendamentos de hoje'
                      : 'Agendamentos de $dayLabel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAlt,
                  ),
                ),
              ),
              Text(
                '${appointments.length} ${_isSameDay(selectedDate, today) ? 'hoje' : 'nesta data'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (_pendingCount > 0) ...[
            const SizedBox(height: 6),
            Text(
              '$_pendingCount pendente${_pendingCount == 1 ? '' : 's'} de confirmacao',
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_loading)
            const _HomeStateCard.loading()
          else if (_error != null)
            _HomeStateCard.error(
              message: _error!,
              onRetry: _carregarAgendamentos,
            )
          else if (appointments.isEmpty)
            const _HomeStateCard.empty()
          else
            ...appointments.map((item) => _AppointmentCard(agendamento: item)),
        ],
      ),
    );
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayLabel(int weekday) {
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return labels[weekday - 1];
  }

  String _dateLabel(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Maio', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textBold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Agendamento agendamento;

  const _AppointmentCard({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(agendamento.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: buildShopCardDecoration(
        radius: 14,
        borderColor: statusColor.withValues(alpha: 0.16),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              _formatTime(agendamento.inicioEm),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkAlt,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  agendamento.servicoNome ??
                      'Servico #${agendamento.servicoId}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(status: agendamento.status),
        ],
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
      'CONCLUIDO' => 'Concluido',
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
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _HomeStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  const _HomeStateCard._({
    required this.icon,
    required this.title,
    required this.message,
    required this.loading,
    this.onRetry,
  });

  const _HomeStateCard.loading()
    : this._(
        icon: Icons.event_note,
        title: 'Carregando agendamentos',
        message: 'Buscando clientes agendados no backend.',
        loading: true,
      );

  const _HomeStateCard.empty()
    : this._(
        icon: Icons.event_available,
        title: 'Nenhum agendamento hoje',
        message:
            'Quando um cliente agendar um servico deste estabelecimento, ele aparecera aqui.',
        loading: false,
      );

  const _HomeStateCard.error({
    required String message,
    required VoidCallback onRetry,
  }) : this._(
         icon: Icons.cloud_off,
         title: 'Falha ao carregar agenda',
         message: message,
         loading: false,
         onRetry: onRetry,
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: buildShopCardDecoration(radius: 16),
      child: Column(
        children: [
          if (loading)
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accent,
              ),
            )
          else
            Icon(icon, size: 42, color: AppColors.textMuted),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ],
      ),
    );
  }
}
