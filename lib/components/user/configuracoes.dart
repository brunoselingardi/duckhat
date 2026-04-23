import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configurações',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, 'GERAL'),
          const SizedBox(height: 8),
          _buildItem(
            context,
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Português (Brasil)',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            context,
            icon: Icons.schedule,
            title: 'Formato de Hora',
            subtitle: '24 horas',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            context,
            icon: Icons.calendar_month,
            title: 'Formato de Data',
            subtitle: 'DD/MM/YYYY',
            onTap: () => _showEmBreve(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'APARÊNCIA'),
          const SizedBox(height: 8),
          _buildItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Tema',
            subtitle: AppThemeController.isDark ? 'Escuro' : 'Claro',
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: AppThemeController.mode,
              builder: (context, mode, _) {
                return Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: AppThemeController.setDark,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'SOM'),
          const SizedBox(height: 8),
          _buildItem(
            context,
            icon: Icons.volume_up_outlined,
            title: 'Sons',
            subtitle: 'Som de notificações ativado',
            trailing: const Switch(value: true, onChanged: null),
          ),
          _buildItem(
            context,
            icon: Icons.vibration,
            title: 'Vibração',
            subtitle: 'Vibração ao tocar ativada',
            trailing: const Switch(value: true, onChanged: null),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'SOBRENOUS'),
          const SizedBox(height: 8),
          _buildItem(
            context,
            icon: Icons.info_outline,
            title: 'Versão do App',
            subtitle: '1.0.0',
            trailing: const SizedBox.shrink(),
          ),
          _buildItem(
            context,
            icon: Icons.description_outlined,
            title: 'Termos de Uso',
            onTap: () => _showEmBreve(context),
          ),
          _buildItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Política de Privacidade',
            onTap: () => _showEmBreve(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary.withValues(alpha: 0.62),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.05);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.72 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
            color: colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              )
            : null,
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
      ),
    );
  }

  void _showEmBreve(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }
}
