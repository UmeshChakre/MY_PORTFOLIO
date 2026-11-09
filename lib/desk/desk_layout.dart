import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays windows out in masonry columns by [DeskSlot.slot], but paints and
/// hit-tests them in child order. Reordering the children therefore changes
/// z-order (bring-to-front) without changing the layout.
class DeskLayout extends MultiChildRenderObjectWidget {
  const DeskLayout({
    super.key,
    required this.columns,
    this.gap = 28,
    required super.children,
  });

  final int columns;
  final double gap;

  @override
  RenderDesk createRenderObject(BuildContext context) =>
      RenderDesk(columns: columns, gap: gap);

  @override
  void updateRenderObject(BuildContext context, RenderDesk renderObject) {
    renderObject
      ..columns = columns
      ..gap = gap;
  }
}

class DeskParentData extends ContainerBoxParentData<RenderBox> {
  int slot = 0;
  bool fullSpan = false;
  Offset drag = Offset.zero;
}

class DeskSlot extends ParentDataWidget<DeskParentData> {
  const DeskSlot({
    super.key,
    required this.slot,
    required this.fullSpan,
    required this.drag,
    required super.child,
  });

  final int slot;
  final bool fullSpan;
  final Offset drag;

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as DeskParentData;
    if (data.slot != slot || data.fullSpan != fullSpan || data.drag != drag) {
      data
        ..slot = slot
        ..fullSpan = fullSpan
        ..drag = drag;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => DeskLayout;
}

class RenderDesk extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DeskParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DeskParentData> {
  RenderDesk({required this._columns, required this._gap});

  int _columns;
  set columns(int v) {
    if (v == _columns) return;
    _columns = v;
    markNeedsLayout();
  }

  double _gap;
  set gap(double v) {
    if (v == _gap) return;
    _gap = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DeskParentData) {
      child.parentData = DeskParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final cols = math.max(1, _columns);
    final colWidth = (width - _gap * (cols - 1)) / cols;
    final heights = List<double>.filled(cols, 0);

    final ordered = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      ordered.add(child);
      child = childAfter(child);
    }
    ordered.sort(
      (a, b) => (a.parentData! as DeskParentData).slot.compareTo(
        (b.parentData! as DeskParentData).slot,
      ),
    );

    var bottom = 0.0;
    for (final c in ordered) {
      final data = c.parentData! as DeskParentData;
      final full = data.fullSpan || cols == 1;
      c.layout(
        BoxConstraints.tightFor(width: full ? width : colWidth),
        parentUsesSize: true,
      );
      Offset base;
      if (full) {
        final y = heights.reduce(math.max);
        base = Offset(0, y);
        heights.fillRange(0, cols, y + c.size.height + _gap);
      } else {
        var col = 0;
        for (var i = 1; i < cols; i++) {
          if (heights[i] < heights[col] - 0.5) col = i;
        }
        base = Offset(col * (colWidth + _gap), heights[col]);
        heights[col] += c.size.height + _gap;
      }
      final pos = base + data.drag;
      data.offset = pos;
      bottom = math.max(bottom, pos.dy + c.size.height);
    }
    size = constraints.constrain(Size(width, bottom));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Windows may be dragged partly outside the desk; still let them be hit.
    if (hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  /// Clamps a proposed drag so [child] stays inside the desk horizontally
  /// and never above its top edge.
  Offset clampDrag(RenderBox child, Offset delta) {
    final data = child.parentData! as DeskParentData;
    final next = data.offset + delta;
    final maxX = math.max(0.0, size.width - child.size.width);
    final clamped = Offset(next.dx.clamp(0.0, maxX), math.max(0.0, next.dy));
    return clamped - data.offset;
  }
}
