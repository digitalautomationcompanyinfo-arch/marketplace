// app_theme.dart - World-class theme for كيف نخدمك
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ─── Color Palette ──────────────────────────────────────
  static const primaryColor = Color(0xFF1A3C5E);
  static const primaryLight = Color(0xFF2980B9);
  static const primaryDark = Color(0xFF0D2640);
  static const accentColor = Color(0xFF27AE60);
  static const accentLight = Color(0xFF2ECC71);
  static const warningColor = Color(0xFFF39C12);
  static const errorColor = Color(0xFFE74C3C);
  static const successColor = Color(0xFF27AE60);
  static const bgLight = Color(0xFFF0F4F8);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgDark = Color(0xFF0F1923);
  static const bgCardDark = Color(0xFF1A2535);
  static const textPrimary = Color(0xFF1C2833);
  static const textSecondary = Color(0xFF566573);
  static const textMuted = Color(0xFFABB2B9);
  static const borderColor = Color(0xFFE8EDF2);

  // ─── Gradients ──────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFF1E8449)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const cardGradient = LinearGradient(
    colors: [Color(0xFF1A3C5E), Color(0xFF2980B9)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // ─── Border Radius ───────────────────────────────────────
  static const radiusSm = BorderRadius.all(Radius.circular(8));
  static const radiusMd = BorderRadius.all(Radius.circular(12));
  static const radiusLg = BorderRadius.all(Radius.circular(20));
  static const radiusXl = BorderRadius.all(Radius.circular(28));

  // ─── Shadows ─────────────────────────────────────────────
  static final shadowSm = [
    BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 8,
        offset: const Offset(0, 2)),
  ];
  static final shadowMd = [
    BoxShadow(
        color: Colors.black.withOpacity(0.10),
        blurRadius: 16,
        offset: const Offset(0, 4)),
  ];
  static final shadowLg = [
    BoxShadow(
        color: primaryColor.withOpacity(0.15),
        blurRadius: 32,
        offset: const Offset(0, 8)),
  ];
  static final shadowPrimary = [
    BoxShadow(
        color: primaryLight.withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 6)),
  ];
  static final shadowGreen = [
    BoxShadow(
        color: accentColor.withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 6)),
  ];

  // ─── Text Styles ─────────────────────────────────────────
  static const TextStyle headingXl = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  static const TextStyle headingLg = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );
  static const TextStyle headingMd = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );
  static const TextStyle headingSm = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    color: textSecondary,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    color: textMuted,
  );
  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );
  static const TextStyle priceLg = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: accentColor,
  );

  // ──────────────────────────────────────────────────────────
  // LIGHT THEME
  // ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryLight,
          brightness: Brightness.light,
          primary: primaryColor,
          secondary: primaryLight,
          tertiary: accentColor,
          error: errorColor,
          surface: bgCard,
          background: bgLight,
        ),

        // Typography
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900),
          displayMedium:
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
          headlineLarge:
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
          headlineMedium:
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          titleLarge:
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          titleMedium:
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontFamily: 'Cairo'),
          bodyMedium: TextStyle(fontFamily: 'Cairo'),
          labelLarge:
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: const RoundedRectangleBorder(borderRadius: radiusMd),
            textStyle: const TextStyle(
                fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor, width: 1.5),
            minimumSize: const Size(double.infinity, 52),
            shape: const RoundedRectangleBorder(borderRadius: radiusMd),
            textStyle: const TextStyle(
                fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryLight,
            textStyle: const TextStyle(
                fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryLight, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorColor)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
              fontFamily: 'Cairo', color: textMuted, fontSize: 14),
          labelStyle: const TextStyle(
              fontFamily: 'Cairo', color: textSecondary, fontSize: 14),
          prefixIconColor: textMuted,
          suffixIconColor: textMuted,
        ),

        // Card
        cardTheme: const CardThemeData(
          elevation: 0,
          color: bgCard,
          shape: RoundedRectangleBorder(
              borderRadius: radiusMd, side: BorderSide(color: borderColor)),
          margin: EdgeInsets.zero,
        ),

        // Bottom Nav
        navigationBarTheme: NavigationBarThemeData(
          height: 65,
          backgroundColor: Colors.white,
          indicatorColor: primaryLight.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(
              fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600)),
          iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
                color:
                    s.contains(WidgetState.selected) ? primaryLight : textMuted,
                size: 24,
              )),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: bgLight,
          selectedColor: primaryLight.withOpacity(0.15),
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: const RoundedRectangleBorder(borderRadius: radiusMd),
          side: const BorderSide(color: borderColor),
        ),

        // Divider
        dividerTheme:
            const DividerThemeData(color: borderColor, thickness: 1, space: 0),

        // Progress
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: primaryLight),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? primaryLight : Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? primaryLight.withOpacity(0.4)
                  : Colors.grey[300]),
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryDark,
          contentTextStyle: const TextStyle(
              fontFamily: 'Cairo', color: Colors.white, fontSize: 14),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          behavior: SnackBarBehavior.floating,
        ),

        // Dialog
        dialogTheme: const DialogThemeData(
          backgroundColor: bgCard,
          elevation: 20,
          shape: RoundedRectangleBorder(borderRadius: radiusLg),
          titleTextStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary),
          contentTextStyle: TextStyle(
              fontFamily: 'Cairo', fontSize: 14, color: textSecondary),
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: bgCard,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          elevation: 8,
        ),
      );

  // ──────────────────────────────────────────────────────────
  // DARK THEME
  // ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: bgDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryLight,
          brightness: Brightness.dark,
          primary: primaryLight,
          secondary: accentColor,
          surface: bgCardDark,
          background: bgDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgCardDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: bgCardDark,
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF243040),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryLight, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
              fontFamily: 'Cairo', color: Color(0xFF5D7285), fontSize: 14),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: bgCardDark,
          indicatorColor: primaryLight.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(
              fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      );
}
