class Avaliacao {
  final int id;
  final int agendamentoId;
  final int? prestadorId;
  final int? servicoId;
  final int? clienteId;
  final String? clienteNome;
  final int nota;
  final String? comentario;
  final DateTime criadoEm;

  Avaliacao({
    required this.id,
    required this.agendamentoId,
    required this.servicoId,
    required this.prestadorId,
    required this.clienteId,
    required this.clienteNome,
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
      prestadorId: json['prestadorId'] == null
          ? null
          : parseInt(json['prestadorId']),
      servicoId: json['servicoId'] == null ? null : parseInt(json['servicoId']),
      clienteId: json['clienteId'] == null ? null : parseInt(json['clienteId']),
      clienteNome: json['clienteNome'] as String?,
      nota: parseInt(json['nota']),
      comentario: json['comentario'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );
  }
}
