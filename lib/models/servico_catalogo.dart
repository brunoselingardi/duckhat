class ServicoCatalogo {
  final int id;
  final int prestadorId;
  final String nome;
  final String? descricao;
  final int duracaoMin;
  final double preco;

  ServicoCatalogo({
    required this.id,
    required this.prestadorId,
    required this.nome,
    required this.descricao,
    required this.duracaoMin,
    required this.preco,
  });

  factory ServicoCatalogo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) =>
        value is int ? value : int.parse(value.toString());

    return ServicoCatalogo(
      id: parseInt(json['id']),
      prestadorId: parseInt(json['prestadorId']),
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      duracaoMin: parseInt(json['duracaoMin']),
      preco: parseDouble(json['preco']),
    );
  }

  static double parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString().replaceAll(',', '.'));
  }
}
