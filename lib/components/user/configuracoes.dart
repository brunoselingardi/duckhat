import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

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
          'Configurações',
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
          _buildSectionTitle('GERAL'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Português (Brasil)',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.attach_money,
            title: 'Moeda',
            subtitle: 'BRL - Real Brasileiro',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.schedule,
            title: 'Formato de Hora',
            subtitle: '24 horas',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.calendar_month,
            title: 'Formato de Data',
            subtitle: 'DD/MM/YYYY',
            onTap: () => _showEmBreve(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('APARÊNCIA'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.dark_mode_outlined,
            title: 'Tema',
            subtitle: 'Claro',
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('SOM'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.volume_up_outlined,
            title: 'Sons',
            subtitle: 'Som de notificações ativado',
            trailing: const Switch(value: true, onChanged: null),
          ),
          _buildItem(
            icon: Icons.vibration,
            title: 'Vibração',
            subtitle: 'Vibração ao tocar ativada',
            trailing: const Switch(value: true, onChanged: null),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('SOBRENOUS'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.info_outline,
            title: 'Versão do App',
            subtitle: '1.0.0',
            trailing: const SizedBox.shrink(),
          ),
          _buildItem(
            icon: Icons.description_outlined,
            title: 'Termos de Uso',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de Privacidade',
            onTap: () => _showEmBreve(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.darkAlt,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.grayField),
              )
            : null,
        trailing:
            trailing ??
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }

  void _showEmBreve(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }
}
