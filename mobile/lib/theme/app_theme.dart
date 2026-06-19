import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --------------------------------------------------------
  // 1. DESIGN TOKENS: Colors
  // --------------------------------------------------------
  static const Color primaryGold = Color(0xFFD4A03C);
  static const Color primaryGoldDark = Color(0xFFB8860B);
  
  static const Color backgroundDark = Color(0xFF1A1614);
  static const Color cardDark = Color(0xFF26211E);
  static const Color cardDarkElevated = Color(0xFF322C28);
  
  static const Color textLight = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);
  
  static const Color statusSuccess = Color(0xFF52B788);
  static const Color statusError = Color(0xFFEF4444);

  // --------------------------------------------------------
  // 2. DESIGN TOKENS: Typography
  // --------------------------------------------------------
  static TextTheme get _textTheme {
    return GoogleFonts.sourceSans3TextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.sourceSans3(color: textLight, fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: GoogleFonts.sourceSans3(color: textLight, fontWeight: FontWeight.bold, fontSize: 28),
      titleLarge: GoogleFonts.sourceSans3(color: textLight, fontWeight: FontWeight.w600, fontSize: 22),
      titleMedium: GoogleFonts.sourceSans3(color: textLight, fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: GoogleFonts.sourceSans3(color: textLight, fontSize: 16),
      bodyMedium: GoogleFonts.sourceSans3(color: textMuted, fontSize: 14),
      labelLarge: GoogleFonts.sourceSans3(color: textLight, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
    );
  }

  // --------------------------------------------------------
  // 3. THEME DATA
  // --------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: primaryGoldDark,
        surface: cardDark,
        background: backgroundDark,
        onPrimary: Colors.white,
        onSurface: textLight,
        onBackground: textLight,
        error: statusError,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // Default to transparent for premium feel
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryGold),
        titleTextStyle: _textTheme.titleLarge?.copyWith(color: primaryGold),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Input decoration global theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDarkElevated.withOpacity(0.5),
        labelStyle: _textTheme.bodyMedium,
        prefixIconColor: primaryGold,
        suffixIconColor: primaryGold,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: statusError, width: 1),
        ),
      ),
    );
  }
}
