class Agendamento {
  final int id;
  final int clienteId;
  final int? prestadorId;
  final String? prestadorNome;
  final int servicoId;
  final String? servicoNome;
  final DateTime inicioEm;
  final DateTime fimEm;
  final String status;
  final String? observacoes;
  final DateTime? criadoEm;

  Agendamento({
    required this.id,
    required this.clienteId,
    required this.prestadorId,
    required this.prestadorNome,
    required this.servicoId,
    required this.servicoNome,
    required this.inicioEm,
    required this.fimEm,
    required this.status,
    required this.observacoes,
    required this.criadoEm,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) =>
        value is int ? value : int.parse(value.toString());

    return Agendamento(
      id: parseInt(json['id']),
      clienteId: parseInt(json['clienteId']),
      prestadorId: json['prestadorId'] == null
          ? null
          : parseInt(json['prestadorId']),
      prestadorNome: json['prestadorNome'] as String?,
      servicoId: parseInt(json['servicoId']),
      servicoNome: json['servicoNome'] as String?,
      inicioEm: DateTime.parse(json['inicioEm'] as String),
      fimEm: DateTime.parse(json['fimEm'] as String),
      status: json['status'] as String,
      observacoes: json['observacoes'] as String?,
      criadoEm: json['criadoEm'] == null
          ? null
          : DateTime.parse(json['criadoEm'] as String),
    );
  }

  bool get podeCancelar => status != 'CANCELADO' && status != 'CONCLUIDO';
}
