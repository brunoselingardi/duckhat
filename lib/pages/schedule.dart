import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../core/app_route.dart';
import '../pages/appointment_detail.dart';
import '../services/duckhat_api.dart';

const kBackgroundColor = Color(0xFFFAFBFC);
const kPrimaryColor = Color(0xFF3A7FD5);
const kPrimaryLightOpaque = Color(0xFF8EB5F0);
const kTextColor = Color(0xFF2F4987);
const kGrayColor = Color(0xFF6B7280);

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
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _api.listarAgendamentos()
        ..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));

      final initialDate = items.isNotEmpty
          ? _dateOnly(items.first.inicioEm)
          : _dateOnly(DateTime.now());

      if (!mounted) return;

      setState(() {
        _agendamentos = items;
        _selectedDate ??= initialDate;
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

  List<DateTime> get _calendarDays {
    final result = <DateTime>[];
    final seen = <String>{};

    for (final item in _agendamentos) {
      final day = _dateOnly(item.inicioEm);
      final key = '${day.year}-${day.month}-${day.day}';
      if (seen.add(key)) {
        result.add(day);
      }
    }

    if (result.isEmpty) {
      result.add(_dateOnly(DateTime.now()));
    }

    return result;
  }

  List<Agendamento> get _selectedDayAppointments {
    final selected = _selectedDate ?? _dateOnly(DateTime.now());

    return _agendamentos
        .where((item) => _isSameDay(item.inicioEm, selected))
        .toList()
      ..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));
  }

  Future<void> _cancelarAgendamento(Agendamento agendamento) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar agendamento'),
          content: Text(
            'Deseja cancelar ${agendamento.servicoNome ?? 'este agendamento'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api.cancelarAgendamento(agendamento.id);
      if (!mounted) return;
      await _carregarAgendamentos();
      _showSnackBar('Agendamento cancelado com sucesso.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(_prettyError(e), isError: true);
    }
  }

  Future<void> _abrirDetalheAgendamento(Agendamento agendamento) async {
    final changed = await Navigator.of(context).push<bool>(
      AppRoute(
        builder: (_) => AppointmentDetailPage(
          agendamento: agendamento,
          onCancel: (item) async {
            await _api.cancelarAgendamento(item.id);
          },
        ),
      ),
    );

    if (changed == true && mounted) {
      await _carregarAgendamentos();
      _showSnackBar('Agendamento atualizado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                ),
              )
            else if (_error != null)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _carregarAgendamentos,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 120),
                      Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: kGrayColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Falha ao carregar agenda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kGrayColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: FilledButton.icon(
                          onPressed: _carregarAgendamentos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _buildCalendar(),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _carregarAgendamentos,
                  child: _buildAppointmentsList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Agenda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _carregarAgendamentos,
            icon: const Icon(Icons.refresh, color: kPrimaryColor),
            tooltip: 'Atualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final days = _calendarDays;
    final selected = _selectedDate ?? days.first;

    return SizedBox(
      height: 84,
      child: ListView.builder(
        key: const PageStorageKey('schedule-calendar-scroll'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day, selected);
          final hasItems = _agendamentos.any(
            (item) => _isSameDay(item.inicioEm, day),
          );

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasItems
                      ? (isSelected ? kPrimaryColor : kPrimaryLightOpaque)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: hasItems
                    ? [
                        BoxShadow(
                          color: kPrimaryLightOpaque.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabel(day),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : kGrayColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _twoDigits(day.day),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : kTextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final items = _selectedDayAppointments;

    if (items.isEmpty) {
      return ListView(
        key: const PageStorageKey('schedule-empty-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.event_available,
            size: 64,
            color: kGrayColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Nenhum agendamento nesta data',
              style: TextStyle(fontSize: 16, color: kGrayColor),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Toque no + para criar um novo agendamento.',
              style: TextStyle(fontSize: 12, color: kGrayColor),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      key: const PageStorageKey('schedule-appointments-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 72,
                decoration: BoxDecoration(
                  color: _statusColor(item.status),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatTime(item.inicioEm)} - ${_formatTime(item.fimEm)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.servicoNome ?? 'Serviço #${item.servicoId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.prestadorNome ??
                          (item.prestadorId != null
                              ? 'Prestador #${item.prestadorId}'
                              : 'Prestador não informado'),
                      style: const TextStyle(fontSize: 12, color: kGrayColor),
                    ),
                    if (item.observacoes != null &&
                        item.observacoes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.observacoes!,
                        style: const TextStyle(fontSize: 12, color: kGrayColor),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(status: item.status),
                        if (item.podeCancelar)
                          OutlinedButton.icon(
                            onPressed: () => _cancelarAgendamento(item),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        TextButton.icon(
                          onPressed: () => _abrirDetalheAgendamento(item),
                          icon: const Icon(Icons.chevron_right, size: 18),
                          label: const Text('Detalhes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : kPrimaryColor,
      ),
    );
  }

  String _prettyError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayLabel(DateTime date) {
    const labels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    return labels[date.weekday - 1];
  }

  String _formatTime(DateTime date) =>
      '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.redAccent;
      case 'CONCLUIDO':
        return Colors.grey;
      case 'PENDENTE':
      default:
        return Colors.orange;
    }
  }
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
