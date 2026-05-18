import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:duckhat/theme.dart';

class ShopBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final int unreadChatCount;

  const ShopBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.unreadChatCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: themeColors.surface,
        border: Border(
          top: BorderSide(color: themeColors.border.withValues(alpha: 0.9)),
        ),
        boxShadow: [
          BoxShadow(
            color: themeColors.shadow.withValues(
              alpha: themeColors.isDark ? 0.34 : 0.35,
            ),
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
          backgroundColor: themeColors.surface,
          elevation: 0,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: themeColors.navUnselected,
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
                badgeCount: unreadChatCount,
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
  final int badgeCount;

  const _NavIcon({
    required this.asset,
    required this.isSelected,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.accent : themeColors.navUnselected,
              BlendMode.srcIn,
            ),
            child: SvgPicture.asset(asset, width: 32, height: 32),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: _UnreadBadge(count: badgeCount),
            ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);
    final label = count > 9 ? '9+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: themeColors.surface, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
