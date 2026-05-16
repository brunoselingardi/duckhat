class CatalogoPrestadorBusca {
  final int prestadorId;
  final String nome;
  final String categoriaLabel;
  final String? endereco;
  final String? telefone;
  final String? descricaoPublica;
  final String? horarioAtendimento;
  final String? imagemCapa;
  final String? imagemLogo;
  final String? fotoPerfilBase64;

  const CatalogoPrestadorBusca({
    required this.prestadorId,
    required this.nome,
    required this.categoriaLabel,
    required this.endereco,
    required this.telefone,
    required this.descricaoPublica,
    required this.horarioAtendimento,
    required this.imagemCapa,
    required this.imagemLogo,
    required this.fotoPerfilBase64,
  });

  factory CatalogoPrestadorBusca.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) =>
        value is int ? value : int.parse(value.toString());

    return CatalogoPrestadorBusca(
      prestadorId: parseInt(json['prestadorId']),
      nome: json['nome'] as String? ?? '',
      categoriaLabel:
          json['categoriaLabel'] as String? ?? 'Estabelecimento no DuckHat',
      endereco: json['endereco'] as String?,
      telefone: json['telefone'] as String?,
      descricaoPublica: json['descricaoPublica'] as String?,
      horarioAtendimento: json['horarioAtendimento'] as String?,
      imagemCapa: json['imagemCapa'] as String?,
      imagemLogo: json['imagemLogo'] as String?,
      fotoPerfilBase64: json['fotoPerfilBase64'] as String?,
    );
  }
}
