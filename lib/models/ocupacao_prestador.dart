class OcupacaoPrestador {
  final DateTime inicioEm;
  final DateTime fimEm;

  OcupacaoPrestador({required this.inicioEm, required this.fimEm});

  factory OcupacaoPrestador.fromJson(Map<String, dynamic> json) {
    return OcupacaoPrestador(
      inicioEm: DateTime.parse(json['inicioEm'] as String),
      fimEm: DateTime.parse(json['fimEm'] as String),
    );
  }

  bool overlaps(DateTime inicio, DateTime fim) {
    return inicio.isBefore(fimEm) && fim.isAfter(inicioEm);
  }
}
