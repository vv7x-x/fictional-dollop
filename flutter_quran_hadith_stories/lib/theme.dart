import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildArabicTheme() {
  final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
  final textTheme = GoogleFonts.tajawalTextTheme(base.textTheme).apply(
    bodyColor: const Color(0xFF1F2937),
    displayColor: const Color(0xFF111827),
  );

  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF006D77),
      secondary: Color(0xFF83C5BE),
      surface: Color(0xFFF7FAFC),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF0B132B),
      onSurface: Color(0xFF1F2937),
    ),
    scaffoldBackgroundColor: const Color(0xFFF7FAFC),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF7FAFC),
      foregroundColor: const Color(0xFF0B132B),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      subtitleTextStyle: textTheme.bodyMedium,
    ),
  );
}