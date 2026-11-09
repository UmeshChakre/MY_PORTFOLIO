import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/paint_theme.dart';

enum PaintTool {
  select('select', 'Select (browse & drag windows)'),
  eraser('eraser', 'Eraser (rub out doodles)'),
  fill('fill', 'Fill With Color (paint the canvas)'),
  zoom('zoom', 'Magnifier (text size)'),
  pencil('pencil', 'Pencil (doodle!)'),
  brush('brush', 'Brush'),
  airbrush('airbrush', 'Airbrush'),
  text('text', 'Text (click the canvas to write)');

  const PaintTool(this.icon, this.label);

  final String icon;
  final String label;

  bool get draws =>
      this == pencil || this == brush || this == airbrush || this == eraser;
}

class Stroke {
  Stroke({required this.color, required this.width, required this.spray});

  final Color color;
  final double width;
  final bool spray;
  final List<Offset> points = [];
}

class DoodleText {
  DoodleText({required this.position, required this.color})
    : controller = TextEditingController(),
      focus = FocusNode();

  final Offset position;
  final Color color;
  final TextEditingController controller;
  final FocusNode focus;

  void dispose() {
    controller.dispose();
    focus.dispose();
  }
}

/// Everything the Paint chrome can change: active tool, colours, zoom,
/// canvas colour, and the visitor's doodles.
class PaintState extends ChangeNotifier {
  PaintTool _tool = PaintTool.select;
  Color _foreground = PaintColors.black;
  Color _background = PaintColors.white;
  Color _canvas = PaintColors.white;
  double _zoom = 1;
  int _brushSize = 1;

  PaintTool get tool => _tool;
  Color get foreground => _foreground;
  Color get background => _background;
  Color get canvas => _canvas;
  double get zoom => _zoom;

  /// 0, 1 or 2 - the three size options in the tool options box.
  int get brushSize => _brushSize;

  /// Committed strokes. Repaints of finished art listen to [committed].
  final List<Stroke> strokes = [];
  final ValueNotifier<int> committed = ValueNotifier(0);
  final ValueNotifier<Stroke?> active = ValueNotifier(null);

  /// Bumped whenever the in-progress stroke gains points.
  final ValueNotifier<int> activeTick = ValueNotifier(0);
  final List<DoodleText> texts = [];

  /// Cursor position over the canvas, for the status bar.
  final ValueNotifier<Offset?> cursor = ValueNotifier(null);

  final math.Random _spray = math.Random();

  set tool(PaintTool value) {
    if (value == _tool) return;
    _tool = value;
    // Drop empty text boxes when leaving the text tool.
    if (value != PaintTool.text) {
      texts.removeWhere((t) {
        final empty = t.controller.text.trim().isEmpty;
        if (empty) t.dispose();
        return empty;
      });
    }
    notifyListeners();
  }

  void pickColor(Color color, {bool secondary = false}) {
    if (secondary) {
      _background = color;
    } else {
      _foreground = color;
    }
    notifyListeners();
  }

  void swapColors() {
    final f = _foreground;
    _foreground = _background;
    _background = f;
    notifyListeners();
  }

  set brushSize(int value) {
    _brushSize = value;
    notifyListeners();
  }

  set zoom(double value) {
    _zoom = value;
    notifyListeners();
  }

  void fillCanvas(Color color) {
    _canvas = color;
    notifyListeners();
  }

  double get _width => switch (_tool) {
    PaintTool.pencil => 1.5 + _brushSize,
    PaintTool.brush => 4.0 + _brushSize * 4,
    PaintTool.airbrush => 10.0 + _brushSize * 8,
    PaintTool.eraser => 8.0 + _brushSize * 8,
    _ => 2,
  };

  void beginStroke(Offset p, {bool secondary = false}) {
    if (_tool == PaintTool.eraser) {
      _erase(p);
      return;
    }
    final stroke = Stroke(
      color: secondary ? _background : _foreground,
      width: _width,
      spray: _tool == PaintTool.airbrush,
    );
    active.value = stroke;
    _add(stroke, p);
  }

  void extendStroke(Offset p) {
    if (_tool == PaintTool.eraser) {
      _erase(p);
      return;
    }
    final stroke = active.value;
    if (stroke == null) return;
    _add(stroke, p);
  }

  void _add(Stroke stroke, Offset p) {
    if (stroke.spray) {
      for (var i = 0; i < 6; i++) {
        final a = _spray.nextDouble() * math.pi * 2;
        final d = math.sqrt(_spray.nextDouble()) * stroke.width / 2;
        stroke.points.add(p + Offset(math.cos(a) * d, math.sin(a) * d));
      }
    } else {
      stroke.points.add(p);
    }
    activeTick.value++;
  }

  void endStroke() {
    final stroke = active.value;
    if (stroke == null) return;
    strokes.add(stroke);
    active.value = null;
    committed.value++;
  }

  void _erase(Offset p) {
    final r = _width / 2;
    final before = strokes.length;
    strokes.removeWhere(
      (s) => s.points.any((q) => (q - p).distance <= r + s.width / 2),
    );
    if (strokes.length != before) committed.value++;
  }

  DoodleText addText(Offset position) {
    final t = DoodleText(position: position, color: _foreground);
    texts.add(t);
    notifyListeners();
    return t;
  }

  bool get hasDoodles => strokes.isNotEmpty || texts.isNotEmpty;

  void undo() {
    if (strokes.isNotEmpty) {
      strokes.removeLast();
      committed.value++;
    } else if (texts.isNotEmpty) {
      texts.removeLast().dispose();
      notifyListeners();
    }
  }

  void clearAll() {
    strokes.clear();
    for (final t in texts) {
      t.dispose();
    }
    texts.clear();
    _canvas = PaintColors.white;
    committed.value++;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final t in texts) {
      t.dispose();
    }
    committed.dispose();
    active.dispose();
    activeTick.dispose();
    cursor.dispose();
    super.dispose();
  }
}
