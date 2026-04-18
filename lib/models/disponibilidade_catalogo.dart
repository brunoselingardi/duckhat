class DisponibilidadeCatalogo {
  final int id;
  final int prestadorId;
  final int diaSemana;
  final String horaInicio;
  final String horaFim;
  final bool ativo;

  DisponibilidadeCatalogo({
    required this.id,
    required this.prestadorId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
    required this.ativo,
  });

  factory DisponibilidadeCatalogo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) =>
        value is int ? value : int.parse(value.toString());

    return DisponibilidadeCatalogo(
      id: parseInt(json['id']),
      prestadorId: parseInt(json['prestadorId']),
      diaSemana: parseInt(json['diaSemana']),
      horaInicio: json['horaInicio'] as String,
      horaFim: json['horaFim'] as String,
      ativo: json['ativo'] as bool? ?? false,
    );
  }
}
