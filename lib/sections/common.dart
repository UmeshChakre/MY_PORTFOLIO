import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../platform/browser.dart';
import '../data/portfolio_data.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';

/// Renders `*marked*` parts of [source] with a yellow highlighter stroke.
class Highlighted extends StatelessWidget {
  const Highlighted(this.source, {super.key, this.style = PaintText.body});

  final String source;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final parts = source.split('*');
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd
                  ? const TextStyle(
                      backgroundColor: Color(0xAAFFF176),
                      color: PaintColors.black,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

/// A row with a hand-drawn tick (or dash) in front of the text.
class ScribbleBullet extends StatelessWidget {
  const ScribbleBullet({
    super.key,
    required this.child,
    this.color = PaintColors.blue,
    this.seed = 0,
    this.dash = false,
  });

  final Widget child;
  final Color color;
  final int seed;
  final bool dash;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 10),
          child: CustomPaint(
            size: const Size(16, 14),
            painter: _TickPainter(color, seed, dash),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.color, this.seed, this.dash);

  final Color color;
  final int seed;
  final bool dash;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    double j() => (r.nextDouble() - 0.5) * 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    if (dash) {
      path
        ..moveTo(2 + j(), 7 + j())
        ..quadraticBezierTo(8, 5 + j(), 14 + j(), 7 + j());
    } else {
      path
        ..moveTo(1 + j(), 7 + j())
        ..lineTo(6 + j(), 12 + j())
        ..quadraticBezierTo(9, 5, 15 + j(), 1 + j());
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TickPainter old) => false;
}

/// A loose hand-drawn arrow from [from] to [to] (fractions of the box).
class HandArrow extends StatelessWidget {
  const HandArrow({
    super.key,
    required this.size,
    this.from = const Offset(0, 0),
    this.to = const Offset(1, 1),
    this.bend = 0.3,
    this.color = PaintColors.red,
  });

  final Size size;
  final Offset from;
  final Offset to;
  final double bend;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: size,
      painter: _ArrowPainter(from, to, bend, color),
    ),
  );
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.from, this.to, this.bend, this.color);

  final Offset from;
  final Offset to;
  final double bend;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(from.dx * size.width, from.dy * size.height);
    final b = Offset(to.dx * size.width, to.dy * size.height);
    final d = b - a;
    final ctrl = (a + b) / 2 + Offset(-d.dy, d.dx) * bend;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy),
      paint,
    );
    // Arrow head follows the curve's final tangent.
    final tangent = b - ctrl;
    final angle = math.atan2(tangent.dy, tangent.dx);
    for (final side in [-1, 1]) {
      final t = angle + math.pi + side * 0.5;
      canvas.drawLine(b, b + Offset(math.cos(t), math.sin(t)) * 12, paint);
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => false;
}

/// The sketched "Download CV.exe" button.
class DownloadCvButton extends StatelessWidget {
  const DownloadCvButton({super.key});

  @override
  Widget build(BuildContext context) {
    return RetroButton(
      semanticLabel: 'Download CV (PDF)',
      tooltip: 'Umesh_Chakradhar_CV.pdf',
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      onPressed: () =>
          Browser.downloadAsset(Portfolio.cvAsset, 'Umesh_Chakradhar_CV.pdf'),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelIcon('floppy', size: 20),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Download CV.exe',
              style: TextStyle(
                fontFamily: PaintFonts.pixel,
                fontSize: 22,
                height: 1,
                color: PaintColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pixel-font caption, e.g. a section label.
class PixelLabel extends StatelessWidget {
  const PixelLabel(this.text, {super.key, this.color = PaintColors.darkGrey});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: PaintText.chrome.copyWith(color: color, letterSpacing: 1),
  );
}
