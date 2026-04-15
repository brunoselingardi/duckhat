import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class ServiceCard extends StatelessWidget {
  final String nome;
  final String duracao;
  final String preco;
  final VoidCallback onAgendar;

  const ServiceCard({
    super.key,
    required this.nome,
    required this.duracao,
    required this.preco,
    required this.onAgendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duracao,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "R\$ $preco",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onAgendar,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Agendar",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceList extends StatelessWidget {
  final List<Map<String, dynamic>> servicos;

  const ServiceList({super.key, required this.servicos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: servicos.map((servico) {
        return ServiceCard(
          nome: servico["nome"],
          duracao: servico["duracao"],
          preco: servico["preco"],
          onAgendar: () {},
        );
      }).toList(),
    );
  }
}
