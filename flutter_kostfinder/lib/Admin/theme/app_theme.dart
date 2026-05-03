import 'package:flutter/material.dart';

class AppColors {
  // ── Primary palette (dari Laravel CSS :root) ──────────────────────
  static const coral      = Color(0xFFE8430D);  // --coral
  static const coral2     = Color(0xFFFF6B3D);  // --coral2
  static const coralBg    = Color(0x14E8430D);  // --coral-bg
  static const teal       = Color(0xFF008F78);  // --teal
  static const tealBg     = Color(0x14008F78);  // --teal-bg
  static const yellow     = Color(0xFFD48D00);  // --yellow
  static const yellowBg   = Color(0x17D48D00);  // --yellow-bg
  static const blue       = Color(0xFF2563EB);  // --blue
  static const blueBg     = Color(0x142563EB);  // --blue-bg
  static const green      = Color(0xFF38A169);
  static const greenBg    = Color(0x1A38A169);
  static const teal2      = Color(0xFF00C9A7);

  // ── Light theme ───────────────────────────────────────────────────
  static const bgLight    = Color(0xFFF5F7FA);  // --bg
  static const bg2Light   = Color(0xFFEAEFF5);  // --bg2
  static const cardLight  = Color(0xFFFFFFFF);  // --card
  static const mutedLight = Color(0xFF6B7E94);  // --muted
  static const textLight  = Color(0xFF1A2A3A);  // --text
  static const text2Light = Color(0xFF3D5166);  // --text2
  static const borderLight= Color(0x1A1A2A3A);  // --border

  // ── Dark theme ────────────────────────────────────────────────────
  static const bgDark     = Color(0xFF0F1923);
  static const bg2Dark    = Color(0xFF172130);
  static const cardDark   = Color(0xFF1C2B3A);
  static const mutedDark  = Color(0xFF7A94AB);
  static const textDark   = Color(0xFFE8F2FF);
  static const text2Dark  = Color(0xFFA8BDD0);
  static const borderDark = Color(0x14FFFFFF);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.coral,
      secondary: AppColors.teal,
      surface: AppColors.cardLight,
      onSurface: AppColors.textLight,
    ),
    fontFamily: 'DMSans',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardLight,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textLight,
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight, space: 0),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: -0.3),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textLight),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textLight),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textLight),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.text2Light),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedLight, letterSpacing: 0.05),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.coral,
      secondary: AppColors.teal,
      surface: AppColors.cardDark,
      onSurface: AppColors.textDark,
    ),
    fontFamily: 'DMSans',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardDark,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderDark),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg2Dark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.mutedDark, fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderDark, space: 0),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.3),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.text2Dark),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedDark, letterSpacing: 0.05),
    ),
  );
}
