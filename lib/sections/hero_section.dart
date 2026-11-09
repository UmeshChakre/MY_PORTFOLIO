import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/portfolio_data.dart';
import '../desk/retro_window.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/sketchy.dart';
import 'common.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final wide = context.isWide;

    final intro = Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Hello, world! I'm",
          style: PaintText.body.copyWith(
            fontSize: 22,
            color: PaintColors.darkGrey,
          ),
        ),
        const SizedBox(height: 4),
        HandHeading(
          Portfolio.name,
          seed: 7,
          style: PaintText.heading.copyWith(
            fontSize: compact ? 36 : 54,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          Portfolio.headline,
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: PaintText.body.copyWith(
            fontSize: compact ? 22 : 27,
            color: PaintColors.blue,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'I build fast, offline-first mobile apps in Flutter and native '
          'Android - mostly for fintech, where every tap moves real money.',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: PaintText.body,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: compact ? WrapAlignment.center : WrapAlignment.start,
          children: [
            const DownloadCvButton(),
            RetroButton(
              semanticLabel: 'Go to contact form',
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              onPressed: () => AppScope.of(context).windows.reveal('contact'),
              child: Text(
                "Let's talk >",
                style: PaintText.chrome.copyWith(fontSize: 22),
              ),
            ),
          ],
        ),
      ],
    );

    final avatar = _Avatar(size: compact ? 150 : 190);
    const stamp = _StatsStamp();

    final Widget body;
    if (compact) {
      body = Column(
        children: [
          const SizedBox(height: 8),
          avatar,
          const SizedBox(height: 22),
          intro,
          const SizedBox(height: 28),
          stamp,
        ],
      );
    } else if (!wide) {
      body = Column(
        children: [
          Row(
            children: [
              avatar,
              const SizedBox(width: 36),
              Expanded(child: intro),
            ],
          ),
          const SizedBox(height: 24),
          stamp,
        ],
      );
    } else {
      body = Row(
        children: [
          avatar,
          const SizedBox(width: 44),
          Expanded(child: intro),
          const SizedBox(width: 24),
          stamp,
        ],
      );
    }

    return CanvasBody(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 36,
        compact ? 20 : 32,
        compact ? 16 : 36,
        compact ? 28 : 36,
      ),
      child: body,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Marquee(
            handles: true,
            inset: -6,
            child: Image.asset(
              'assets/images/chakre.jpeg',
              width: size,
              height: size,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              cacheWidth: (size * 2).round(),
              semanticLabel: 'Pixel-art portrait of Umesh Chakradhar',
            ),
          ),
          Positioned(
            right: -14,
            bottom: -30,
            child: Transform.rotate(
              angle: -0.12,
              child: Text(
                "that's me!",
                style: PaintText.body.copyWith(
                  color: PaintColors.red,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A rubber-stamp badge with the key numbers.
class _StatsStamp extends StatelessWidget {
  const _StatsStamp();

  static const ink = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: CustomPaint(
        painter: _StampPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '* CERTIFIED *',
                style: PaintText.chrome.copyWith(
                  color: ink,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              for (final s in Portfolio.stats)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 118,
                        child: Text(
                          s.value,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                          style: PaintText.heading.copyWith(
                            color: ink,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 108,
                        child: Text(
                          s.label,
                          style: PaintText.body.copyWith(
                            color: ink,
                            fontSize: 18,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ink = Paint()
      ..color = _StatsStamp.ink.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(Sketch.rect(rect.deflate(2), 41, rough: 1.8), ink);
    canvas.drawPath(
      Sketch.rect(rect.deflate(8), 42, rough: 1.2, passes: 1),
      ink..strokeWidth = 1.5,
    );
    // Uneven ink: a few faded blotches.
    final r = math.Random(5);
    final fade = Paint()..color = const Color(0x14D32F2F);
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        10 + r.nextDouble() * 18,
        fade,
      );
    }
  }

  @override
  bool shouldRepaint(_StampPainter old) => false;
}
