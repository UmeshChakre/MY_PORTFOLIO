import 'package:flutter/material.dart';

import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';

/// Shows a Windows 95 message box. Every button simply closes it.
Future<void> showRetroDialog(
  BuildContext context, {
  required String title,
  required String message,
  String icon = 'brush',
  List<String> buttons = const ['OK'],
}) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x33000000),
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            type: MaterialType.transparency,
            child: Bevel(
              padding: const EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 26,
                    padding: const EdgeInsets.only(left: 6, right: 3),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PaintColors.navy,
                          PaintColors.titleGradientEnd,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(title, style: PaintText.title)),
                        SizedBox(
                          width: 22,
                          height: 20,
                          child: RetroButton(
                            padding: EdgeInsets.zero,
                            semanticLabel: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Center(
                              child: PixelIcon('close', size: 9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelIcon(icon, size: 36),
                        const SizedBox(width: 16),
                        Expanded(child: Text(message, style: PaintText.body)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      children: [
                        for (final b in buttons)
                          SizedBox(
                            width: 88,
                            child: RetroButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Center(
                                child: Text(b, style: PaintText.chrome),
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
        ),
      ),
    ),
  );
}
