import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/man_imBored.png", height: 140),

          const SizedBox(height: 20),

          const Text(
            "Não encontramos nada T-T",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            selectionColor: Color.fromRGBO(45, 34, 91, 1),
          ),

          const SizedBox(height: 8),

          const Text(
            "Tente mudar os filtros ou pesquisar outra coisa",
            style: TextStyle(color: Color.fromRGBO(45, 34, 91, 0.8)),
          ),
        ],
      ),
    );
  }
}
