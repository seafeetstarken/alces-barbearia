import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Alces Barbearia Branding Base
  static const Color primaryGold = Color(0xFFD4A03C);
  static const Color backgroundDark = Color(0xFF1A1614);
  static const Color cardDark = Color(0xFF26211E);
  static const Color textLight = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: primaryGold,
        surface: cardDark,
        background: backgroundDark,
        onPrimary: Colors.white,
        onSurface: textLight,
        onBackground: textLight,
      ),
      textTheme: GoogleFonts.sourceSans3TextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.sourceSans3(color: textLight, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.sourceSans3(color: textLight, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.sourceSans3(color: textLight),
        bodyMedium: GoogleFonts.sourceSans3(color: textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryGold),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
