import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopHelpPage extends StatelessWidget {
  const ShopHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.of(context).background,
      appBar: buildShopAppBar(context, title: 'Ajuda'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem(
            context,
            'Como aceitar um agendamento?',
            'Na aba Agenda, toque no agendamento e selecione "Confirmar".',
          ),
          _buildFaqItem(
            context,
            'Como bloquear um horário?',
            'Na aba Agenda, selecione o dia e toque no ícone de bloqueio ao lado do horário.',
          ),
          _buildFaqItem(
            context,
            'Como remarcar um horário?',
            'Toque no ícone de editar no agendamento e selecione "Remarcar". O cliente precisará confirmar.',
          ),
          _buildFaqItem(
            context,
            'Como adicionar serviços?',
            'Va em Perfil > Serviços e Preços e adicione novos serviços.',
          ),
          _buildFaqItem(
            context,
            'Como alterar meu horário de funcionamento?',
            'Va em Perfil > Horários de Serviço e configure.',
          ),
          const SizedBox(height: 24),
          _buildContactItem(
            context,
            'E-mail',
            'suporte@duckhat.com',
            Icons.email,
          ),
          _buildContactItem(context, 'WhatsApp', '(11) 99999-9999', Icons.chat),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: buildShopCardDecorationFor(context, radius: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: themeColors.accent,
        collapsedIconColor: themeColors.mutedText,
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: themeColors.primaryText,
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(fontSize: 13, color: themeColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: buildShopCardDecorationFor(context, radius: 12),
      child: ListTile(
        onTap: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Em breve'))),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: themeColors.accent, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: themeColors.primaryText,
          ),
        ),
        subtitle: Text(value, style: TextStyle(color: themeColors.mutedText)),
        trailing: Icon(Icons.chevron_right, color: themeColors.mutedText),
      ),
    );
  }
}
