import 'package:flutter/material.dart';

class TradeXColors {
  static const background = Color(0xFF050817);
  static const backgroundAlt = Color(0xFF090D20);
  static const panel = Color(0xCC11172D);
  static const panelStrong = Color(0xF2141B34);
  static const cyan = Color(0xFF26D9FF);
  static const blue = Color(0xFF5278FF);
  static const violet = Color(0xFF9C6CFF);
  static const green = Color(0xFF4BE39C);
  static const red = Color(0xFFFF5B73);
  static const amber = Color(0xFFFFC857);
  static const border = Color(0xFF253154);
  static const muted = Color(0xFF95A2C6);
}

// Compatibility palette for legacy trading screens retained in TradeX Intelligence.
class TitanEgyptColors {
  static const obsidian = TradeXColors.background;
  static const charcoal = TradeXColors.backgroundAlt;
  static const panel = TradeXColors.panel;
  static const bronze = TradeXColors.border;
  static const gold = TradeXColors.amber;
  static const brightGold = Color(0xFFFFE08A);
  static const cyan = TradeXColors.cyan;
  static const emerald = TradeXColors.green;
  static const red = TradeXColors.red;
  static const amber = TradeXColors.amber;
  static const muted = TradeXColors.muted;
}

ThemeData buildTitanTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: TradeXColors.cyan,
    brightness: Brightness.dark,
    primary: TradeXColors.cyan,
    secondary: TradeXColors.violet,
    surface: TradeXColors.panelStrong,
    error: TradeXColors.red,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: TradeXColors.background,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(color: Color(0xFFE9EEFF)),
      bodyMedium: TextStyle(color: Color(0xFFD2DAF4)),
      bodySmall: TextStyle(color: TradeXColors.muted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: TradeXColors.border,
      thickness: 1,
    ),
    cardTheme: CardThemeData(
      color: TradeXColors.panel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: TradeXColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TradeXColors.panelStrong,
      labelStyle: const TextStyle(color: TradeXColors.muted),
      prefixIconColor: TradeXColors.cyan,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: TradeXColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: TradeXColors.cyan, width: 1.6),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: const Color(0xFF031019),
        backgroundColor: TradeXColors.cyan,
        minimumSize: const Size(0, 50),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: TradeXColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      selectedIconTheme: IconThemeData(color: TradeXColors.cyan),
      selectedLabelTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      unselectedIconTheme: IconThemeData(color: TradeXColors.muted),
      unselectedLabelTextStyle: TextStyle(color: TradeXColors.muted),
    ),
  );
}
