import 'package:material_ui/material_ui.dart';

/// The calm green palette of the mockup, with large tap targets.
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  Color pick(int light, int darkValue) => Color(dark ? darkValue : light);

  final background = pick(0xfff4f3ee, 0xff111715);
  final card = pick(0xffffffff, 0xff1b2321);
  final line = pick(0xffe1e0d9, 0xff2b3633);
  final accent = pick(0xff2f7d68, 0xff6cc4a9);
  final soft = pick(0xffe1efe9, 0xff213a33);
  final text = pick(0xff1f2a27, 0xffe8eeec);

  final colors =
      ColorScheme.fromSeed(
        seedColor: const Color(0xff2f7d68),
        brightness: brightness,
      ).copyWith(
        primary: accent,
        onPrimary: pick(0xffffffff, 0xff0c1b16),
        primaryContainer: soft,
        onPrimaryContainer: text,
        secondaryContainer: soft,
        onSecondaryContainer: text,
        surface: background,
        onSurface: text,
        onSurfaceVariant: pick(0xff6b7773, 0xff94a29e),
        surfaceContainerLowest: card,
        surfaceContainerLow: card,
        surfaceContainer: card,
        surfaceContainerHigh: card,
        surfaceContainerHighest: soft,
        outline: pick(0xff6b7773, 0xff94a29e),
        outlineVariant: line,
        error: pick(0xffb4483c, 0xffe8897d),
      );

  const buttonSize = Size(48, 48);
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: line),
  );

  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: background,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        shape: buttonShape,
        backgroundColor: card,
        side: BorderSide(color: line),
        foregroundColor: text,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: buttonSize, shape: buttonShape),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(minimumSize: buttonSize),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: card,
      border: border,
      enabledBorder: border,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      indicatorColor: soft,
    ),
  );
}
