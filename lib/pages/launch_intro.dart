import 'dart:async';

import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/pages/app_shell.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class LaunchIntroPage extends StatefulWidget {
  const LaunchIntroPage({super.key});

  @override
  State<LaunchIntroPage> createState() => _LaunchIntroPageState();
}

class _LaunchIntroPageState extends State<LaunchIntroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _sheetSlide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _cardSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.58, curve: Curves.easeOutCubic),
    );
    _cardFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.42, curve: Curves.easeOut),
    );
    _sheetSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.95, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2300), _openHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppRoute(builder: (_) => const MainNavigator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED0FB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFAED0FB),
                      AppColors.accent.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(_cardSlide),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(28, 70, 28, 0),
                    child: GuestProfilePreviewCard(),
                  ),
                ),
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_sheetSlide),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuestProfilePreviewCard extends StatelessWidget {
  const GuestProfilePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/patrick.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Dr. Patrick O'Quack",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textBold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
              ),
              child: const Column(
                children: [
                  _GuestProfileRow(icon: Icons.person),
                  Divider(height: 1, color: Color(0xFFE8EDF6)),
                  _GuestProfileRow(icon: Icons.shield_outlined),
                  Divider(height: 1, color: Color(0xFFE8EDF6)),
                  _GuestProfileRow(icon: Icons.medication_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestProfileRow extends StatelessWidget {
  final IconData icon;

  const _GuestProfileRow({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 108,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.textBold.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 54,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}
