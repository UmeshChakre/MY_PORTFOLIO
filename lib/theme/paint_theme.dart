import 'package:flutter/material.dart';

/// Windows 95 / MS Paint palette.
abstract final class PaintColors {
  static const grey = Color(0xFFC0C0C0);
  static const darkGrey = Color(0xFF808080);
  static const light = Color(0xFFDFDFDF);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const navy = Color(0xFF000080);
  static const titleGradientEnd = Color(0xFF1084D0);
  static const desktop = Color(0xFF008080);

  // MS Paint toolbar accents.
  static const red = Color(0xFFFF0000);
  static const blue = Color(0xFF0000FF);
  static const electricBlue = Color(0xFF0080FF);
  static const lime = Color(0xFF00FF00);
  static const yellow = Color(0xFFFFFF00);
  static const ink = Color(0xFF1A1A2E);
  static const pencil = Color(0xFF333333);

  /// The classic 28-colour MS Paint palette (two rows of 14).
  static const palette = <Color>[
    Color(0xFF000000),
    Color(0xFF808080),
    Color(0xFF800000),
    Color(0xFF808000),
    Color(0xFF008000),
    Color(0xFF008080),
    Color(0xFF000080),
    Color(0xFF800080),
    Color(0xFF808040),
    Color(0xFF004040),
    Color(0xFF0080FF),
    Color(0xFF004080),
    Color(0xFF8000FF),
    Color(0xFF804000),
    Color(0xFFFFFFFF),
    Color(0xFFC0C0C0),
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFFFF80),
    Color(0xFF00FF80),
    Color(0xFF80FFFF),
    Color(0xFF8080FF),
    Color(0xFFFF0080),
    Color(0xFFFF8040),
  ];
}

abstract final class PaintFonts {
  static const hand = 'GochiHand';
  static const marker = 'PermanentMarker';
  static const pixel = 'VT323';
}

abstract final class PaintText {
  static const body = TextStyle(
    fontFamily: PaintFonts.hand,
    fontSize: 19,
    height: 1.35,
    color: PaintColors.ink,
  );

  static const small = TextStyle(
    fontFamily: PaintFonts.hand,
    fontSize: 16,
    height: 1.3,
    color: PaintColors.ink,
  );

  static const heading = TextStyle(
    fontFamily: PaintFonts.marker,
    fontSize: 26,
    height: 1.2,
    color: PaintColors.black,
  );

  static const chrome = TextStyle(
    fontFamily: PaintFonts.pixel,
    fontSize: 20,
    height: 1,
    color: PaintColors.black,
  );

  static const title = TextStyle(
    fontFamily: PaintFonts.pixel,
    fontSize: 20,
    height: 1,
    color: PaintColors.white,
  );
}

ThemeData buildPaintTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: PaintFonts.hand,
    scaffoldBackgroundColor: PaintColors.desktop,
    colorScheme: const ColorScheme.light(
      primary: PaintColors.navy,
      secondary: PaintColors.electricBlue,
      surface: PaintColors.grey,
      onSurface: PaintColors.ink,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: PaintColors.black,
      selectionColor: Color(0x660000FF),
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
}
