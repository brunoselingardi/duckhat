import 'package:duckhat/models/servico_catalogo.dart';

class EstabelecimentoCatalogo {
  final int prestadorId;
  final String nome;
  final String? telefone;
  final String? endereco;
  final String? categoria;
  final String? categoriaLabel;
  final String? descricao;
  final String? horarioAtendimento;
  final String? bannerImagemBase64;
  final String? fotoPerfilBase64;
  final int totalServicos;
  final double? precoInicial;
  final List<ServicoCatalogo> servicos;

  const EstabelecimentoCatalogo({
    required this.prestadorId,
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.categoria,
    required this.categoriaLabel,
    required this.descricao,
    required this.horarioAtendimento,
    required this.bannerImagemBase64,
    required this.fotoPerfilBase64,
    required this.totalServicos,
    required this.precoInicial,
    required this.servicos,
  });

  factory EstabelecimentoCatalogo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) =>
        value is int ? value : int.parse(value.toString());

    final rawServices = json['servicos'];
    final services = rawServices is List
        ? rawServices
              .map(
                (item) => ServicoCatalogo.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
        : <ServicoCatalogo>[];

    return EstabelecimentoCatalogo(
      prestadorId: parseInt(json['prestadorId']),
      nome: json['nome'] as String? ?? 'Estabelecimento',
      telefone: json['telefone'] as String?,
      endereco: json['endereco'] as String?,
      categoria: json['categoria'] as String?,
      categoriaLabel: json['categoriaLabel'] as String?,
      descricao: json['descricao'] as String?,
      horarioAtendimento: json['horarioAtendimento'] as String?,
      bannerImagemBase64: json['bannerImagemBase64'] as String?,
      fotoPerfilBase64: json['fotoPerfilBase64'] as String?,
      totalServicos: json['totalServicos'] == null
          ? services.length
          : parseInt(json['totalServicos']),
      precoInicial: json['precoInicial'] == null
          ? null
          : ServicoCatalogo.parseDouble(json['precoInicial']),
      servicos: services,
    );
  }

  String get enderecoPublico => endereco?.trim().isNotEmpty == true
      ? endereco!.trim()
      : 'Endereço não informado';

  String get descricaoPublica => descricao?.trim().isNotEmpty == true
      ? descricao!.trim()
      : 'Este estabelecimento ainda está ajustando a descrição da vitrine.';

  String get horarioPublico => horarioAtendimento?.trim().isNotEmpty == true
      ? horarioAtendimento!.trim()
      : 'Horários sob consulta';

  String get precoInicialLabel {
    if (precoInicial == null) return 'Preços em breve';
    final normalized = precoInicial!.toStringAsFixed(2).replaceAll('.', ',');
    final withoutCents = normalized.endsWith(',00')
        ? normalized.substring(0, normalized.length - 3)
        : normalized;
    return 'A partir de R\$ $withoutCents';
  }
}
