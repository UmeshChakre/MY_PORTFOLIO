import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'data/portfolio_data.dart';
import 'desk/window_manager.dart';
import 'paint/paint_state.dart';
import 'platform/browser.dart';
import 'sections/windows.dart';
import 'shell/paint_shell.dart';
import 'theme/paint_theme.dart';

const siteTitle = '${Portfolio.name} | Mobile Application Developer';

void main() {
  runApp(const PortfolioApp());
  WidgetsBinding.instance.addPostFrameCallback((_) => Browser.removeSplash());
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  final _paint = PaintState();
  final _windows = WindowManager(portfolioWindows);
  String? _lastActive;

  @override
  void initState() {
    super.initState();
    _windows.addListener(_syncTitle);
  }

  /// Keeps the browser tab title in step with the focused window.
  void _syncTitle() {
    final id = _windows.active;
    if (id == _lastActive) return;
    _lastActive = id;
    final title = id == null ? null : _windows.spec(id).pageTitle;
    Browser.setPageMeta(title: title ?? siteTitle);
  }

  @override
  void dispose() {
    _windows
      ..removeListener(_syncTitle)
      ..dispose();
    _paint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      paint: _paint,
      windows: _windows,
      child: MaterialApp(
        title: siteTitle,
        debugShowCheckedModeBanner: false,
        theme: buildPaintTheme(),
        home: const PaintShell(),
      ),
    );
  }
}
