import 'package:flutter/material.dart';
import 'package:duckhat/components/user/editar_perfil.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  static const Color kBackgroundColor = Color(0xFFF0F4F8);
  static const Color kPrimaryColor = Color(0xFF3A7FD5);
  static const Color kPrimaryLightOpaque = Color(0xFF8EB5F0);
  static const Color kSecondaryBackgroundColor = Color(0xFFFFFFFF);
  static const Color kBlackColor = Color(0xFF0C0041);
  static const Color kGray70Color = Color(0xB30F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
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
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notificações',
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Segurança e Privacidade',
                ),
              ]),
              const SizedBox(height: 16),
              _buildSectionLabel('CONFIGURAÇÕES', Icons.tune),
              _buildMenuCard([
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                ),
                _buildDivider(),
                _buildMenuItem(icon: Icons.help_outline, title: 'Ajuda'),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Sair',
                  titleColor: Colors.red,
                  showArrow: false,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryLightOpaque],
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
                  color: kPrimaryColor,
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
          Icon(icon, size: 16, color: kGray70Color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kGray70Color,
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
        color: kSecondaryBackgroundColor,
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
    final iconColor = titleColor ?? kPrimaryColor;
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
                  color: titleColor ?? kBlackColor,
                ),
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right, color: kGray70Color, size: 22),
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
}
