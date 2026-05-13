class HorarioFuncionamento {
  final Map<String, bool> dias;
  final String horaAbertura;
  final String horaFechamento;
  final bool vinteQuatroHoras;
  final bool fechado;

  HorarioFuncionamento({
    Map<String, bool>? dias,
    this.horaAbertura = '08:00',
    this.horaFechamento = '18:00',
    this.vinteQuatroHoras = false,
    this.fechado = false,
  }) : dias = dias ??
           {
             'SEGUNDA': true,
             'TERCA': true,
             'QUARTA': true,
             'QUINTA': true,
             'SEXTA': true,
             'SABADO': false,
             'DOMINGO': false,
           };

  HorarioFuncionamento copyWith({
    Map<String, bool>? dias,
    String? horaAbertura,
    String? horaFechamento,
    bool? vinteQuatroHoras,
    bool? fechado,
  }) {
    return HorarioFuncionamento(
      dias: dias ?? Map.from(this.dias),
      horaAbertura: horaAbertura ?? this.horaAbertura,
      horaFechamento: horaFechamento ?? this.horaFechamento,
      vinteQuatroHoras: vinteQuatroHoras ?? this.vinteQuatroHoras,
      fechado: fechado ?? this.fechado,
    );
  }

  List<String> get diasAtivos =>
      dias.entries.where((e) => e.value).map((e) => e.key).toList();

  String get resumo {
    if (fechado) return 'Fechado';
    if (vinteQuatroHoras) return '24 horas';
    final diasStr = _agruparDias(diasAtivos);
    return '$diasStr $horaAbertura - $horaFechamento';
  }

  String _agruparDias(List<String> dias) {
    if (dias.isEmpty) return '';

    const ordem = ['SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO', 'DOMINGO'];
    final ativosOrdenados = ordem.where((d) => dias.contains(d)).toList();

    if (ativosOrdenados.isEmpty) return '';

    final List<String> grupos = [];
    List<String> grupoAtual = [];

    for (int i = 0; i < ativosOrdenados.length; i++) {
      if (grupoAtual.isEmpty) {
        grupoAtual.add(ativosOrdenados[i]);
      } else {
        final ultimo = grupoAtual.last;
        final idxAtual = ordem.indexOf(ativosOrdenados[i]);
        final idxUltimo = ordem.indexOf(ultimo);

        if (idxAtual == idxUltimo + 1) {
          grupoAtual.add(ativosOrdenados[i]);
        } else {
          grupos.add(_formatarGrupo(grupoAtual));
          grupoAtual = [ativosOrdenados[i]];
        }
      }
    }
    if (grupoAtual.isNotEmpty) {
      grupos.add(_formatarGrupo(grupoAtual));
    }

    return grupos.join(', ');
  }

  String _formatarGrupo(List<String> grupo) {
    if (grupo.length == 1) return _nomeCurto(grupo.first);

    final primeiro = _nomeCurto(grupo.first);
    final ultimo = _nomeCurto(grupo.last);

    if (grupo.length == 2) {
      return '$primeiro e $ultimo';
    }

    return '$primeiro a $ultimo';
  }

  String _nomeCurto(String dia) {
    return {
      'SEGUNDA': 'Seg',
      'TERCA': 'Ter',
      'QUARTA': 'Qua',
      'QUINTA': 'Qui',
      'SEXTA': 'Sex',
      'SABADO': 'Sáb',
      'DOMINGO': 'Dom',
    }[dia] ?? dia;
  }

  String toHorarioAtendimento() {
    if (fechado) return 'Fechado';
    if (vinteQuatroHoras) return '24 horas';
    final diasStr = diasAtivos.map(_nomeCurto).join(', ');
    return '$diasStr $horaAbertura - $horaFechamento';
  }

  Map<String, dynamic> toJson() => {
        'dias': dias,
        'horaAbertura': horaAbertura,
        'horaFechamento': horaFechamento,
        'vinteQuatroHoras': vinteQuatroHoras,
        'fechado': fechado,
      };

  factory HorarioFuncionamento.fromJson(Map<String, dynamic> json) {
    return HorarioFuncionamento(
      dias: Map<String, bool>.from(json['dias'] ?? {}),
      horaAbertura: json['horaAbertura'] ?? '08:00',
      horaFechamento: json['horaFechamento'] ?? '18:00',
      vinteQuatroHoras: json['vinteQuatroHoras'] ?? false,
      fechado: json['fechado'] ?? false,
    );
  }

  factory HorarioFuncionamento.parseFromText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return HorarioFuncionamento();
    }
    if (text == 'Fechado') {
      return HorarioFuncionamento(fechado: true);
    }
    if (text == '24 horas') {
      return HorarioFuncionamento(vinteQuatroHoras: true);
    }
    return HorarioFuncionamento();
  }
}
