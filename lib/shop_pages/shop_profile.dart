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
  String? _backgroundImage;
  String? _profileImage;

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

  void _changeBackground() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolher Plano de Fundo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildBackgroundOption('assets/ondas.jpg'),
                _buildBackgroundOption('assets/praia.jpg'),
                _buildBackgroundOption('assets/cidade.jpg'),
                _buildBackgroundOption(null, label: 'Padrão'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOption(String? image, {String? label}) {
    final isSelected = _backgroundImage == image;
    return GestureDetector(
      onTap: () {
        setState(() => _backgroundImage = image);
        Navigator.pop(context);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(image, fit: BoxFit.cover),
              )
            : Center(
                child: Text(label ?? '', style: const TextStyle(fontSize: 12)),
              ),
      ),
    );
  }

  void _changeProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolher Foto de Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildProfileOption(null, icon: Icons.storefront),
                _buildProfileOption(null, icon: Icons.cut),
                _buildProfileOption(null, icon: Icons.spa),
                _buildProfileOption(null, icon: Icons.medical_services),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(String? image, {IconData? icon}) {
    final isSelected = _profileImage == image;
    return GestureDetector(
      onTap: () {
        setState(() => _profileImage = image);
        Navigator.pop(context);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 3 : 1,
          ),
          color: AppColors.accent,
        ),
        child: icon != null
            ? Icon(icon, size: 40, color: AppColors.primary)
            : image != null
            ? ClipOval(child: Image.asset(image, fit: BoxFit.cover))
            : const Icon(Icons.storefront, size: 40, color: AppColors.primary),
      ),
    );
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
                    const SizedBox(height: 16),
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

    return SizedBox(
      height: 350,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            height: 226,
            width: double.infinity,
            child: _backgroundImage != null
                ? Image.asset(_backgroundImage!, fit: BoxFit.cover)
                : Image.asset('assets/ondas.jpg', fit: BoxFit.cover),
          ),
          GestureDetector(
            onTap: _changeBackground,
            child: Container(
              height: 226,
              width: double.infinity,
              color: AppColors.primary.withValues(alpha: 0),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.wallpaper,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 132,
            child: GestureDetector(
              onTap: _changeProfileImage,
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
                  child: Container(
                    color: AppColors.accent,
                    child: const Icon(
                      Icons.storefront,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
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

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ESTABELECIMENTO'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.store,
            title: 'Dados do Estabelecimento',
            subtitle: 'Nome, telefone, endereço',
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
        _buildSectionTitle('CONTA'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Notificações',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopNotificationsPage()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.lock,
            title: 'Privacidade e Segurança',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopPrivacyPage()),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSectionTitle('SUPORTE'),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.help,
            title: 'Ajuda',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopHelpPage()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info,
            title: 'Sobre o App',
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: color, size: 18),
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
                        fontSize: 12,
                        color: AppColors.textMuted,
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
