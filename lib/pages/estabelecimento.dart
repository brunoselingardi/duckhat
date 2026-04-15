import 'package:flutter/material.dart';
import 'package:duckhat/components/bottomnav.dart';
import 'package:duckhat/components/place/placeheader.dart';
import 'package:duckhat/components/place/placeinfo.dart';
import 'package:duckhat/components/place/servicelist.dart';

class EstabelecimentoPage extends StatefulWidget {
  final String nome;
  final String imagem;
  final double nota;
  final int avaliacoes;
  final String endereco;
  final String horario;
  final String descricao;
  final List<Map<String, dynamic>> servicos;

  const EstabelecimentoPage({
    super.key,
    required this.nome,
    required this.imagem,
    required this.nota,
    required this.avaliacoes,
    required this.endereco,
    required this.horario,
    required this.descricao,
    required this.servicos,
  });

  @override
  State<EstabelecimentoPage> createState() => _EstabelecimentoPageState();
}

class _EstabelecimentoPageState extends State<EstabelecimentoPage> {
  int _selectedNavIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          PlaceHeader(
            imagem: widget.imagem,
            onBack: () => Navigator.pop(context),
            onFavorite: () {},
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PlaceInfo(
                    nome: widget.nome,
                    nota: widget.nota,
                    avaliacoes: widget.avaliacoes,
                    endereco: widget.endereco,
                    horario: widget.horario,
                    descricao: widget.descricao,
                    onChat: () {},
                  ),
                  const SizedBox(height: 16),
                  ServiceList(servicos: widget.servicos),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DuckHatBottomNav(
        selectedIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
      ),
    );
  }
}
