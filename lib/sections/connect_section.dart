import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../platform/browser.dart';
import '../theme/paint_theme.dart';
import '../ui/bevel.dart';
import '../ui/pixel_icons.dart';

/// Social links laid out like a Paint tool palette.
class ConnectSection extends StatelessWidget {
  const ConnectSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick a tool. Any tool.',
            style: PaintText.body.copyWith(fontSize: 21),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final perRow = c.maxWidth >= 380 ? 2 : 1;
              const gap = 10.0;
              final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final s in Portfolio.socials)
                    SizedBox(
                      width: w,
                      child: _SocialTool(social: s),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SocialTool extends StatelessWidget {
  const _SocialTool({required this.social});

  final Social social;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: RetroButton(
        semanticLabel: '${social.name}: ${social.handle}',
        tooltip: social.url,
        padding: const EdgeInsets.all(10),
        onPressed: () => Browser.open(social.url),
        child: Row(
          children: [
            Bevel(
              style: BevelStyle.sunken,
              color: PaintColors.white,
              padding: const EdgeInsets.all(5),
              child: PixelIcon(social.icon, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    social.name,
                    style: PaintText.heading.copyWith(fontSize: 19),
                  ),
                  Text(
                    social.handle,
                    overflow: TextOverflow.ellipsis,
                    style: PaintText.chrome.copyWith(
                      fontSize: 18,
                      color: PaintColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
