import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:duckhat/theme.dart';

class ShopBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const ShopBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.35),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: AppColors.splash,
          highlightColor: AppColors.highlight,
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.navUnselected,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _NavIcon(
                asset: 'assets/icones/homepato.svg',
                isSelected: selectedIndex == 0,
              ),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                asset: 'assets/icones/agendapato.svg',
                isSelected: selectedIndex == 1,
              ),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                asset: 'assets/icones/chatpato.svg',
                isSelected: selectedIndex == 2,
              ),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                asset: 'assets/icones/perfilpato.svg',
                isSelected: selectedIndex == 3,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String asset;
  final bool isSelected;

  const _NavIcon({required this.asset, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          isSelected ? AppColors.accent : AppColors.navUnselected,
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset(asset, width: 32, height: 32),
      ),
    );
  }
}
