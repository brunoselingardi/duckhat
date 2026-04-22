import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/servico_catalogo.dart';
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
  bool _creating = false;
  String? _error;
  List<Agendamento> _agendamentos = [];
  DateTime? _selectedDate;

  bool get _isPrestador => _api.isPrestador;

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
      final items =
          await (_isPrestador
                ? _api.listarAgendamentosPrestador()
                : _api.listarAgendamentos())
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

  Future<void> _abrirNovoAgendamento() async {
    if (_isPrestador) return;

    try {
      setState(() => _creating = true);
      final servicos = await _api.listarServicosAtivos();

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          final navigator = Navigator.of(sheetContext);
          return _CreateAppointmentSheet(
            servicos: servicos,
            onSubmit:
                ({
                  required int servicoId,
                  required DateTime inicioEm,
                  required DateTime fimEm,
                  String? observacoes,
                }) async {
                  await _api.criarAgendamento(
                    servicoId: servicoId,
                    inicioEm: inicioEm,
                    fimEm: fimEm,
                    observacoes: observacoes,
                  );
                  if (!mounted) return;
                  navigator.pop();
                  await _carregarAgendamentos();
                  _showSnackBar('Agendamento criado com sucesso.');
                },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(_prettyError(e), isError: true);
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
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
      MaterialPageRoute(
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
      await _carregarAgendamentos();
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
          if (!_isPrestador) ...[
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: _creating ? null : _abrirNovoAgendamento,
                icon: _creating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add, color: kPrimaryColor),
                tooltip: 'Novo agendamento',
              ),
            ),
          ],
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
          Center(
            child: Text(
              _isPrestador
                  ? 'Nenhum atendimento nesta data.'
                  : 'Toque no + para criar um novo agendamento.',
              style: TextStyle(fontSize: 12, color: kGrayColor),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
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
                      _isPrestador
                          ? (item.clienteNome ?? 'Cliente #${item.clienteId}')
                          : (item.prestadorNome ??
                                (item.prestadorId != null
                                    ? 'Prestador #${item.prestadorId}'
                                    : 'Prestador não informado')),
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
                        if (!_isPrestador && item.podeCancelar)
                          OutlinedButton.icon(
                            onPressed: () => _cancelarAgendamento(item),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        if (_isPrestador && item.status == 'PENDENTE')
                          FilledButton.icon(
                            onPressed: () => _confirmarAgendamento(item),
                            icon: const Icon(Icons.check_circle, size: 16),
                            label: const Text('Confirmar'),
                          ),
                        if (_isPrestador && item.status == 'CONFIRMADO')
                          FilledButton.icon(
                            onPressed: () => _concluirAgendamento(item),
                            icon: const Icon(Icons.task_alt, size: 16),
                            label: const Text('Concluir'),
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

class _CreateAppointmentSheet extends StatefulWidget {
  final List<ServicoCatalogo> servicos;
  final Future<void> Function({
    required int servicoId,
    required DateTime inicioEm,
    required DateTime fimEm,
    String? observacoes,
  })
  onSubmit;

  const _CreateAppointmentSheet({
    required this.servicos,
    required this.onSubmit,
  });

  @override
  State<_CreateAppointmentSheet> createState() =>
      _CreateAppointmentSheetState();
}

class _CreateAppointmentSheetState extends State<_CreateAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();

  ServicoCatalogo? _servicoSelecionado;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  bool _saving = false;

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Novo agendamento',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServicoCatalogo>(
                initialValue: _servicoSelecionado,
                items: widget.servicos
                    .map(
                      (servico) => DropdownMenuItem(
                        value: servico,
                        child: Text(servico.nome),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _servicoSelecionado = value),
                decoration: const InputDecoration(
                  labelText: 'Serviço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Selecione um serviço' : null,
              ),
              if (_servicoSelecionado != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${_servicoSelecionado!.duracaoMin} min • R\$ ${_servicoSelecionado!.preco.toStringAsFixed(2)}',
                  style: const TextStyle(color: kGrayColor),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _dataSelecionada == null
                            ? 'Selecionar data'
                            : '${_twoDigits(_dataSelecionada!.day)}/${_twoDigits(_dataSelecionada!.month)}/${_dataSelecionada!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _horaSelecionada == null
                            ? 'Selecionar hora'
                            : '${_twoDigits(_horaSelecionada!.hour)}:${_twoDigits(_horaSelecionada!.minute)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Opcional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_saving ? 'Salvando...' : 'Criar agendamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 180)),
      initialDate: _dataSelecionada ?? now,
    );

    if (selected != null) {
      setState(() => _dataSelecionada = selected);
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (selected != null) {
      setState(() => _horaSelecionada = selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_servicoSelecionado == null) {
      _showError('Selecione um serviço.');
      return;
    }

    if (_dataSelecionada == null) {
      _showError('Selecione uma data.');
      return;
    }

    if (_horaSelecionada == null) {
      _showError('Selecione um horário.');
      return;
    }

    final inicioEm = DateTime(
      _dataSelecionada!.year,
      _dataSelecionada!.month,
      _dataSelecionada!.day,
      _horaSelecionada!.hour,
      _horaSelecionada!.minute,
    );

    final fimEm = inicioEm.add(
      Duration(minutes: _servicoSelecionado!.duracaoMin),
    );

    try {
      setState(() => _saving = true);

      await widget.onSubmit(
        servicoId: _servicoSelecionado!.id,
        inicioEm: inicioEm,
        fimEm: fimEm,
        observacoes: _observacoesController.text,
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
