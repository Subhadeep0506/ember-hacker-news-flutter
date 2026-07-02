import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Horizontal space added per nesting level (also the spacing between rails).
/// Kept a little wider than the avatar diameter so avatars at adjacent depths
/// don't overlap and the connector elbow has room to read as a curve.
const double kCommentIndent = 32.0;

/// Radius of the author avatar; the connector curve runs into its centre.
const double kCommentAvatarRadius = 15.0;

/// Top padding above the avatar; the connector elbow sits at the avatar centre.
const double kCommentTopPad = 12.0;

/// Paints the monochrome thread rails behind a comment row: continuing vertical
/// lines for ancestors that still have siblings, a curved elbow connecting this
/// comment to its parent, and a stub descending to its own children.
class CommentThreadPainter extends CustomPainter {
  final int depth;

  /// One flag per ancestor column (length == [depth]); true keeps that column's
  /// vertical line running full-height through this row.
  final List<bool> rails;

  /// Whether a rail should descend from this comment's avatar to its children.
  final bool hasChildRail;
  final Color color;
  final double strokeWidth;

  const CommentThreadPainter({
    required this.depth,
    required this.rails,
    required this.hasChildRail,
    required this.color,
    this.strokeWidth = 1.5,
  });

  double _railX(int column) => column * kCommentIndent + kCommentAvatarRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const curveY = kCommentTopPad + kCommentAvatarRadius;

    // Continuing vertical rails for higher ancestors with more siblings below.
    // The immediate-parent column (depth - 1) is handled by the elbow below.
    for (var c = 0; c < depth - 1 && c < rails.length; c++) {
      if (rails[c]) {
        final x = _railX(c);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // Curved elbow from the parent rail into this comment's avatar. The line runs
    // to the avatar centre (behind the opaque avatar) so it always connects.
    if (depth > 0) {
      final parentX = _railX(depth - 1);
      final avatarCenterX = _railX(depth);
      const corner = 14.0;
      final continues = rails.length >= depth && rails[depth - 1];

      final elbow = Path()
        ..moveTo(parentX, 0)
        ..lineTo(parentX, curveY - corner)
        ..quadraticBezierTo(parentX, curveY, parentX + corner, curveY)
        ..lineTo(avatarCenterX, curveY);
      canvas.drawPath(elbow, paint);

      // If this comment has following siblings, keep its parent rail running.
      if (continues) {
        canvas.drawLine(
          Offset(parentX, curveY),
          Offset(parentX, size.height),
          paint,
        );
      }
    }

    // Stub descending from this comment's avatar to its first child.
    if (hasChildRail) {
      final x = _railX(depth);
      canvas.drawLine(Offset(x, curveY), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CommentThreadPainter old) =>
      old.depth != depth ||
      old.hasChildRail != hasChildRail ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      !listEquals(old.rails, rails);
}
