import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';
import '../ui/sketchy.dart';
import 'desk_layout.dart';
import 'window_manager.dart';

/// A Win95 window frame: draggable title bar, min/max/close buttons and a
/// marching-ants marquee while it is the active window.
class RetroWindow extends StatelessWidget {
  const RetroWindow({
    super.key,
    required this.spec,
    required this.state,
    required this.active,
    required this.draggable,
  });

  final WindowSpec spec;
  final WindowState state;
  final bool active;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    final windows = AppScope.of(context).windows;
    return RepaintBoundary(
      child: Listener(
        onPointerDown: (_) => windows.focus(spec.id),
        child: Semantics(
          container: true,
          label: spec.title,
          child: Marquee(
            visible: active && draggable,
            inset: -6,
            child: Bevel(
              padding: const EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TitleBar(
                    spec: spec,
                    state: state,
                    active: active,
                    draggable: draggable,
                  ),
                  if (!state.minimized) spec.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({
    required this.spec,
    required this.state,
    required this.active,
    required this.draggable,
  });

  final WindowSpec spec;
  final WindowState state;
  final bool active;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    final windows = AppScope.of(context).windows;
    final handle = Row(
      children: [
        PixelIcon(spec.icon, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            spec.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PaintText.title.copyWith(
              color: active ? PaintColors.white : PaintColors.light,
            ),
          ),
        ),
      ],
    );
    final bar = Container(
      height: 26,
      padding: const EdgeInsets.only(left: 4, right: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? const [PaintColors.navy, PaintColors.titleGradientEnd]
              : const [PaintColors.darkGrey, Color(0xFFB5B5B5)],
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _dragHandle(context, windows, handle)),
          _ChromeButton(
            icon: 'min',
            label: state.minimized ? 'Restore ${spec.taskLabel}' : 'Minimize',
            onTap: () => windows.toggleMinimized(spec.id),
          ),
          _ChromeButton(
            icon: state.maximized ? 'restore' : 'max',
            label: state.maximized ? 'Restore size' : 'Maximize',
            onTap: () => windows.toggleMaximized(spec.id),
          ),
          const SizedBox(width: 2),
          _ChromeButton(
            icon: 'close',
            label: 'Close ${spec.taskLabel}',
            onTap: () => windows.close(spec.id),
          ),
        ],
      ),
    );

    // Titles are chrome, not content: keep them out of text selection.
    return SelectionContainer.disabled(child: bar);
  }

  /// Only the icon + title area drags / double-click-maximizes, so the
  /// buttons respond instantly instead of waiting out a double-tap.
  Widget _dragHandle(
    BuildContext context,
    WindowManager windows,
    Widget handle,
  ) {
    if (!draggable) return handle;
    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => windows.focus(spec.id),
        onPanUpdate: (d) {
          final desk = context.findAncestorRenderObjectOfType<RenderDesk>();
          // The window's own box is the desk's direct child.
          RenderObject? node = context.findRenderObject();
          while (node != null && node.parent != desk) {
            node = node.parent;
          }
          if (desk == null || node is! RenderBox) return;
          windows.move(spec.id, desk.clampDrag(node, d.delta));
        },
        onDoubleTap: () => windows.toggleMaximized(spec.id),
        child: handle,
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 20,
      child: RetroButton(
        padding: EdgeInsets.zero,
        tooltip: label,
        semanticLabel: label,
        onPressed: onTap,
        child: Center(child: PixelIcon(icon, size: 9)),
      ),
    );
  }
}

/// White sunken drawing surface used as the body of most windows.
class CanvasBody extends StatelessWidget {
  const CanvasBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 22),
    this.color = PaintColors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Bevel(
        style: BevelStyle.field,
        color: color,
        padding: padding,
        child: child,
      ),
    );
  }
}
