import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class MetodosPagamentoPage extends StatelessWidget {
  const MetodosPagamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Métodos de Pagamento',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            icon: Icons.credit_card,
            title: 'Cartão de Crédito',
            subtitle: '**** **** **** 4242',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Padrão',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            icon: Icons.credit_card_outlined,
            title: 'Cartão de Débito',
            subtitle: 'Nenhum cartão cadastrado',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAdicionarDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Método de Pagamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkAlt,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.grayField),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showAdicionarDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve: adicionar método de pagamento')),
    );
  }
}
