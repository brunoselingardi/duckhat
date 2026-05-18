import 'package:duckhat/components/user/profile_settings_ui.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsScaffold(
      title: 'Ajuda',
      heroTitle: 'Suporte DuckHat',
      heroSubtitle:
          'Encontre respostas rápidas sobre perfil, agenda, chat e serviços.',
      heroIcon: Icons.help_outline,
      children: [
        _SearchField(onTap: () => _showEmBreve(context)),
        const SizedBox(height: 18),
        ProfileSettingsSection(
          title: 'PERGUNTAS FREQUENTES',
          children: const [
            _FaqTile(
              question: 'Como agendar um serviço?',
              answer:
                  'Use a busca, abra o perfil do estabelecimento, escolha o serviço e selecione uma data com horário disponível.',
            ),
            ProfileSettingsDivider(),
            _FaqTile(
              question: 'Como cancelar um agendamento?',
              answer:
                  'Abra a agenda, toque no card do agendamento e use a ação de cancelamento na tela de detalhes.',
            ),
            ProfileSettingsDivider(),
            _FaqTile(
              question: 'Como alterar meu perfil?',
              answer:
                  'Entre em Perfil e toque em Editar perfil para atualizar seus dados pessoais.',
            ),
            ProfileSettingsDivider(),
            _FaqTile(
              question: 'Como falar com um estabelecimento?',
              answer:
                  'Abra o perfil público do estabelecimento e inicie uma conversa pelo chat.',
            ),
          ],
        ),
        ProfileSettingsSection(
          title: 'CANAIS',
          children: [
            ProfileSettingsTile(
              icon: Icons.email_outlined,
              title: 'E-mail',
              subtitle: 'suporte@duckhat.com',
              onTap: () => _showEmBreve(context),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
              subtitle: 'Atendimento pelo app',
              onTap: () => _showEmBreve(context),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.phone_outlined,
              title: 'Telefone',
              subtitle: '(11) 99999-9999',
              onTap: () => _showEmBreve(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showEmBreve(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }
}

class _SearchField extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchField({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.accent),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Buscar dúvida...',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      iconColor: AppColors.accent,
      collapsedIconColor: AppColors.textMuted,
      title: Text(
        question,
        style: const TextStyle(
          color: AppColors.darkAlt,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
