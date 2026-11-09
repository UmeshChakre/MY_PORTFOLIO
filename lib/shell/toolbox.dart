import 'package:flutter/material.dart';

import '../paint/paint_state.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';

/// Paint's tool box: a 2-column grid of tools plus the options box.
/// With [horizontal] it becomes a single strip for phones.
class ToolBox extends StatelessWidget {
  const ToolBox({super.key, required this.paint, this.horizontal = false});

  final PaintState paint;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: paint,
      builder: (context, _) {
        final buttons = [
          for (final t in PaintTool.values)
            SizedBox(
              width: 30,
              height: 30,
              child: RetroButton(
                padding: EdgeInsets.zero,
                selected: paint.tool == t,
                tooltip: t.label,
                semanticLabel: t.label,
                onPressed: () => paint.tool = t,
                child: Center(child: PixelIcon(t.icon, size: 18)),
              ),
            ),
        ];

        if (horizontal) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: Row(
              children: [
                ...buttons,
                const SizedBox(width: 6),
                _OptionsBox(paint: paint, horizontal: true),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
          child: Column(
            children: [
              SizedBox(width: 60, child: Wrap(children: buttons)),
              const SizedBox(height: 8),
              _OptionsBox(paint: paint),
            ],
          ),
        );
      },
    );
  }
}

class _OptionsBox extends StatelessWidget {
  const _OptionsBox({required this.paint, this.horizontal = false});

  final PaintState paint;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final tool = paint.tool;
    final List<Widget> options;
    if (tool.draws) {
      options = [
        for (var i = 0; i < 3; i++)
          _Option(
            selected: paint.brushSize == i,
            label: 'Size ${i + 1}',
            onTap: () => paint.brushSize = i,
            builder: (fg) => Container(
              width: 6.0 + i * 6,
              height: tool == PaintTool.pencil ? 2.0 + i : 6.0 + i * 6,
              decoration: BoxDecoration(
                color: fg,
                shape: tool == PaintTool.pencil
                    ? BoxShape.rectangle
                    : BoxShape.circle,
              ),
            ),
          ),
      ];
    } else if (tool == PaintTool.zoom) {
      options = [
        for (final z in const [1.0, 1.15, 1.3])
          _Option(
            selected: paint.zoom == z,
            label: 'Zoom ${(z * 100).round()}%',
            onTap: () => paint.zoom = z,
            builder: (fg) => Text(
              '${z == 1 ? 1 : z}x',
              style: PaintText.chrome.copyWith(fontSize: 17, color: fg),
            ),
          ),
      ];
    } else {
      options = const [];
    }

    final content = horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: options)
        : Column(mainAxisSize: MainAxisSize.min, children: options);

    return Bevel(
      style: BevelStyle.sunken,
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        width: horizontal ? null : 50,
        height: horizontal ? 26 : 84,
        child: options.isEmpty ? const SizedBox(width: 26) : content,
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.label,
    required this.onTap,
    required this.builder,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget Function(Color fg) builder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 26,
            color: selected ? PaintColors.navy : Colors.transparent,
            alignment: Alignment.center,
            child: builder(selected ? PaintColors.white : PaintColors.black),
          ),
        ),
      ),
    );
  }
}
