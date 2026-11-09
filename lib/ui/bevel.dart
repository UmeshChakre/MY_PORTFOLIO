import 'package:flutter/material.dart';

import '../theme/paint_theme.dart';

enum BevelStyle { raised, sunken, pressed, field }

/// Classic Windows 95 3D border.
class Bevel extends StatelessWidget {
  const Bevel({
    super.key,
    required this.child,
    this.style = BevelStyle.raised,
    this.color = PaintColors.grey,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final BevelStyle style;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BevelPainter(style),
      child: Container(
        color: color,
        margin: const EdgeInsets.all(2),
        padding: padding,
        child: child,
      ),
    );
  }
}

class _BevelPainter extends CustomPainter {
  _BevelPainter(this.style);

  final BevelStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final (outerTL, outerBR, innerTL, innerBR) = switch (style) {
      BevelStyle.raised => (
        PaintColors.light,
        PaintColors.black,
        PaintColors.white,
        PaintColors.darkGrey,
      ),
      BevelStyle.sunken || BevelStyle.field => (
        PaintColors.darkGrey,
        PaintColors.white,
        PaintColors.black,
        PaintColors.light,
      ),
      BevelStyle.pressed => (
        PaintColors.black,
        PaintColors.white,
        PaintColors.darkGrey,
        PaintColors.light,
      ),
    };
    final w = size.width, h = size.height;
    final p = Paint()..isAntiAlias = false;
    void edge(Color c, Rect r) => canvas.drawRect(r, p..color = c);
    // Outer ring.
    edge(outerTL, Rect.fromLTWH(0, 0, w, 1));
    edge(outerTL, Rect.fromLTWH(0, 0, 1, h));
    edge(outerBR, Rect.fromLTWH(0, h - 1, w, 1));
    edge(outerBR, Rect.fromLTWH(w - 1, 0, 1, h));
    // Inner ring.
    edge(innerTL, Rect.fromLTWH(1, 1, w - 2, 1));
    edge(innerTL, Rect.fromLTWH(1, 1, 1, h - 2));
    edge(innerBR, Rect.fromLTWH(1, h - 2, w - 2, 1));
    edge(innerBR, Rect.fromLTWH(w - 2, 1, 1, h - 2));
  }

  @override
  bool shouldRepaint(_BevelPainter old) => old.style != style;
}

/// A Win95 push button that depresses while held.
class RetroButton extends StatefulWidget {
  const RetroButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.selected = false,
    this.tooltip,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final bool selected;
  final String? tooltip;
  final String? semanticLabel;

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pressed = _down || widget.selected;
    Widget button = Semantics(
      button: true,
      label: widget.semanticLabel,
      selected: widget.selected,
      child: MouseRegion(
        cursor: widget.onPressed == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: widget.onPressed,
          child: Bevel(
            style: pressed ? BevelStyle.pressed : BevelStyle.raised,
            color: widget.selected ? PaintColors.light : PaintColors.grey,
            padding: widget.padding,
            child: Transform.translate(
              offset: pressed ? const Offset(1, 1) : Offset.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFE1),
          border: Border.all(color: PaintColors.black),
        ),
        textStyle: PaintText.chrome.copyWith(fontSize: 17),
        child: button,
      );
    }
    return button;
  }
}
