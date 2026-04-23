class ChatMensagem {
  final int id;
  final int conversaId;
  final int remetenteId;
  final String remetenteNome;
  final String conteudo;
  final DateTime criadoEm;
  final bool enviadaPorMim;

  ChatMensagem({
    required this.id,
    required this.conversaId,
    required this.remetenteId,
    required this.remetenteNome,
    required this.conteudo,
    required this.criadoEm,
    required this.enviadaPorMim,
  });

  factory ChatMensagem.fromJson(Map<String, dynamic> json) {
    return ChatMensagem(
      id: _parseInt(json['id']),
      conversaId: _parseInt(json['conversaId']),
      remetenteId: _parseInt(json['remetenteId']),
      remetenteNome: json['remetenteNome'] as String? ?? '',
      conteudo: json['conteudo'] as String? ?? '',
      criadoEm: DateTime.parse(json['criadoEm'].toString()),
      enviadaPorMim: json['enviadaPorMim'] == true,
    );
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.parse(value.toString());
}
