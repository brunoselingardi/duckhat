import 'dart:math' as math;

import 'package:duckhat/pages/login.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LaunchIntroPage extends StatefulWidget {
  const LaunchIntroPage({super.key});

  @override
  State<LaunchIntroPage> createState() => _LaunchIntroPageState();
}

class _LaunchIntroPageState extends State<LaunchIntroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _wordFade;
  late final Animation<Offset> _wordSlide;
  late final Animation<double> _badgeFade;
  late final Animation<double> _loadingFade;
  late final Animation<double> _loadingProgress;
  late final Animation<double> _exitWave;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4300),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.22, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.14, curve: Curves.easeOut),
    );
    _wordFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.14, 0.32, curve: Curves.easeOut),
    );
    _wordSlide = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.14, 0.34, curve: Curves.easeOutCubic),
          ),
        );
    _badgeFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.48, curve: Curves.easeOut),
    );
    _loadingFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.62, curve: Curves.easeOut),
    );
    _loadingProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 0.82, curve: Curves.easeInOutCubic),
      ),
    );
    _exitWave = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 1, curve: Curves.easeInOutCubic),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _openLogin();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, _) =>
            FadeTransition(opacity: animation, child: const LoginPage()),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF020916),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF020916),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                const Positioned.fill(child: _IntroBackground()),
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: const _LogoMark(),
                            ),
                          ),
                          const SizedBox(height: 28),
                          FadeTransition(
                            opacity: _wordFade,
                            child: SlideTransition(
                              position: _wordSlide,
                              child: const _Wordmark(),
                            ),
                          ),
                          const SizedBox(height: 38),
                          FadeTransition(
                            opacity: _badgeFade,
                            child: const _IntentBadge(),
                          ),
                          const SizedBox(height: 26),
                          FadeTransition(
                            opacity: _loadingFade,
                            child: _LoadingStatus(
                              progress: _loadingProgress.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ExitWavePainter(progress: _exitWave.value),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IntroBackground extends StatelessWidget {
  const _IntroBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.22, -0.46),
          radius: 1.12,
          colors: [Color(0xFF103E91), Color(0xFF06142D), Color(0xFF020916)],
          stops: [0, 0.42, 1],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      height: 138,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF247CFF), Color(0xFF063486)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Image.asset(
          'assets/duckhat_detective.png',
          key: const ValueKey('launchIntroDetectiveLogo'),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 46,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: Colors.white,
          ),
          children: [
            TextSpan(text: 'Duck'),
            TextSpan(
              text: 'Hat',
              style: TextStyle(color: Color(0xFF2C83FF)),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentBadge extends StatelessWidget {
  const _IntentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.92),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Descubra seu próximo serviço',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingStatus extends StatelessWidget {
  final double progress;

  const _LoadingStatus({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 214,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2C83FF)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Carregando DuckHat',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExitWavePainter extends CustomPainter {
  final double progress;

  const _ExitWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height * 0.58);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final radius = maxRadius * progress;
    final bluePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.92 * progress);
    final whitePaint = Paint()
      ..color = Colors.white.withValues(
        alpha: math.max(0, progress - 0.42) * 1.75,
      );

    canvas.drawCircle(center, radius, bluePaint);
    canvas.drawCircle(center, math.max(0, radius - 92), whitePaint);
  }

  @override
  bool shouldRepaint(covariant _ExitWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
