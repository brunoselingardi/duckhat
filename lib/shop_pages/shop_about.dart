import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopAboutPage extends StatelessWidget {
  const ShopAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: themeColors.background,
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
                Text(
                  'DuckHat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versão 1.0.0',
                  style: TextStyle(color: themeColors.mutedText),
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
              style: TextStyle(fontSize: 12, color: themeColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Builder(
      builder: (context) {
        final themeColors = AppThemeColors.of(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: buildShopCardDecorationFor(context, radius: 12),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: themeColors.mutedText,
                ),
              ),
              const Spacer(),
              Text(value, style: TextStyle(color: themeColors.primaryText)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        final themeColors = AppThemeColors.of(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: themeColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: themeColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: ListTile(
                title: Text(
                  title,
                  style: TextStyle(color: themeColors.primaryText),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: themeColors.mutedText,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
