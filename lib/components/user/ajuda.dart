import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

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
          'Ajuda',
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
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildSectionTitle('PERGUNTAS FREQUENTES'),
          const SizedBox(height: 8),
          _buildFaqItem(
            context,
            'Como agendar um serviço?',
            'Toque no botão de agendamento, escolha o serviço, profissional e horário disponível.',
          ),
          _buildFaqItem(
            context,
            'Como cancelar um agendamento?',
            'Acesse seus agendamentos, selecione o agendamento desejado e toque em cancelar.',
          ),
          _buildFaqItem(
            context,
            'Como alterar meu perfil?',
            'Acesse a página Meu Perfil e toque em Editar Perfil.',
          ),
          _buildFaqItem(
            context,
            'Quais formas de pagamento são aceitas?',
            'Aceitamos cartão de crédito e débito das principais bandeiras.',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('FALE CONOSCO'),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.email_outlined,
            title: 'E-mail',
            subtitle: 'suporte@duckhat.com',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.chat_bubble_outline,
            title: 'Chat',
            subtitle: 'Atendimento online',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.phone_outlined,
            title: 'Telefone',
            subtitle: '(11) 99999-9999',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            icon: Icons.chat,
            title: 'WhatsApp',
            subtitle: '(11) 99999-9999',
            onTap: () => _showEmBreve(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar dúvida...',
          hintStyle: TextStyle(color: AppColors.grayField),
          prefixIcon: const Icon(Icons.search, color: AppColors.accent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
        ),
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

  Widget _buildFaqItem(BuildContext context, String pregunta, String resposta) {
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: AppColors.accent,
        collapsedIconColor: AppColors.textMuted,
        title: Text(
          pregunta,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkAlt,
          ),
        ),
        children: [
          Text(
            resposta,
            style: TextStyle(fontSize: 13, color: AppColors.grayField),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: AppColors.grayField),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }

  void _showEmBreve(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }
}
