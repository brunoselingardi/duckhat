import 'package:duckhat/components/user/profile_settings_ui.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsScaffold(
      title: 'Configurações',
      heroTitle: 'Preferências do app',
      heroSubtitle:
          'Ajuste como o DuckHat aparece e organiza informações da sua conta.',
      heroIcon: Icons.tune_outlined,
      children: [
        ProfileSettingsSection(
          title: 'GERAL',
          children: [
            ProfileSettingsTile(
              icon: Icons.language_outlined,
              title: 'Idioma',
              subtitle: 'Português (Brasil)',
              onTap: () => _showEmBreve(context),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.schedule_outlined,
              title: 'Formato de hora',
              subtitle: '24 horas',
              onTap: () => _showEmBreve(context),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.calendar_month_outlined,
              title: 'Formato de data',
              subtitle: 'DD/MM/AAAA',
              onTap: () => _showEmBreve(context),
            ),
          ],
        ),
        ProfileSettingsSection(
          title: 'APARÊNCIA',
          children: [
            ValueListenableBuilder<ThemeMode>(
              valueListenable: AppThemeController.mode,
              builder: (context, mode, _) {
                final isDark = mode == ThemeMode.dark;
                return ProfileSettingsTile(
                  icon: isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  title: 'Tema',
                  subtitle: isDark ? 'Escuro' : 'Claro',
                  trailing: Switch(
                    value: isDark,
                    onChanged: AppThemeController.setDark,
                  ),
                );
              },
            ),
          ],
        ),
        ProfileSettingsSection(
          title: 'SOBRE',
          children: [
            const ProfileSettingsTile(
              icon: Icons.info_outline,
              title: 'Versão do app',
              subtitle: '1.0.0',
              trailing: SizedBox.shrink(),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.description_outlined,
              title: 'Termos de uso',
              subtitle: 'Condições de uso do DuckHat',
              onTap: () => _showEmBreve(context),
            ),
            const ProfileSettingsDivider(),
            ProfileSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de privacidade',
              subtitle: 'Como seus dados são tratados no app',
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
