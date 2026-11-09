import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'desk_layout.dart';
import 'retro_window.dart';

/// All open windows, laid out in columns and stacked by z-order.
class Desk extends StatelessWidget {
  const Desk({super.key});

  @override
  Widget build(BuildContext context) {
    final windows = AppScope.of(context).windows;
    final draggable = !context.isCompact;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 2 : 1;
        return ListenableBuilder(
          listenable: windows,
          builder: (context, _) {
            final slots = {
              for (var i = 0; i < windows.specs.length; i++)
                windows.specs[i].id: i,
            };
            return DeskLayout(
              columns: columns,
              gap: context.isCompact ? 20 : 30,
              children: [
                for (final id in windows.zOrder)
                  if (!windows.state(id).closed)
                    DeskSlot(
                      key: ValueKey(id),
                      slot: slots[id]!,
                      fullSpan:
                          windows.spec(id).fullSpan ||
                          windows.state(id).maximized,
                      drag: windows.state(id).offset,
                      child: RetroWindow(
                        key: windows.keys[id],
                        spec: windows.spec(id),
                        state: windows.state(id),
                        active: windows.active == id,
                        draggable: draggable,
                      ),
                    ),
              ],
            );
          },
        );
      },
    );
  }
}
