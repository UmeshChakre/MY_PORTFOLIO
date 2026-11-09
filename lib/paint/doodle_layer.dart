import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/paint_theme.dart';
import 'paint_state.dart';

/// Visitor doodles drawn above the canvas. Committed strokes and the
/// in-progress stroke are painted in separate layers so drawing a new stroke
/// never re-rasterises the finished ones.
class DoodleLayer extends StatelessWidget {
  const DoodleLayer({super.key, required this.paint});

  final PaintState paint;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: paint,
      builder: (context, _) {
        final tool = paint.tool;
        final capturing =
            tool.draws || tool == PaintTool.fill || tool == PaintTool.text;
        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _StrokesPainter(paint, paint.committed),
                ),
              ),
            ),
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _ActiveStrokePainter(paint)),
              ),
            ),
            if (capturing) _Capture(paint: paint, tool: tool),
            for (final t in paint.texts)
              Positioned(
                left: t.position.dx,
                top: t.position.dy - 14,
                child: IgnorePointer(
                  ignoring: tool != PaintTool.text,
                  child: _DoodleTextField(text: t),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Capture extends StatelessWidget {
  const _Capture({required this.paint, required this.tool});

  final PaintState paint;
  final PaintTool tool;

  bool _secondary(PointerEvent e) => e.buttons == kSecondaryMouseButton;

  @override
  Widget build(BuildContext context) {
    if (tool == PaintTool.fill || tool == PaintTool.text) {
      return MouseRegion(
        cursor: tool == PaintTool.text
            ? SystemMouseCursors.text
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            if (tool == PaintTool.fill) {
              paint.fillCanvas(paint.foreground);
            } else {
              paint.addText(d.localPosition).focus.requestFocus();
            }
          },
        ),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) =>
            paint.beginStroke(e.localPosition, secondary: _secondary(e)),
        onPointerMove: (e) => paint.extendStroke(e.localPosition),
        onPointerUp: (_) => paint.endStroke(),
        onPointerCancel: (_) => paint.endStroke(),
        // Swallow drags so touch devices draw instead of scrolling.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {},
          onPanUpdate: (_) {},
          onSecondaryTapDown: (_) {},
        ),
      ),
    );
  }
}

void _drawStroke(Canvas canvas, Stroke s) {
  final p = Paint()
    ..color = s.color
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  if (s.spray) {
    for (final pt in s.points) {
      canvas.drawCircle(pt, 0.9, p);
    }
    return;
  }
  if (s.points.length == 1) {
    canvas.drawCircle(s.points.first, s.width / 2, p);
    return;
  }
  final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
  for (var i = 1; i < s.points.length - 1; i++) {
    // Midpoint smoothing keeps fast strokes from looking polygonal.
    final a = s.points[i];
    final b = s.points[i + 1];
    path.quadraticBezierTo(a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  }
  path.lineTo(s.points.last.dx, s.points.last.dy);
  canvas.drawPath(
    path,
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width,
  );
}

class _StrokesPainter extends CustomPainter {
  _StrokesPainter(this.state, Listenable repaint) : super(repaint: repaint);

  final PaintState state;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in state.strokes) {
      _drawStroke(canvas, s);
    }
  }

  @override
  bool shouldRepaint(_StrokesPainter old) => false;
}

class _ActiveStrokePainter extends CustomPainter {
  _ActiveStrokePainter(this.state)
    : super(repaint: Listenable.merge([state.active, state.activeTick]));

  final PaintState state;

  @override
  void paint(Canvas canvas, Size size) {
    final s = state.active.value;
    if (s != null) _drawStroke(canvas, s);
  }

  @override
  bool shouldRepaint(_ActiveStrokePainter old) => false;
}

class _DoodleTextField extends StatelessWidget {
  const _DoodleTextField({required this.text});

  final DoodleText text;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 60, maxWidth: 360),
        child: TextField(
          controller: text.controller,
          focusNode: text.focus,
          maxLines: null,
          style: PaintText.body.copyWith(color: text.color, fontSize: 22),
          cursorColor: text.color,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(4),
            hintText: 'type...',
            hintStyle: TextStyle(color: PaintColors.darkGrey),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: PaintColors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
