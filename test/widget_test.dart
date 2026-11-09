import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_portfolio/main.dart';
import 'package:my_portfolio/paint/paint_state.dart';
import 'package:my_portfolio/shell/taskbar.dart';
import 'package:my_portfolio/ui/sketchy.dart';

Future<void> _loadFonts() async {
  const fonts = {
    'GochiHand': 'assets/fonts/GochiHand-Regular.ttf',
    'PermanentMarker': 'assets/fonts/PermanentMarker-Regular.ttf',
    'VT323': 'assets/fonts/VT323-Regular.ttf',
  };
  for (final e in fonts.entries) {
    final bytes = File(e.value).readAsBytes().then(ByteData.sublistView);
    await (FontLoader(e.key)..addFont(bytes)).load();
  }
}

Finder _rough(String text) =>
    find.byWidgetPredicate((w) => w is RoughText && w.text == text);

void main() {
  setUpAll(_loadFonts);

  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PortfolioApp());
    await tester.pump();
  }

  testWidgets('desktop layout shows every window', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    expect(find.text('Untitled - Paint'), findsOneWidget);
    expect(_rough('Umesh Chakradhar'), findsOneWidget);
    expect(find.text('about_me.txt'), findsOneWidget);
    expect(find.text('Send Message.txt - Notepad'), findsOneWidget);
    expect(_rough("p.s. yes, of course it's vibecoded ;)"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone layout renders without overflow', (tester) async {
    await pumpApp(tester, const Size(375, 812));

    expect(_rough('Umesh Chakradhar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing a window removes it and the taskbar restores it', (
    tester,
  ) async {
    await pumpApp(tester, const Size(1440, 900));

    final close = find.bySemanticsLabel('Close Hobbies');
    await tester.ensureVisible(close);
    await tester.pumpAndSettle();
    await tester.tap(close);
    await tester.pump();
    await tester.pump();
    expect(find.text('Sketchpad - hobbies.bmp'), findsNothing);

    await tester.tap(
      find.descendant(of: find.byType(Taskbar), matching: find.text('Hobbies')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sketchpad - hobbies.bmp'), findsOneWidget);
  });

  test('pencil strokes commit and undo', () {
    final paint = PaintState()..tool = PaintTool.pencil;
    paint
      ..beginStroke(const Offset(10, 10))
      ..extendStroke(const Offset(20, 20))
      ..endStroke();
    expect(paint.strokes, hasLength(1));
    expect(paint.strokes.single.points, hasLength(2));

    paint.undo();
    expect(paint.strokes, isEmpty);
  });

  test('eraser removes strokes it touches', () {
    final paint = PaintState()..tool = PaintTool.pencil;
    paint
      ..beginStroke(const Offset(50, 50))
      ..endStroke()
      ..tool = PaintTool.eraser
      ..beginStroke(const Offset(52, 52));
    expect(paint.strokes, isEmpty);
  });
}
