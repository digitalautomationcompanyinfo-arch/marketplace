import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviderTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.cairo().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3C5E)),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A3C5E),
            foregroundColor: Colors.white,
            elevation: 0),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3C5E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)))),
        navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF2980B9).withOpacity(0.15)),
      );
}
