import 'package:flutter/material.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/pages/login.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';
import 'shop_establishment_data.dart';
import 'shop_gallery.dart';
import 'shop_work_days.dart';
import 'shop_work_hours.dart';
import 'shop_service_duration.dart';
import 'shop_notifications.dart';
import 'shop_privacy.dart';
import 'shop_help.dart';
import 'shop_about.dart';

class ShopProfilePage extends StatefulWidget {
  const ShopProfilePage({super.key});

  @override
  State<ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage> {
  final DuckHatApi _api = DuckHatApi.instance;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    if (_api.currentSession == null) return;
    try {
      await _api.carregarMeuPerfil();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Builder(
        builder: (ctx) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ValueListenableBuilder<LoginSession?>(
                valueListenable: _api.sessionNotifier,
                builder: (context, session, _) => _buildHeader(session),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ValueListenableBuilder<LoginSession?>(
                      valueListenable: _api.sessionNotifier,
                      builder: (context, session, _) =>
                          _ShopQuickStats(session: session),
                    ),
                    const SizedBox(height: 18),
                    _buildMenuSection(ctx),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 92)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LoginSession? session) {
    final nome = session?.nome ?? 'Estabelecimento';
    final email = session?.email ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowAccent,
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sua empresa',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Perfil do estabelecimento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Conta ativa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 116,
                height: 116,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/Ducklogo.jpg', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    nome,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Atualize sua vitrine, agenda, servicos e preferencias do estabelecimento.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
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

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('VITRINE DO ESTABELECIMENTO'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.store,
            title: 'Dados do Estabelecimento',
            subtitle: 'Capa, logo, nome, endereco e descricao',
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShopEstablishmentDataPage(),
                ),
              );
              if (updated == true) {
                await _refreshProfile();
              }
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.photo_library,
            title: 'Galeria de Fotos',
            subtitle: '5 fotos cadastradas',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopGalleryPage()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.calendar_month,
            title: 'Dias de Funcionamento',
            subtitle: 'Seg a Sex (Sáb e Dom fechado)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopWorkDaysPage()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.schedule,
            title: 'Horários de Serviço',
            subtitle: '08:00 às 18:00',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopWorkHoursPage()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.timer,
            title: 'Serviços e Preços',
            subtitle: 'Tempo e valor de cada serviço',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ShopServiceDurationPage(),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSectionTitle('CONTA E PREFERENCIAS'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Notificações',
            subtitle: 'Preferencias de alertas e mensagens',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopNotificationsPage()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.lock,
            title: 'Privacidade e Segurança',
            subtitle: 'Protecao, dados e acesso da empresa',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopPrivacyPage()),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSectionTitle('SUPORTE E SOBRE'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.help,
            title: 'Ajuda',
            subtitle: 'Duvidas e canais de atendimento',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopHelpPage()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info,
            title: 'Sobre o App',
            subtitle: 'Versao e informacoes do DuckHat',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopAboutPage()),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sair',
            subtitle: 'Encerrar a sessao neste dispositivo',
            titleColor: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ),
        ]),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 16, 9),
      child: Row(
        children: [
          Text(
            title,
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

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final color = titleColor ?? AppColors.accent;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? AppColors.textBold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textRegular,
                      ),
                    ),
                ],
              ),
            ),
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.textMuted.withValues(alpha: 0.45),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    DuckHatApi.instance.clearSession();
    Navigator.of(context).pushAndRemoveUntil(
      AppRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}

class _ShopQuickStats extends StatelessWidget {
  final LoginSession? session;

  const _ShopQuickStats({required this.session});

  @override
  Widget build(BuildContext context) {
    final name = session?.nome.trim() ?? '';
    final initial = name.isEmpty ? 'D' : name.characters.first.toUpperCase();
    final horario = session?.horarioAtendimento?.trim();
    final endereco = session?.endereco?.trim();
    final descricao = session?.descricao?.trim();
    final resumo = [
      if (horario != null && horario.isNotEmpty) horario,
      if (endereco != null && endereco.isNotEmpty) endereco,
    ].join(' · ');
    final subtitle = resumo.isNotEmpty
        ? resumo
        : (descricao != null && descricao.isNotEmpty)
        ? descricao
        : 'Organize dados, fotos, agenda e servicos do estabelecimento.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppColors.accent.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Vitrine pronta para ajustes' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textBold,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 11,
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
}
