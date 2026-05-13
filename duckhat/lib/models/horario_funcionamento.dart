class HorarioFuncionamento {
  final Map<String, bool> dias;
  final String horaAbertura;
  final String horaFechamento;
  final bool vinteQuatroHoras;
  final bool fechado;

  HorarioFuncionamento({
    Map<String, bool>? dias,
    this.horaAbertura = '06:00',
    this.horaFechamento = '22:00',
    this.vinteQuatroHoras = false,
    this.fechado = false,
  }) : dias = dias ??
           {
             'segunda': true,
             'terca': true,
             'quarta': true,
             'quinta': true,
             'sexta': true,
             'sabado': false,
             'domingo': false,
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
    final diasStr = diasAtivos.map(_nomeCurto).join(', ');
    return '$diasStr $horaAbertura - $horaFechamento';
  }

  String _nomeCurto(String dia) {
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
      horaAbertura: json['horaAbertura'] ?? '06:00',
      horaFechamento: json['horaFechamento'] ?? '22:00',
      vinteQuatroHoras: json['vinteQuatroHoras'] ?? false,
      fechado: json['fechado'] ?? false,
    );
  }
}
