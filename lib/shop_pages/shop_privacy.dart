import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class ShopPrivacyPage extends StatefulWidget {
  const ShopPrivacyPage({super.key});

  @override
  State<ShopPrivacyPage> createState() => _ShopPrivacyPageState();
}

class _ShopPrivacyPageState extends State<ShopPrivacyPage> {
  bool _perfilPrivado = false;
  bool _mostrarContato = true;
  bool _mostrarLocal = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacidade e Segurança',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('PRIVACIDADE'),
          _buildToggleItem(
            'Perfil Privado',
            'Apenas clientes agendados podem ver',
            _perfilPrivado,
            (v) => setState(() => _perfilPrivado = v),
          ),
          _buildToggleItem(
            'Mostrar Contato',
            'Clientes podem ver seu telefone',
            _mostrarContato,
            (v) => setState(() => _mostrarContato = v),
          ),
          _buildToggleItem(
            'Mostrar Localização',
            'Clientes podem ver seu endereço',
            _mostrarLocal,
            (v) => setState(() => _mostrarLocal = v),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('SEGURANÇA'),
          _buildMenuItem('Alterar Senha', () => _showComingSoon(context)),
          _buildMenuItem(
            'Autenticação em 2 Fatores',
            () => _showComingSoon(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('DADOS'),
          _buildMenuItem('Baixar meus dados', () => _showComingSoon(context)),
          _buildMenuItem(
            'Excluir minha conta',
            () => _showDeleteDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkAlt,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
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
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.darkAlt,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }

  void _save(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configurações salvas')));
    Navigator.pop(context);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text('Tem certeza? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
