import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import '../theme/paint_theme.dart';

/// Shared helpers for "drawn by hand" strokes. Everything is seeded so the
/// wobble is stable between frames (no shimmering on repaint).
abstract final class Sketch {
  /// A slightly bowed line from [a] to [b], with jittered end points.
  static void line(
    Path path,
    Offset a,
    Offset b,
    math.Random r, {
    double rough = 1.4,
  }) {
    double j() => (r.nextDouble() - 0.5) * 2 * rough;
    final start = a + Offset(j(), j());
    final end = b + Offset(j(), j());
    final mid = Offset.lerp(start, end, 0.4 + r.nextDouble() * 0.2)!;
    final dir = end - start;
    final len = dir.distance;
    final normal = len == 0 ? Offset.zero : Offset(-dir.dy, dir.dx) / len;
    final bow = normal * (j() * 1.2 + len * 0.004 * (r.nextBool() ? 1 : -1));
    path
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx + bow.dx, mid.dy + bow.dy, end.dx, end.dy);
  }

  /// A rough rectangle traced twice, like a quick pen sketch.
  static Path rect(Rect rect, int seed, {double rough = 1.4, int passes = 2}) {
    final r = math.Random(seed);
    final path = Path();
    for (var i = 0; i < passes; i++) {
      line(path, rect.topLeft, rect.topRight, r, rough: rough);
      line(path, rect.topRight, rect.bottomRight, r, rough: rough);
      line(path, rect.bottomRight, rect.bottomLeft, r, rough: rough);
      line(path, rect.bottomLeft, rect.topLeft, r, rough: rough);
    }
    return path;
  }

  /// A loose, not-quite-closed hand-drawn ellipse.
  static Path ellipse(Rect rect, int seed, {int loops = 2}) {
    final r = math.Random(seed);
    final path = Path();
    final c = rect.center;
    final start = r.nextDouble() * math.pi * 2;
    const steps = 48;
    for (var loop = 0; loop < loops; loop++) {
      final rx = rect.width / 2 + (r.nextDouble() - 0.5) * 4;
      final ry = rect.height / 2 + (r.nextDouble() - 0.5) * 4;
      for (var i = 0; i <= steps; i++) {
        final t = start + loop * 0.3 + i / steps * math.pi * 2.08;
        final wobble = 1 + (r.nextDouble() - 0.5) * 0.025;
        final p =
            c + Offset(math.cos(t) * rx * wobble, math.sin(t) * ry * wobble);
        if (loop == 0 && i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
    }
    return path;
  }
}

/// A box with a rough pen-drawn outline and an optional fill.
class SketchyBox extends StatelessWidget {
  const SketchyBox({
    super.key,
    required this.child,
    this.seed = 1,
    this.color = PaintColors.black,
    this.fill,
    this.strokeWidth = 1.6,
    this.padding = const EdgeInsets.all(12),
    this.shadow = false,
  });

  final Widget child;
  final int seed;
  final Color color;
  final Color? fill;
  final double strokeWidth;
  final EdgeInsetsGeometry padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SketchyBoxPainter(
        seed: seed,
        color: color,
        fill: fill,
        strokeWidth: strokeWidth,
        shadow: shadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _SketchyBoxPainter extends CustomPainter {
  _SketchyBoxPainter({
    required this.seed,
    required this.color,
    required this.fill,
    required this.strokeWidth,
    required this.shadow,
  });

  final int seed;
  final Color color;
  final Color? fill;
  final double strokeWidth;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (shadow) {
      canvas.drawRect(
        rect.shift(const Offset(5, 5)),
        Paint()..color = const Color(0x33000000),
      );
    }
    if (fill != null) canvas.drawRect(rect, Paint()..color = fill!);
    canvas.drawPath(
      Sketch.rect(rect.deflate(1), seed),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SketchyBoxPainter old) =>
      old.seed != seed ||
      old.color != color ||
      old.fill != fill ||
      old.strokeWidth != strokeWidth ||
      old.shadow != shadow;
}

/// Heading text with a scribbled marker underline.
class HandHeading extends StatelessWidget {
  const HandHeading(
    this.text, {
    super.key,
    this.style = PaintText.heading,
    this.underline = PaintColors.red,
    this.seed = 3,
  });

  final String text;
  final TextStyle style;
  final Color underline;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: CustomPaint(
        foregroundPainter: _UnderlinePainter(underline, seed),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RoughText(text, style: style, seed: seed),
        ),
      ),
    );
  }
}

