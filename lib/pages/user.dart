import 'package:flutter/material.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/components/user/editar_perfil.dart';
import 'package:duckhat/components/user/notificacoes.dart';
import 'package:duckhat/components/user/seguranca.dart';
import 'package:duckhat/components/user/configuracoes.dart';
import 'package:duckhat/components/user/ajuda.dart';
import 'package:duckhat/theme.dart' show AppColors;

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Builder(
        builder: (ctx) => CustomScrollView(
          key: const PageStorageKey('profile-scroll'),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: _buildSectionLabel('MINHA CONTA', Icons.account_circle),
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
              child: _buildSectionLabel('CONFIGURAÇÕES', Icons.tune),
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
                titleColor: Colors.red,
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

  Widget _buildHeader() {
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
                    const Flexible(
                      child: Text(
                        'Estadosunilson',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
                const Text(
                  'estadosunilson@hotmail.com.br',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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

  Widget _buildSectionLabel(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 16, 9),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.sectionLabel,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
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

  void _showComingSoon(BuildContext ctx) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }

  void _showLogoutDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
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
