import 'package:flutter/material.dart';

import '../paint/paint_state.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';

/// The colour box at the bottom of Paint. Left click picks the foreground
/// colour, right click (or long press) picks the background colour.
class PaletteBar extends StatelessWidget {
  const PaletteBar({super.key, required this.paint});

  final PaintState paint;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Row(
        children: [
          ListenableBuilder(
            listenable: paint,
            builder: (context, _) => _CurrentColors(paint: paint),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 14 * 18,
            child: Wrap(
              children: [
                for (final c in PaintColors.palette)
                  _Swatch(color: c, paint: paint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentColors extends StatelessWidget {
  const _CurrentColors({required this.paint});

  final PaintState paint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Swap foreground and background colours',
      child: GestureDetector(
        onTap: paint.swapColors,
        child: Bevel(
          style: BevelStyle.sunken,
          color: PaintColors.light,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              children: [
                Positioned(right: 4, bottom: 4, child: _chip(paint.background)),
                Positioned(left: 4, top: 4, child: _chip(paint.foreground)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(Color c) => Container(
    width: 15,
    height: 15,
    decoration: BoxDecoration(
      color: c,
      border: Border.all(color: PaintColors.black),
    ),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.paint});

  final Color color;
  final PaintState paint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Colour #${color.toARGB32().toRadixString(16).substring(2)}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => paint.pickColor(color),
          onSecondaryTap: () => paint.pickColor(color, secondary: true),
          onLongPress: () => paint.pickColor(color, secondary: true),
          child: Bevel(
            style: BevelStyle.sunken,
            color: color,
            child: const SizedBox(width: 14, height: 14),
          ),
        ),
      ),
    );
  }
}
