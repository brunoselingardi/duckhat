import 'dart:ui' show lerpDouble;

import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class PostLoginTransitionPage extends StatefulWidget {
  final Widget destination;
  final String title;
  final String subtitle;

  const PostLoginTransitionPage({
    required this.destination,
    this.title = 'Login realizado',
    this.subtitle = 'Sua conta foi acessada com sucesso.',
    super.key,
  });

  @override
  State<PostLoginTransitionPage> createState() =>
      _PostLoginTransitionPageState();
}

class _PostLoginTransitionPageState extends State<PostLoginTransitionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _overlayVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() => _overlayVisible = false);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.destination),
        if (_overlayVisible)
          Positioned.fill(
            child: IgnorePointer(
              child: _PostLoginOverlay(
                controller: _controller,
                title: widget.title,
                subtitle: widget.subtitle,
              ),
            ),
          ),
      ],
    );
  }
}

class _PostLoginOverlay extends StatelessWidget {
  final AnimationController controller;
  final String title;
  final String subtitle;

  const _PostLoginOverlay({
    required this.controller,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value.clamp(0.0, 1.0);
        final overlayOpacity =
            1 -
            Curves.easeOutCubic.transform(const Interval(0.44, 1).transform(t));
        final ballEnter = Curves.easeOutBack.transform(
          const Interval(0.0, 0.28).transform(t),
        );
        final ballExit = Curves.easeInCubic.transform(
          const Interval(0.32, 1).transform(t),
        );
        final gifAppear = Curves.easeOutCubic.transform(
          const Interval(0.06, 0.3).transform(t),
        );
        final ballScale =
            (lerpDouble(0.78, 1, ballEnter)! - lerpDouble(0, 0.18, ballExit)!)
                .clamp(0.0, 1.2);
        final ballOpacity = (1 - ballExit).clamp(0.0, 1.0);
        final gifScale = lerpDouble(0.72, 1, gifAppear)!.clamp(0.0, 1.0);

        return RepaintBoundary(
          child: ColoredBox(
            color: AppColors.accent.withValues(
              alpha: overlayOpacity.clamp(0.0, 1.0),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Column(
                      children: [
                        _SuccessBanner(title: title, subtitle: subtitle),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: ballOpacity,
                    child: Transform.scale(
                      scale: ballScale,
                      child: RepaintBoundary(
                        child: Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: gifAppear.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: gifScale,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.asset(
                                      'assets/duck-dance.gif',
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SuccessBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.close, color: AppColors.textMuted, size: 16),
        ],
      ),
    );
  }
}

class InstantPageRoute<T> extends PageRouteBuilder<T> {
  InstantPageRoute({required Widget child})
    : super(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => child,
      );
}
