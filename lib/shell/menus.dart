import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/portfolio_data.dart';
import '../platform/browser.dart';
import '../theme/paint_theme.dart';
import 'dialogs.dart';

final _menuStyle = MenuStyle(
  backgroundColor: const WidgetStatePropertyAll(PaintColors.grey),
  elevation: const WidgetStatePropertyAll(0),
  padding: const WidgetStatePropertyAll(EdgeInsets.all(3)),
  shape: const WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(color: PaintColors.black),
    ),
  ),
  shadowColor: const WidgetStatePropertyAll(Colors.transparent),
);

final _itemStyle = ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(Size(180, 28)),
  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
  shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
  textStyle: const WidgetStatePropertyAll(PaintText.chrome),
  backgroundColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)
        ? PaintColors.navy
        : PaintColors.grey,
  ),
  foregroundColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.disabled)
        ? PaintColors.darkGrey
        : s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)
        ? PaintColors.white
        : PaintColors.black,
  ),
);

class MenuEntry {
  const MenuEntry(this.label, this.onTap);

  final String label;
  final VoidCallback? onTap;
}

const menuDivider = MenuEntry('-', null);

/// A Win95 drop-down menu attached to [child].
class RetroMenu extends StatelessWidget {
  const RetroMenu({super.key, required this.items, required this.builder});

  final List<MenuEntry> items;
  final Widget Function(BuildContext, MenuController) builder;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: _menuStyle,
      alignmentOffset: const Offset(0, 1),
      menuChildren: [
        for (final i in items)
          if (identical(i, menuDivider))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
              child: Column(
                children: [
                  Divider(height: 1, thickness: 1, color: PaintColors.darkGrey),
                  Divider(height: 1, thickness: 1, color: PaintColors.white),
                ],
              ),
            )
          else
            MenuItemButton(
              style: _itemStyle,
              onPressed: i.onTap,
              child: Text(i.label),
            ),
      ],
      builder: (context, controller, _) => builder(context, controller),
    );
  }
}

/// File / Edit / View / Help.
class PaintMenuBar extends StatelessWidget {
  const PaintMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final windows = scope.windows;
    final paint = scope.paint;

    final menus = <String, List<MenuEntry>>{
      'File': [
        MenuEntry(
          'Download CV.exe',
          () => Browser.downloadAsset(
            Portfolio.cvAsset,
            'Umesh_Chakradhar_CV.pdf',
          ),
        ),
        MenuEntry('Send Message...', () => windows.reveal('contact')),
        menuDivider,
        MenuEntry('Exit', () => showExit(context)),
      ],
      'Edit': [
        MenuEntry('Undo doodle', paint.undo),
        MenuEntry('Clear Image', paint.clearAll),
      ],
      'View': [
        for (final s in windows.specs)
          MenuEntry(s.taskLabel, () => windows.reveal(s.id)),
        menuDivider,
        MenuEntry('Reset windows', windows.resetAll),
        MenuEntry('Full screen', Browser.toggleFullscreen),
      ],
      'Help': [MenuEntry('About Paint', () => showAbout(context))],
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in menus.entries)
            RetroMenu(
              items: entry.value,
              builder: (context, controller) => _MenuTitle(
                label: entry.key,
                open: controller.isOpen,
                onTap: () =>
                    controller.isOpen ? controller.close() : controller.open(),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuTitle extends StatelessWidget {
  const _MenuTitle({
    required this.label,
    required this.open,
    required this.onTap,
  });

  final String label;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label menu',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            color: open ? PaintColors.navy : Colors.transparent,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label[0],
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: label.substring(1)),
                ],
              ),
              style: PaintText.chrome.copyWith(
                color: open ? PaintColors.white : PaintColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showExit(BuildContext context) => showRetroDialog(
  context,
  title: 'Paint',
  icon: 'floppy',
  message:
      "Save changes to umesh_chakradhar.bmp?\n\n(Nice try - this "
      "portfolio isn't going anywhere.)",
  buttons: const ['Yes', 'No', 'Cancel'],
);

void showAbout(BuildContext context) => showRetroDialog(
  context,
  title: 'About Paint',
  icon: 'brush',
  message:
      '${Portfolio.name} - Portfolio 95\n\n'
      'Built with Flutter Web. Every icon is hand-placed pixel art.\n\n'
      'Tip: grab the pencil from the tool box and doodle anywhere. '
      'Drag windows by their title bars.',
);
