import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:duckhat/theme.dart';

class DuckHatBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const DuckHatBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(0, -2),
            blurRadius: 4,
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
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.navUnselected,
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
              label: 'Chat',
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
