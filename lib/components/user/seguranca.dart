import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class SegurancaPage extends StatelessWidget {
  const SegurancaPage({super.key});

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
          'Segurança e Privacidade',
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
          _buildSectionTitle('SEGURANÇA'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            subtitle: 'Última alteração há 30 dias',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.fingerprint,
            title: 'Biometria',
            subtitle: 'Usar impressão digital para login',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppColors.accent,
            ),
          ),
          _buildItem(
            icon: Icons.phone_android,
            title: 'Verificação em Dois Fatores',
            subtitle: 'Adiciona uma camada extra de segurança',
            onTap: () => _showEmBreve(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('PRIVACIDADE'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.visibility_off_outlined,
            title: 'Perfil Privado',
            subtitle: 'Apenas clientes agendados podem ver seu perfil',
            trailing: Switch(
              value: false,
              onChanged: (v) {},
              activeThumbColor: AppColors.accent,
            ),
          ),
          _buildItem(
            icon: Icons.location_off_outlined,
            title: 'Localização',
            subtitle: 'Controlar acesso à localização',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.share_outlined,
            title: 'Dados Compartilhados',
            subtitle: 'Gerenciar quais dados são compartilhados',
            onTap: () => _showEmBreve(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('CONTA'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.delete_outline,
            title: 'Excluir Conta',
            subtitle: 'Remover conta e todos os dados',
            titleColor: Colors.red,
            onTap: () => _showExcluirDialog(context),
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
    required String subtitle,
    Widget? trailing,
    Color? titleColor,
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
            color: (titleColor ?? AppColors.accent).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: titleColor ?? AppColors.accent, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: titleColor ?? AppColors.darkAlt,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: AppColors.grayField),
        ),
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

  void _showExcluirDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Conta excluída')));
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
