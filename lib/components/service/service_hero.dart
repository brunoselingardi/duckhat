import 'package:flutter/material.dart';

class ServiceHero extends StatelessWidget {
  final VoidCallback onBack;

  const ServiceHero({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/barbie.jpg',
            fit: BoxFit.cover,
            cacheWidth: 800,
            filterQuality: FilterQuality.medium,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.46),
                ],
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeroAction(
                  icon: Icons.arrow_back_ios_new,
                  onTap: onBack,
                  iconSize: 20,
                ),
                Row(
                  children: [
                    _HeroAction(icon: Icons.share_outlined, iconSize: 20),
                    const SizedBox(width: 10),
                    const _FavoriteHeroAction(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteHeroAction extends StatefulWidget {
  const _FavoriteHeroAction();

  @override
  State<_FavoriteHeroAction> createState() => _FavoriteHeroActionState();
}

class _FavoriteHeroActionState extends State<_FavoriteHeroAction> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onTap: _toggleFavorite,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: AnimatedScale(
            scale: _isFavorite ? 1.25 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: _isFavorite ? Colors.red.shade400 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;

  const _HeroAction({required this.icon, this.onTap, this.iconSize = 18});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}
