import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/portfolio_data.dart';
import '../platform/browser.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';
import 'menus.dart';

/// Windows 95 taskbar: Start menu, one button per window, and a clock.
/// It doubles as the site's section navigation.
class Taskbar extends StatelessWidget {
  const Taskbar({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final windows = scope.windows;
    final compact = context.isCompact;

    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: PaintColors.grey,
        border: Border(top: BorderSide(color: PaintColors.white, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
      child: Row(
        children: [
          RetroMenu(
            items: [
              for (final s in windows.specs)
                MenuEntry(s.taskLabel, () => windows.reveal(s.id)),
              menuDivider,
              MenuEntry(
                'Download CV.exe',
                () => Browser.downloadAsset(
                  Portfolio.cvAsset,
                  'Umesh_Chakradhar_CV.pdf',
                ),
              ),
              MenuEntry('Shut Down...', () => showExit(context)),
            ],
            builder: (context, controller) => RetroButton(
              semanticLabel: 'Start menu',
              selected: controller.isOpen,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PixelIcon('brush', size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Start',
                    style: PaintText.chrome.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ListenableBuilder(
              listenable: windows,
              builder: (context, _) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final s in windows.specs)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SizedBox(
                        width: compact ? null : 150,
                        child: RetroButton(
                          semanticLabel: 'Show ${s.taskLabel}',
                          selected:
                              windows.active == s.id &&
                              !windows.state(s.id).closed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          onPressed: () => windows.reveal(s.id),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PixelIcon(s.icon, size: 16),
                              const SizedBox(width: 5),
                              // The phone strip scrolls, so labels there
                              // size themselves instead of flexing.
                              if (compact)
                                _label(s.taskLabel, windows.state(s.id).closed)
                              else
                                Flexible(
                                  child: _label(
                                    s.taskLabel,
                                    windows.state(s.id).closed,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 6),
            const Bevel(
              style: BevelStyle.sunken,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: _Clock(),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _label(String text, bool closed) => Text(
  text,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: PaintText.chrome.copyWith(
    color: closed ? PaintColors.darkGrey : PaintColors.black,
  ),
);

class _Clock extends StatefulWidget {
  const _Clock();

  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockState extends State<_Clock> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Tick on the minute boundary, then every minute.
    _timer = Timer(Duration(seconds: 60 - _now.second), () {
      _tick();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
    });
  }

  void _tick() => setState(() => _now = DateTime.now());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final m = _now.minute.toString().padLeft(2, '0');
    final ampm = _now.hour < 12 ? 'AM' : 'PM';
    return Text('$h:$m $ampm', style: PaintText.chrome);
  }
}
