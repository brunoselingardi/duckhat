class UsuarioPerfil {
  final int id;
  final String nome;
  final String email;
  final String? telefone;
  final String? cnpj;
  final String? responsavelNome;
  final DateTime? dataNascimento;
  final String? endereco;
  final String? descricao;
  final String? horarioAtendimento;
  final String tipo;

  const UsuarioPerfil({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cnpj,
    required this.responsavelNome,
    required this.dataNascimento,
    required this.endereco,
    required this.descricao,
    required this.horarioAtendimento,
    required this.tipo,
  });

  factory UsuarioPerfil.fromJson(Map<String, dynamic> json) {
    return UsuarioPerfil(
      id: _parseInt(json['id']),
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefone: json['telefone'] as String?,
      cnpj: json['cnpj'] as String?,
      responsavelNome: json['responsavelNome'] as String?,
      dataNascimento: _parseDate(json['dataNascimento']),
      endereco: json['endereco'] as String?,
      descricao: json['descricao'] as String?,
      horarioAtendimento: json['horarioAtendimento'] as String?,
      tipo: json['tipo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nome': nome.trim(),
      'email': email.trim().toLowerCase(),
      'telefone': _nullableTrim(telefone),
      'cnpj': _nullableTrim(cnpj),
      'responsavelNome': _nullableTrim(responsavelNome),
      'dataNascimento': dataNascimento == null
          ? null
          : _formatDate(dataNascimento!),
      'endereco': _nullableTrim(endereco),
      'descricao': _nullableTrim(descricao),
      'horarioAtendimento': _nullableTrim(horarioAtendimento),
    };
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.parse(value.toString());

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String? _nullableTrim(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
