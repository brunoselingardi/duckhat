class Avaliacao {
  final int id;
  final int agendamentoId;
  final int nota;
  final String? comentario;
  final DateTime? criadoEm;

  const Avaliacao({
    required this.id,
    required this.agendamentoId,
    required this.nota,
    required this.comentario,
    required this.criadoEm,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) =>
        value is int ? value : int.parse(value.toString());

    return Avaliacao(
      id: parseInt(json['id']),
      agendamentoId: parseInt(json['agendamentoId']),
      nota: parseInt(json['nota']),
      comentario: json['comentario'] as String?,
      criadoEm: json['criadoEm'] == null
          ? null
          : DateTime.parse(json['criadoEm'] as String),
    );
  }
}
