class ChatConversa {
  final int id;
  final int clienteId;
  final String clienteNome;
  final int prestadorId;
  final String prestadorNome;
  final int participanteId;
  final String participanteNome;
  final String? ultimaMensagem;
  final DateTime? ultimaMensagemEm;

  ChatConversa({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.prestadorId,
    required this.prestadorNome,
    required this.participanteId,
    required this.participanteNome,
    required this.ultimaMensagem,
    required this.ultimaMensagemEm,
  });

  factory ChatConversa.fromJson(Map<String, dynamic> json) {
    return ChatConversa(
      id: _parseInt(json['id']),
      clienteId: _parseInt(json['clienteId']),
      clienteNome: json['clienteNome'] as String? ?? '',
      prestadorId: _parseInt(json['prestadorId']),
      prestadorNome: json['prestadorNome'] as String? ?? '',
      participanteId: _parseInt(json['participanteId']),
      participanteNome: json['participanteNome'] as String? ?? '',
      ultimaMensagem: json['ultimaMensagem'] as String?,
      ultimaMensagemEm: _parseDate(json['ultimaMensagemEm']),
    );
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.parse(value.toString());

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
