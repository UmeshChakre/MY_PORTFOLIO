import 'package:flutter/widgets.dart';

import 'desk/window_manager.dart';
import 'paint/paint_state.dart';

/// Hands the two app-wide controllers down the tree. It does not rebuild
/// dependents; widgets listen to exactly what they need.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.paint,
    required this.windows,
    required super.child,
  });

  final PaintState paint;
  final WindowManager windows;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope old) =>
      old.paint != paint || old.windows != windows;
}

/// Layout breakpoints shared by the shell and the sections.
extension Breakpoints on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isCompact => screenWidth < 720;
  bool get isWide => screenWidth >= 1000;
}
