import 'package:duckhat/components/user/ajuda.dart';
import 'package:duckhat/components/user/configuracoes.dart';
import 'package:duckhat/components/user/editar_perfil.dart';
import 'package:duckhat/components/user/notificacoes.dart';
import 'package:duckhat/components/user/seguranca.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/pages/login.dart';
import 'package:duckhat/pages/signup.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart' show AppColors;
import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = DuckHatApi.instance.currentSession;
    if (session == null) {
      return const _GuestProfilePage();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Builder(
        builder: (ctx) => CustomScrollView(
          key: const PageStorageKey('profile-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: _LoggedProfileHeader(
                nome: session.nome,
                email: session.email,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionLabel('MINHA CONTA'),
            ),
            SliverToBoxAdapter(
              child: _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Editar Perfil',
                onTap: () => Navigator.push(
                  ctx,
                  AppRoute(builder: (_) => const EditarPerfilPage()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _ProfileDivider()),
            SliverToBoxAdapter(
              child: _buildMenuItem(
                icon: Icons.notifications_none_outlined,
                title: 'Notificações',
                onTap: () => Navigator.push(
                  ctx,
                  AppRoute(builder: (_) => const NotificacoesPage()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _ProfileDivider()),
            SliverToBoxAdapter(
              child: _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Minhas Localizações',
                onTap: () => _showComingSoon(ctx),
              ),
            ),
            const SliverToBoxAdapter(child: _ProfileDivider()),
            SliverToBoxAdapter(
              child: _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Segurança e Privacidade',
                onTap: () => Navigator.push(
                  ctx,
                  AppRoute(builder: (_) => const SegurancaPage()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: _buildSectionLabel('CONFIGURAÇÕES'),
            ),
            SliverToBoxAdapter(
              child: _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Configurações',
                onTap: () => Navigator.push(
                  ctx,
                  AppRoute(builder: (_) => const ConfiguracoesPage()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _ProfileDivider()),
            SliverToBoxAdapter(
              child: _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Ajuda',
                onTap: () => Navigator.push(
                  ctx,
                  AppRoute(builder: (_) => const AjudaPage()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _ProfileDivider()),
            SliverToBoxAdapter(
              child: _buildMenuItem(
                icon: Icons.logout,
                title: 'Sair',
                titleColor: AppColors.error,
                showArrow: false,
                onTap: () => _showLogoutDialog(ctx),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 92)),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 16, 9),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.sectionLabel,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    final iconColor = titleColor ?? AppColors.accent;
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? AppColors.textBold,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: AppColors.textMuted.withValues(alpha: 0.8),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext ctx) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }

  static Future<void> _showLogoutDialog(BuildContext ctx) async {
    final shouldLogout = await showDialog<bool>(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !ctx.mounted) return;

    DuckHatApi.instance.clearSession();
    Navigator.of(ctx).pushAndRemoveUntil(
      AppRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}

class _LoggedProfileHeader extends StatelessWidget {
  final String nome;
  final String email;

  const _LoggedProfileHeader({required this.nome, required this.email});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            height: 226,
            width: double.infinity,
            child: Image.asset('assets/ondas.jpg', fit: BoxFit.cover),
          ),
          Positioned(
            top: 132,
            child: Container(
              width: 172,
              height: 172,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.secondary, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/icon.jpg', fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        nome,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textBold,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.accent.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestProfilePage extends StatelessWidget {
  const _GuestProfilePage();

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(AppRoute(builder: (_) => const LoginPage()));
  }

  void _openSignup(BuildContext context) {
    Navigator.of(context).push(
      AppRoute(builder: (_) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED0FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 42, 28, 18),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: AspectRatio(
                          aspectRatio: 0.76,
                          child: Image.asset(
                            'assets/patrick.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 34),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Customize seu perfil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Desbloqueie funcionalidades e ajuste suas preferências para uma busca de serviços mais apropriada para você',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textBold.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => _openSignup(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Crie uma conta!',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _openLogin(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textBold,
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Faça Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.textMuted.withValues(alpha: 0.45),
    );
  }
}
