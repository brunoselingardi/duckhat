import 'package:duckhat/components/user/profile_settings_ui.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/pages/login.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class SegurancaPage extends StatefulWidget {
  const SegurancaPage({super.key});

  @override
  State<SegurancaPage> createState() => _SegurancaPageState();
}

class _SegurancaPageState extends State<SegurancaPage> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsScaffold(
      title: 'Segurança',
      heroTitle: 'Controle da conta',
      heroSubtitle:
          'Revise acesso, privacidade e ações sensíveis do seu perfil DuckHat.',
      heroIcon: Icons.verified_user_outlined,
      children: [
        ProfileSettingsSection(
          title: 'ACESSO',
          children: [
            ProfileSettingsTile(
              icon: Icons.lock_outline,
              title: 'Alterar senha',
              subtitle: 'Atualize sua senha de acesso',
              onTap: () => _showEmBreve(context),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.phone_android_outlined,
              title: 'Verificação em duas etapas',
              subtitle: 'Adicione uma camada extra de proteção',
              onTap: () => _showEmBreve(context),
            ),
          ],
        ),
        ProfileSettingsSection(
          title: 'PRIVACIDADE',
          children: [
            ProfileSettingsTile(
              icon: Icons.visibility_off_outlined,
              title: 'Perfil privado',
              subtitle: 'Controle quem pode ver seus dados no app',
              trailing: Switch(
                value: false,
                onChanged: (_) => _showEmBreve(context),
              ),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.location_off_outlined,
              title: 'Localização',
              subtitle: 'Gerencie o acesso à sua localização',
              onTap: () => _showEmBreve(context),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.share_outlined,
              title: 'Dados compartilhados',
              subtitle: 'Revise os dados usados nos agendamentos',
              onTap: () => _showEmBreve(context),
            ),
          ],
        ),
        ProfileSettingsSection(
          title: 'CONTA',
          children: [
            ProfileSettingsTile(
              icon: Icons.delete_outline,
              title: _deleting ? 'Excluindo conta...' : 'Excluir conta',
              subtitle: 'Remove sua conta e seus dados do DuckHat',
              destructive: true,
              trailing: _deleting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _deleting ? null : _confirmDeleteAccount,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Sua conta, sessão, agendamentos e dados relacionados serão removidos. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Excluir conta',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await DuckHatApi.instance.excluirMinhaConta();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        AppRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _showEmBreve(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }
}
