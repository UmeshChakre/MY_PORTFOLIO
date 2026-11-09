import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Static description of a window on the desk.
class WindowSpec {
  const WindowSpec({
    required this.id,
    required this.title,
    required this.taskLabel,
    required this.icon,
    required this.child,
    this.fullSpan = false,
    this.pageTitle,
  });

  final String id;
  final String title;
  final String taskLabel;
  final String icon;
  final Widget child;
  final bool fullSpan;

  /// Browser tab title while this window is focused.
  final String? pageTitle;
}

class WindowState {
  Offset offset = Offset.zero;
  bool minimized = false;
  bool maximized = false;
  bool closed = false;
}

/// Tracks position, z-order and min/max/close state of every window.
class WindowManager extends ChangeNotifier {
  WindowManager(this.specs)
    : _z = [for (final s in specs) s.id],
      _states = {for (final s in specs) s.id: WindowState()},
      keys = {for (final s in specs) s.id: GlobalKey(debugLabel: s.id)};

  final List<WindowSpec> specs;
  final List<String> _z;
  final Map<String, WindowState> _states;

  /// Keys used to scroll a window into view and keep its state while it
  /// moves around the paint order.
  final Map<String, GlobalKey> keys;

  String? _active;

  String? get active => _active;

  /// Paint order, back to front.
  List<String> get zOrder => List.unmodifiable(_z);

  WindowState state(String id) => _states[id]!;

  WindowSpec spec(String id) => specs.firstWhere((s) => s.id == id);

  void focus(String id) {
    final changedZ = _z.last != id;
    if (_active == id && !changedZ) return;
    _active = id;
    if (changedZ) {
      _z
        ..remove(id)
        ..add(id);
    }
    notifyListeners();
  }

  void move(String id, Offset delta) {
    _states[id]!.offset += delta;
    notifyListeners();
  }

  void resetPosition(String id) {
    _states[id]!.offset = Offset.zero;
    notifyListeners();
  }

  void toggleMinimized(String id) => _afterGesture(() {
    final s = _states[id]!;
    s.minimized = !s.minimized;
  });

  void toggleMaximized(String id) {
    final s = _states[id]!;
    s.maximized = !s.maximized;
    s.minimized = false;
    s.offset = Offset.zero;
    focus(id);
    notifyListeners();
  }

  void close(String id) => _afterGesture(() {
    _states[id]!.closed = true;
    if (_active == id) _active = null;
  });

  /// Removing a window's content while the tap that triggered it is still
  /// being processed trips up SelectionArea (it handles the tap-up a frame
  /// later and finds the removed text). Apply such changes after that frame.
  void _afterGesture(VoidCallback change) {
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        change();
        notifyListeners();
      })
      ..scheduleFrame();
  }

  /// Re-opens (if needed), restores, focuses and scrolls to a window.
  void reveal(String id) {
    final s = _states[id]!;
    s
      ..closed = false
      ..minimized = false;
    focus(id);
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = keys[id]!.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      }
    });
  }

  void resetAll() {
    for (final s in _states.values) {
      s
        ..offset = Offset.zero
        ..minimized = false
        ..maximized = false
        ..closed = false;
    }
    _z
      ..clear()
      ..addAll(specs.map((s) => s.id));
    _active = null;
    notifyListeners();
  }
}
