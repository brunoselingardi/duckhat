class NotificacaoPreferencias {
  final bool agendamentos;
  final bool mensagens;
  final bool promocoes;
  final bool novidades;
  final bool resumoEmail;

  NotificacaoPreferencias({
    required this.agendamentos,
    required this.mensagens,
    required this.promocoes,
    required this.novidades,
    required this.resumoEmail,
  });

  factory NotificacaoPreferencias.fromJson(Map<String, dynamic> json) {
    return NotificacaoPreferencias(
      agendamentos: json['agendamentos'] == true,
      mensagens: json['mensagens'] == true,
      promocoes: json['promocoes'] == true,
      novidades: json['novidades'] == true,
      resumoEmail: json['resumoEmail'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agendamentos': agendamentos,
      'mensagens': mensagens,
      'promocoes': promocoes,
      'novidades': novidades,
      'resumoEmail': resumoEmail,
    };
  }

  NotificacaoPreferencias copyWith({
    bool? agendamentos,
    bool? mensagens,
    bool? promocoes,
    bool? novidades,
    bool? resumoEmail,
  }) {
    return NotificacaoPreferencias(
      agendamentos: agendamentos ?? this.agendamentos,
      mensagens: mensagens ?? this.mensagens,
      promocoes: promocoes ?? this.promocoes,
      novidades: novidades ?? this.novidades,
      resumoEmail: resumoEmail ?? this.resumoEmail,
    );
  }
}
