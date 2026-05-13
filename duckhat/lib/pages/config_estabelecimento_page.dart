import 'package:flutter/material.dart';
import '../models/horario_funcionamento.dart';

class ConfigEstabelecimentoPage extends StatefulWidget {
  final HorarioFuncionamento? horarioInicial;

  const ConfigEstabelecimentoPage({super.key, this.horarioInicial});

  @override
  State<ConfigEstabelecimentoPage> createState() =>
      _ConfigEstabelecimentoPageState();
}

class _ConfigEstabelecimentoPageState extends State<ConfigEstabelecimentoPage> {
  late HorarioFuncionamento _horario;

  @override
  void initState() {
    super.initState();
    _horario = widget.horarioInicial ?? HorarioFuncionamento();
  }

  Future<void> _selecionarHora(bool isAbertura) async {
    final partes = isAbertura
        ? _horario.horaAbertura.split(':')
        : _horario.horaFechamento.split(':');
    final horaInicial = int.parse(partes[0]);
    final minutoInicial = int.parse(partes[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: horaInicial, minute: minutoInicial),
    );

    if (picked != null) {
      setState(() {
        final horaFormatada =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isAbertura) {
          _horario = _horario.copyWith(horaAbertura: horaFormatada);
        } else {
          _horario = _horario.copyWith(horaFechamento: horaFormatada);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horário de Funcionamento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dias da semana',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _horario.dias.entries.map((entry) {
                      return FilterChip(
                        label: Text(_nomeExibicao(entry.key)),
                        selected: entry.value,
                        onSelected: (selected) {
                          setState(() {
                            final novosDias =
                                Map<String, bool>.from(_horario.dias);
                            novosDias[entry.key] = selected;
                            _horario =
                                _horario.copyWith(dias: novosDias);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horário',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _selecionarHora(true),
                          child: Text(_horario.horaAbertura),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('até'),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _selecionarHora(false),
                          child: Text(_horario.horaFechamento),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('24 horas'),
                    subtitle: const Text('Aberto o dia todo'),
                    value: _horario.vinteQuatroHoras,
                    onChanged: (value) {
                      setState(() {
                        _horario = _horario.copyWith(vinteQuatroHoras: value);
                        if (value) {
                          _horario = _horario.copyWith(fechado: false);
                        }
                      });
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Fechado'),
                    subtitle: const Text('Não atende neste período'),
                    value: _horario.fechado,
                    onChanged: (value) {
                      setState(() {
                        _horario = _horario.copyWith(fechado: value);
                        if (value) {
                          _horario = _horario.copyWith(vinteQuatroHoras: false);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_horario.resumo),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(_horario);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  String _nomeExibicao(String dia) {
    return {
      'segunda': 'Seg',
      'terca': 'Ter',
      'quarta': 'Qua',
      'quinta': 'Qui',
      'sexta': 'Sex',
      'sabado': 'Sáb',
      'domingo': 'Dom',
    }[dia] ?? dia;
  }
}
