import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';

/// A rich, per-post "ultra gradient" hero used in place of an OG image.
///
/// Renders a smooth mesh gradient by painting a base colour and several blurred
/// colour blobs blended together (the technique from the "Ultra Gradients with
/// Flutter" article). Colours and blob layout are seeded deterministically from
/// [seed], so a given post always shows the same gradient while different posts
/// look distinct. The mesh gently drifts unless the platform requests reduced
/// motion.
class EmberGradientHero extends StatefulWidget {
  /// Deterministic seed (e.g. `articleUrl.hashCode` or a post `id`).
  final int seed;

  /// When true the gradient fills its box edge-to-edge, used behind a
  /// [SliverAppBar]'s floating controls on the detail screen.
  final bool fullBleed;

  const EmberGradientHero({
    super.key,
    required this.seed,
    this.fullBleed = false,
  });

  @override
  State<EmberGradientHero> createState() => _EmberGradientHeroState();
}

class _EmberGradientHeroState extends State<EmberGradientHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // React to reduce-motion here (not in build) so build stays side-effect free.
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = _reduceMotion;

    final blobs = _seedBlobs(widget.seed, ember, isDark);
    final baseColor = _baseColor(blobs.first.color, ember, isDark);
    // Matches the content sheet below (SliverAppBar bottom lip / scaffold).
    final fadeColor =
        ember?.scaffoldBackground ?? Theme.of(context).scaffoldBackgroundColor;

    final height = widget.fullBleed ? double.infinity : 180.0;

    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _UltraGradientPainter(
                blobs: blobs,
                baseColor: baseColor,
                fadeColor: fadeColor,
                t: reduceMotion ? 0 : _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A single blurred colour blob in the mesh.
class _Blob {
  /// Relative centre in the 0..1 unit square.
  final Offset center;

  /// Relative radius as a fraction of the shortest side.
  final double radius;

  /// Phase offset so each blob drifts along its own little orbit.
  final double phase;
  final Color color;

  const _Blob({
    required this.center,
    required this.radius,
    required this.phase,
    required this.color,
  });
}

/// Builds 3-4 deterministic blobs from [seed], always anchoring on the brand
/// ember orange and picking the rest from the Ember palette.
List<_Blob> _seedBlobs(int seed, EmberThemeExtension? ember, bool isDark) {
  final random = math.Random(seed);
  final accent = ember?.accentOrange ?? Colors.orange;
  final pool = <Color>[
    accent,
    ember?.commentBorderLevel1 ?? Colors.blue,
    ember?.commentBorderLevel2 ?? Colors.green,
    ember?.commentBorderLevel3 ?? Colors.purple,
    ember?.commentBorderLevel4 ?? Colors.teal,
  ]..shuffle(random);

  // Always lead with the brand accent, then take two or three more hues.
  final colors = <Color>[
    accent,
    ...pool.where((c) => c != accent).take(2 + random.nextInt(2)),
  ];

  return [
    for (final color in colors)
      _Blob(
        center: Offset(random.nextDouble(), random.nextDouble()),
        radius: 0.45 + random.nextDouble() * 0.35,
        phase: random.nextDouble() * math.pi * 2,
        // Blobs stay vivid but a touch softer in light mode.
        color: color.withValues(alpha: isDark ? 0.85 : 0.7),
      ),
  ];
}

/// A dark/light-aware base fill so the mesh stays legible in both themes.
Color _baseColor(Color first, EmberThemeExtension? ember, bool isDark) {
  if (isDark) {
    return Color.lerp(first, Colors.black, 0.72) ?? Colors.black;
  }
  final surface = ember?.scaffoldBackground ?? Colors.white;
  return Color.lerp(first, surface, 0.55) ?? surface;
}

class _UltraGradientPainter extends CustomPainter {
  final List<_Blob> blobs;
  final Color baseColor;
  final double t;

  /// The content-sheet colour the hero's lower edge dissolves into, so the
  /// gradient blends seamlessly into the sheet below instead of cutting hard.
  final Color fadeColor;

  const _UltraGradientPainter({
    required this.blobs,
    required this.baseColor,
    required this.t,
    required this.fadeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = baseColor);

    final shortest = size.shortestSide;
    final sigma = shortest * 0.35;
    // A small orbit so the mesh breathes without the blobs wandering off-canvas.
    final drift = shortest * 0.08;

    for (final blob in blobs) {
      final angle = t * math.pi * 2 + blob.phase;
      final center = Offset(
        blob.center.dx * size.width + math.cos(angle) * drift,
        blob.center.dy * size.height + math.sin(angle) * drift,
      );
      final paint = Paint()
        ..color = blob.color
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
      canvas.drawCircle(center, blob.radius * shortest, paint);
    }

    // Dissolve the lower edge into the content-sheet colour so the hero blends
    // into the sheet below with no hard horizontal seam.
    // final fadeHeight = size.height * 0.55;
    // final fadeRect = Rect.fromLTWH(
    //   0,
    //   size.height - fadeHeight,
    //   size.width,
    //   fadeHeight,
    // );
    // final fadeShader = LinearGradient(
    //   begin: Alignment.topCenter,
    //   end: Alignment.bottomCenter,
    //   colors: [
    //     fadeColor.withValues(alpha: 0),
    //     fadeColor.withValues(alpha: 0.05),
    //     fadeColor.withValues(alpha: 0.2),
    //     fadeColor.withValues(alpha: 0.5),
    //     fadeColor,
    //   ],
    //   stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    // ).createShader(fadeRect);
    // canvas.drawRect(fadeRect, Paint()..shader = fadeShader);
  }

  @override
  bool shouldRepaint(_UltraGradientPainter old) =>
      old.t != t ||
      old.baseColor != baseColor ||
      old.blobs != blobs ||
      old.fadeColor != fadeColor;
}
