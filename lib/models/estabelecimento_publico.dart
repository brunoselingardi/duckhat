class EstabelecimentoPublico {
  final int id;
  final String nome;
  final String? telefone;
  final String? endereco;
  final String? descricaoPublica;
  final String? horarioAtendimento;
  final String? imagemCapa;
  final String? imagemLogo;
  final String? fotoPerfilBase64;

  const EstabelecimentoPublico({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.descricaoPublica,
    required this.horarioAtendimento,
    required this.imagemCapa,
    required this.imagemLogo,
    required this.fotoPerfilBase64,
  });

  factory EstabelecimentoPublico.fromJson(Map<String, dynamic> json) {
    return EstabelecimentoPublico(
      id: _parseInt(json['id']),
      nome: json['nome'] as String? ?? '',
      telefone: json['telefone'] as String?,
      endereco: json['endereco'] as String?,
      descricaoPublica: json['descricaoPublica'] as String?,
      horarioAtendimento: json['horarioAtendimento'] as String?,
      imagemCapa: json['imagemCapa'] as String?,
      imagemLogo: json['imagemLogo'] as String?,
      fotoPerfilBase64: json['fotoPerfilBase64'] as String?,
    );
  }

  EstabelecimentoPublico mergeFallback(EstabelecimentoPublico fallback) {
    return EstabelecimentoPublico(
      id: id,
      nome: nome.trim().isEmpty ? fallback.nome : nome,
      telefone: _pickValue(telefone, fallback.telefone),
      endereco: _pickValue(endereco, fallback.endereco),
      descricaoPublica: _pickValue(descricaoPublica, fallback.descricaoPublica),
      horarioAtendimento: _pickValue(
        horarioAtendimento,
        fallback.horarioAtendimento,
      ),
      imagemCapa: _pickValue(imagemCapa, fallback.imagemCapa),
      imagemLogo: _pickValue(imagemLogo, fallback.imagemLogo),
      fotoPerfilBase64: _pickValue(fotoPerfilBase64, fallback.fotoPerfilBase64),
    );
  }

  static String? _pickValue(String? primary, String? fallback) {
    final normalized = primary?.trim();
    if (normalized != null && normalized.isNotEmpty) return normalized;
    return fallback;
  }

  static int _parseInt(dynamic value) =>
      value is int ? value : int.parse(value.toString());
}
