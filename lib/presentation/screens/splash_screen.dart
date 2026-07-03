import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 3800);
  static const _ballSize = 80.0;

  late final AnimationController _controller;

  // Phase 1: ball drops from above to screen center (0% – 25%).
  late final Animation<double> _drop;

  // Phase 2: ball rests at center (25% – 38%) — implicit pause.

  // Phase 3: ball expands into a huge circle whose center shifts upward,
  // so the bottom arc cuts across ~75% of screen height (38% – 58%).
  late final Animation<double> _expand;

  // Phase 4: logo fades + scales in (50% – 68%).
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  // Phase 5: everything fades out (84% – 100%).
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _total);

    _drop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
    );

    _expand = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.58, curve: Curves.easeInOutCubic),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.65, curve: Curves.easeOut),
    );
    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.68, curve: Curves.easeOutBack),
    );

    _fadeOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.84, 1.0, curve: Curves.easeInCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final accent = ember?.accentOrange ?? const Color(0xFFFF6600);
    final scaffold =
        ember?.scaffoldBackground ?? Theme.of(context).scaffoldBackgroundColor;
    final size = MediaQuery.sizeOf(context);

    // The expanded circle must be wide enough that its arc spans the full
    // screen width when its center is shifted upward.
    // With center at -20% of height, the bottom edge should be at ~80% height.
    // Radius = distance from center to that bottom edge point at screen edge.
    final expandedRadius = size.width * 1.6;
    final expandedDiam = expandedRadius * 2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final expandT = _expand.value;
        final diameter = _ballSize + (expandedDiam - _ballSize) * expandT;

        // Drop phase: start above screen, land at center.
        final dropStartY = -(size.height * 0.5 + _ballSize);
        final dropY = dropStartY * (1.0 - _drop.value);

        // During expand, shift the circle's center upward so only its lower
        // arc is visible on screen — creating the wave cutoff like the ref.
        final expandShiftY = -size.height * 0.45 * expandT;

        final circleY = dropY + expandShiftY;

        // Logo sits in the upper-center of the colored region.
        final logoY = -size.height * 0.08 * expandT;

        return Opacity(
          opacity: 1.0 - _fadeOut.value,
          child: Material(
            color: scaffold,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, circleY),
                  child: Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, logoY),
                  child: Opacity(
                    opacity: _logoFade.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.6 + (_logoScale.value * 0.4),
                      child: _LogoBox(accent: accent),
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

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
      ),
    );
  }
}
