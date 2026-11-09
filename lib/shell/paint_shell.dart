import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../desk/desk.dart';
import '../paint/doodle_layer.dart';
import '../paint/paint_state.dart';
import '../platform/browser.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';
import 'dialogs.dart';
import 'menus.dart';
import 'palette.dart';
import 'taskbar.dart';
import 'toolbox.dart';

/// The maximised "umesh_chakradhar.bmp - Paint" window plus the taskbar.
class PaintShell extends StatelessWidget {
  const PaintShell({super.key});

  @override
  Widget build(BuildContext context) {
    final paint = AppScope.of(context).paint;
    final compact = context.isCompact;

    return Scaffold(
      backgroundColor: PaintColors.desktop,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Bevel(
                padding: const EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AppTitleBar(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: PaintMenuBar(),
                    ),
                    const Divider(
                      height: 2,
                      thickness: 1,
                      color: PaintColors.darkGrey,
                    ),
                    if (compact) ToolBox(paint: paint, horizontal: true),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!compact) ToolBox(paint: paint),
                          const Expanded(child: _CanvasArea()),
                        ],
                      ),
                    ),
                    PaletteBar(paint: paint),
                    _StatusBar(paint: paint),
                  ],
                ),
              ),
            ),
            const Taskbar(),
          ],
        ),
      ),
    );
  }
}

class _AppTitleBar extends StatelessWidget {
  const _AppTitleBar();

  @override
  Widget build(BuildContext context) {
    Widget button(String icon, String label, VoidCallback onTap) => SizedBox(
      width: 24,
      height: 21,
      child: RetroButton(
        padding: EdgeInsets.zero,
        semanticLabel: label,
        tooltip: label,
        onPressed: onTap,
        child: Center(child: PixelIcon(icon, size: 9)),
      ),
    );

    return Container(
      height: 28,
      padding: const EdgeInsets.only(left: 4, right: 3),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [PaintColors.navy, PaintColors.titleGradientEnd],
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              'assets/images/chakre.jpeg',
              width: 18,
              height: 18,
              cacheWidth: 36,
              filterQuality: FilterQuality.none,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'umesh_chakradhar.bmp - Paint',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PaintText.title,
            ),
          ),
          button('min', 'Minimize', () {
            showRetroDialog(
              context,
              title: 'Paint',
              message:
                  "Can't minimize a masterpiece. Try the windows "
                  'inside instead!',
            );
          }),
          button('max', 'Full screen', Browser.toggleFullscreen),
          const SizedBox(width: 2),
          button('close', 'Close', () => showExit(context)),
        ],
      ),
    );
  }
}

/// The grey work area holding the white canvas, desk and doodle layer.
class _CanvasArea extends StatelessWidget {
  const _CanvasArea();

  @override
  Widget build(BuildContext context) {
    final paint = AppScope.of(context).paint;
    final compact = context.isCompact;
    final pad = compact ? 8.0 : 18.0;

    return Bevel(
      style: BevelStyle.sunken,
      color: PaintColors.darkGrey,
      child: Scrollbar(
        thumbVisibility: !compact,
        child: SingleChildScrollView(
          primary: true,
          padding: EdgeInsets.all(pad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: ListenableBuilder(
                listenable: paint,
                builder: (context, child) {
                  final media = MediaQuery.of(context);
                  return MediaQuery(
                    data: media.copyWith(
                      textScaler: TextScaler.linear(paint.zoom),
                    ),
                    child: Container(color: paint.canvas, child: child),
                  );
                },
                child: _CanvasContent(paint: paint, compact: compact),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CanvasContent extends StatelessWidget {
  const _CanvasContent({required this.paint, required this.compact});

  final PaintState paint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => paint.cursor.value = e.localPosition,
      onExit: (_) => paint.cursor.value = null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 10 : 30,
              compact ? 16 : 30,
              compact ? 10 : 30,
              compact ? 24 : 48,
            ),
            child: const SelectionArea(child: Desk()),
          ),
          Positioned.fill(child: DoodleLayer(paint: paint)),
          // Paint's canvas resize handles.
          for (final a in const [
            Alignment.bottomRight,
            Alignment.bottomCenter,
            Alignment.centerRight,
          ])
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: a,
                  child: FractionalTranslation(
                    translation: Offset(a.x > 0 ? 0.5 : 0, a.y > 0 ? 0.5 : 0),
                    child: Container(
                      width: 5,
                      height: 5,
                      color: PaintColors.navy,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.paint});

  final PaintState paint;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    Widget cell(Widget child, {double? width}) => Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Bevel(
        style: BevelStyle.sunken,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: SizedBox(width: width, child: child),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 1),
      child: Row(
        children: [
          Expanded(
            child: cell(
              ListenableBuilder(
                listenable: paint,
                builder: (context, _) => Text(
                  paint.tool == PaintTool.select
                      ? compact
                            ? 'Tip: pick the pencil & doodle!'
                            : 'For Help, click Help Topics on the Help Menu.  '
                                  'Tip: pick the pencil and doodle anywhere!'
                      : paint.tool.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PaintText.chrome.copyWith(fontSize: 18),
                ),
              ),
            ),
          ),
          if (!compact)
            cell(
              width: 96,
              ValueListenableBuilder<Offset?>(
                valueListenable: paint.cursor,
                builder: (context, p, _) => Row(
                  children: [
                    const PixelIcon('select', size: 14),
                    const SizedBox(width: 4),
                    Text(
                      p == null ? '' : '${p.dx.round()},${p.dy.round()}',
                      style: PaintText.chrome.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