/// Text where every letter is nudged off the baseline and slightly
/// rotated, like quick hand lettering. Words stay intact when wrapping.
/// Meant for short headings: each letter is its own widget.
class RoughText extends StatelessWidget {
  const RoughText(
    this.text, {
    super.key,
    this.style = PaintText.heading,
    this.seed = 1,
    this.wobble = 1,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle style;
  final int seed;

  /// 0 = straight text, 1 = default roughness.
  final double wobble;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final r = math.Random(seed);
    final size = style.fontSize ?? 20;
    final words = text.split(' ');
    final spans = <InlineSpan>[];
    for (var w = 0; w < words.length; w++) {
      if (w > 0) spans.add(const TextSpan(text: ' '));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              for (final ch in words[w].characters)
                Transform.translate(
                  offset: Offset(
                    0,
                    (r.nextDouble() - 0.5) * size * 0.09 * wobble,
                  ),
                  child: Transform.rotate(
                    angle: (r.nextDouble() - 0.5) * 0.14 * wobble,
                    child: Text(
                      ch,
                      style: style.copyWith(
                        // Small per-letter size variation.
                        fontSize:
                            size * (1 + (r.nextDouble() - 0.5) * 0.08 * wobble),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(children: spans),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}

class _UnderlinePainter extends CustomPainter {
  _UnderlinePainter(this.color, this.seed);

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    final y = size.height - 5;
    final path = Path();
    // A quick back-and-forth marker stroke.
    path.moveTo(-2, y + r.nextDouble() * 2);
    final w = size.width * (0.75 + r.nextDouble() * 0.2);
    var x = -2.0;
    while (x < w) {
      x += 14 + r.nextDouble() * 10;
      path.quadraticBezierTo(
        x - 7,
        y + (r.nextDouble() - 0.5) * 4,
        math.min(x, w),
        y + (r.nextDouble() - 0.5) * 3,
      );
    }
    path.quadraticBezierTo(w * 0.6, y + 5, w * 0.15, y + 4);
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_UnderlinePainter old) =>
      old.color != color || old.seed != seed;
}

/// Marching-ants selection rectangle, as drawn by Paint's Select tool.
/// Animates only while [animate] is true.
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.child,
    this.animate = true,
    this.visible = true,
    this.handles = false,
    this.inset = -5,
  });

  final Widget child;
  final bool animate;
  final bool visible;
  final bool handles;
  final double inset;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  final ValueNotifier<int> _phase = ValueNotifier(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(Marquee old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.visible && widget.animate;
    if (run && _timer == null) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 120),
        (_) => _phase.value = (_phase.value + 1) % 8,
      );
    } else if (!run) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the same tree whether or not the marquee shows, so toggling it
    // never rebuilds (or loses the state of) the child subtree.
    return CustomPaint(
      foregroundPainter: widget.visible
          ? _MarqueePainter(_phase, widget.inset, widget.handles)
          : null,
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class _MarqueePainter extends CustomPainter {
  _MarqueePainter(this.phase, this.inset, this.handles) : super(repaint: phase);

  final ValueListenable<int> phase;
  final double inset;
  final bool handles;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(inset);
    const dash = 4.0;
    final shift = phase.value.toDouble();
    final black = Paint()
      ..color = PaintColors.black
      ..strokeWidth = 1
      ..isAntiAlias = false;
    final white = Paint()
      ..color = PaintColors.white
      ..strokeWidth = 1
      ..isAntiAlias = false;

    void dashed(Offset a, Offset b) {
      canvas.drawLine(a, b, white);
      final len = (b - a).distance;
      final dir = (b - a) / len;
      for (var d = -dash * 2 + shift; d < len; d += dash * 2) {
        final s = math.max(0.0, d);
        final e = math.min(len, d + dash);
        if (e > s) canvas.drawLine(a + dir * s, a + dir * e, black);
      }
    }

    dashed(rect.topLeft, rect.topRight);
    dashed(rect.topRight, rect.bottomRight);
    dashed(rect.bottomRight, rect.bottomLeft);
    dashed(rect.bottomLeft, rect.topLeft);

    if (handles) {
      final h = Paint()..color = PaintColors.navy;
      for (final p in [
        rect.topLeft,
        rect.topCenter,
        rect.topRight,
        rect.centerLeft,
        rect.centerRight,
        rect.bottomLeft,
        rect.bottomCenter,
        rect.bottomRight,
      ]) {
        canvas.drawRect(Rect.fromCenter(center: p, width: 6, height: 6), h);
      }
    }
  }

  @override
  bool shouldRepaint(_MarqueePainter old) =>
      old.inset != inset || old.handles != handles;
}
