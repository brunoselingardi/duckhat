class Notificacao {
  final int id;
  final int usuarioId;
  final int? agendamentoId;
  final int? chatConversaId;
  final String tipo;
  final String canal;
  final String titulo;
  final String mensagem;
  final DateTime? criadoEm;
  final DateTime agendadoPara;
  final DateTime? enviadoEm;
  final DateTime? lidoEm;
  final String status;
  final bool lida;

  Notificacao({
    required this.id,
    required this.usuarioId,
    required this.agendamentoId,
    required this.chatConversaId,
    required this.tipo,
    required this.canal,
    required this.titulo,
    required this.mensagem,
    required this.criadoEm,
    required this.agendadoPara,
    required this.enviadoEm,
    required this.lidoEm,
    required this.status,
    required this.lida,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: _parseInt(json['id']),
      usuarioId: _parseInt(json['usuarioId']),
      agendamentoId: _parseNullableInt(json['agendamentoId']),
      chatConversaId: _parseNullableInt(json['chatConversaId']),
      tipo: json['tipo'] as String? ?? 'SISTEMA',
      canal: json['canal'] as String? ?? 'APP',
      titulo: json['titulo'] as String? ?? '',
      mensagem: json['mensagem'] as String? ?? '',
      criadoEm: _parseDate(json['criadoEm']),
      agendadoPara: DateTime.parse(json['agendadoPara'].toString()),
      enviadoEm: _parseDate(json['enviadoEm']),
      lidoEm: _parseDate(json['lidoEm']),
      status: json['status'] as String? ?? 'PENDENTE',
      lida: json['lida'] == true,
    );
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.parse(value.toString());

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    return _parseInt(value);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
