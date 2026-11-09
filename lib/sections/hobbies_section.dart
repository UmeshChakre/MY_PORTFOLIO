import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../desk/retro_window.dart';
import '../theme/paint_theme.dart';
import '../ui/pixel_icons.dart';
import '../ui/sketchy.dart';
import 'common.dart';

class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CanvasBody(
      color: const Color(0xFFFFFEF7),
      child: CustomPaint(
        painter: _GridPaperPainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Flexible(
                  child: HandHeading(
                    'When I am not coding...',
                    seed: 51,
                    underline: Color(0xFFFF00FF),
                  ),
                ),
                const SizedBox(width: 6),
                HandArrow(
                  size: const Size(40, 34),
                  from: const Offset(0.05, 0.1),
                  to: const Offset(0.8, 0.95),
                  bend: -0.35,
                  color: PaintColors.darkGrey,
                ),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, c) {
                // Two notes per row when there is room, otherwise one.
                final perRow = c.maxWidth >= 420 ? 2 : 1;
                const gap = 22.0;
                final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap + 6,
                  children: [
                    for (final h in Portfolio.hobbies)
                      SizedBox(
                        width: w,
                        child: _StickyNote(hobby: h),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyNote extends StatelessWidget {
  const _StickyNote({required this.hobby});

  final Hobby hobby;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: hobby.tilt,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SketchyBox(
            seed: hobby.title.length * 13,
            fill: Color(hobby.paper),
            shadow: true,
            strokeWidth: 1.2,
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PixelIcon(hobby.icon, size: 40, semanticLabel: hobby.title),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hobby.title,
                        style: PaintText.heading.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(hobby.note, style: PaintText.small),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // A strip of tape holding the note down.
          Positioned(
            top: -9,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: -hobby.tilt * 2,
                child: Container(
                  width: 64,
                  height: 18,
                  color: const Color(0x99E0E0E0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x1A0080FF)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPaperPainter old) => false;
}
