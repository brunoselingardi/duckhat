import 'package:flutter/material.dart';
import 'package:duckhat/components/user/editar_perfil.dart';
import 'package:duckhat/components/user/metodos_pagamento.dart';
import 'package:duckhat/components/user/notificacoes.dart';
import 'package:duckhat/components/user/seguranca.dart';
import 'package:duckhat/components/user/configuracoes.dart';
import 'package:duckhat/components/user/ajuda.dart';
import 'package:duckhat/theme.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Builder(
        builder: (ctx) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSectionLabel('MINHA CONTA', Icons.account_circle),
              _buildMenuCard([
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Editar Perfil',
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const EditarPerfilPage()),
                  ),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Métodos de Pagamento',
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const MetodosPagamentoPage(),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notificações',
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const NotificacoesPage()),
                  ),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Segurança e Privacidade',
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const SegurancaPage()),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildSectionLabel('CONFIGURAÇÕES', Icons.tune),
              _buildMenuCard([
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const ConfiguracoesPage(),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Ajuda',
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const AjudaPage()),
                  ),
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Sair',
                  titleColor: Colors.red,
                  showArrow: false,
                  onTap: () => _showLogoutDialog(ctx),
                ),
              ]),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: AppColors.accent,
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Estadosunilson',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'estadosunilson@hotmail.com.br',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
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
      borderRadius: BorderRadius.circular(12),
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? AppColors.darkAlt,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 66,
      endIndent: 16,
      color: Color(0xFFF0F0F0),
    );
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
