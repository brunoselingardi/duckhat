import 'package:flutter/material.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/pages/login.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopPrivacyPage extends StatefulWidget {
  const ShopPrivacyPage({super.key});

  @override
  State<ShopPrivacyPage> createState() => _ShopPrivacyPageState();
}

class _ShopPrivacyPageState extends State<ShopPrivacyPage> {
  bool _perfilPrivado = false;
  bool _mostrarContato = true;
  bool _mostrarLocal = true;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.of(context).background,
      appBar: buildShopAppBar(
        context,
        title: 'Segurança',
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildHero(),
          const SizedBox(height: 18),
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
          _buildMenuItem(
            Icons.lock_outline,
            'Alterar senha',
            'Atualize a senha de acesso da empresa',
            () => _showComingSoon(context),
          ),
          _buildMenuItem(
            Icons.phone_android_outlined,
            'Autenticação em duas etapas',
            'Proteção extra para operações do estabelecimento',
            () => _showComingSoon(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('DADOS'),
          _buildMenuItem(
            Icons.download_outlined,
            'Baixar meus dados',
            'Exportação das informações do perfil',
            () => _showComingSoon(context),
          ),
          _buildMenuItem(
            Icons.delete_outline,
            _deleting ? 'Excluindo conta...' : 'Excluir minha conta',
            'Remove estabelecimento, serviços e dados relacionados',
            _deleting ? null : _showDeleteDialog,
            isDestructive: true,
            trailing: _deleting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowAccent,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Controle do estabelecimento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Gerencie exposição pública, acesso e ações sensíveis da conta.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
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
    return Builder(
      builder: (context) {
        final themeColors = AppThemeColors.of(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeColors.border),
            boxShadow: buildShopCardDecorationFor(
              context,
              radius: 12,
            ).boxShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: themeColors.primaryText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColors.mutedText,
                      ),
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
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    bool isDestructive = false,
    Widget? trailing,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.accent;
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? AppColors.error
                        : themeColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(
                    color: themeColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing:
                    trailing ??
                    Icon(Icons.chevron_right, color: themeColors.mutedText),
              ),
            ),
          ),
        );
      },
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

  Future<void> _showDeleteDialog() async {
    final sessionEmail = DuckHatApi.instance.currentSession?.email.trim() ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ShopDeleteAccountDialog(sessionEmail: sessionEmail),
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
}

class _ShopDeleteAccountDialog extends StatefulWidget {
  final String sessionEmail;

  const _ShopDeleteAccountDialog({required this.sessionEmail});

  @override
  State<_ShopDeleteAccountDialog> createState() =>
      _ShopDeleteAccountDialogState();
}

class _ShopDeleteAccountDialogState extends State<_ShopDeleteAccountDialog> {
  late final TextEditingController _controller;
  String _typed = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid =>
      widget.sessionEmail.isNotEmpty &&
      _typed.trim().toLowerCase() == widget.sessionEmail.toLowerCase();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir conta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O estabelecimento, serviços, agenda e dados relacionados serão removidos. Esta ação não pode ser desfeita.',
            ),
            const SizedBox(height: 14),
            Text(
              'Para confirmar, digite o e-mail da conta:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            SelectableText(
              widget.sessionEmail.isEmpty
                  ? 'E-mail indisponível'
                  : widget.sessionEmail,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'E-mail do estabelecimento',
                errorText: _typed.isEmpty || _isValid
                    ? null
                    : 'Digite o e-mail exatamente como exibido.',
              ),
              onChanged: (value) => setState(() => _typed = value),
              onSubmitted: (_) {
                if (_isValid) Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _isValid ? () => Navigator.pop(context, true) : null,
          child: Text(
            'Excluir conta',
            style: TextStyle(color: _isValid ? AppColors.error : null),
          ),
        ),
      ],
    );
  }
}
