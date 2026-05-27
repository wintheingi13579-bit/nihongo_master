// =============================================================
// app_theme.dart - Anime-inspired theme (light + dark)
// =============================================================
// We use a sakura-pink + indigo-night palette to evoke a manga feel.
// Gradients are defined here so every screen looks consistent.
// =============================================================

import 'package:flutter/material.dart';

class AppTheme {
  // ---- Primary brand colors ----
  static const Color sakura = Color(0xFFFF6F91);     // bright pink
  static const Color sakuraDeep = Color(0xFFB23A6F); // deeper pink
  static const Color indigoNight = Color(0xFF1B1B3A);
  static const Color indigoDeep = Color(0xFF0F0F23);
  static const Color goldXP = Color(0xFFFFC93C);

  // ---- Gradients ----
  static const LinearGradient sakuraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B1B3A), Color(0xFF3B1F5E)],
  );

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: sakura, brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFFFF8FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sakura,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: sakura,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: indigoDeep,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF2A2A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sakura,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
