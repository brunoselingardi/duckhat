import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopAboutPage extends StatelessWidget {
  const ShopAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildShopAppBar(context, title: 'Sobre o App'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DuckHat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkAlt,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versão 1.0.0',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoSection('DESENVOLVEDOR', 'DuckHat Tech'),
          _buildInfoSection('CONTATO', 'contato@duckhat.com'),
          _buildInfoSection('SITE', 'www.duckhat.com'),
          const SizedBox(height: 16),
          _buildMenuItem('Termos de Uso', () {}),
          _buildMenuItem('Política de Privacidade', () {}),
          _buildMenuItem('Licenças', () {}),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2024 DuckHat. Todos os direitos reservados.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.darkAlt)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(color: AppColors.darkAlt)),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}
