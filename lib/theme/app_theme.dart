import 'package:flutter/material.dart';

class AppTheme {
  // Renk paleti
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color darkGreen = Color(0xFF0D3B12);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentAmber = Color(0xFFFFA000);
  static const Color backgroundDark = Color(0xFF0A1A0D);
  static const Color surfaceDark = Color(0xFF132217);
  static const Color surfaceCard = Color(0xFF1A2E1F);
  static const Color surfaceCardLight = Color(0xFF243828);
  static const Color textPrimary = Color(0xFFE8F5E9);
  static const Color textSecondary = Color(0xFFA5D6A7);
  static const Color textMuted = Color(0xFF6B9B6F);
  static const Color dangerRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);
  static const Color warningOrange = Color(0xFFFF9800);

  // Gradyanlar
  static const LinearGradient tableGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1B5E20)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceCard, surfaceCardLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: lightGreen,
          secondary: accentGold,
          surface: surfaceDark,
          error: dangerRed,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surfaceCard,
          elevation: 4,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceCardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lightGreen, width: 2),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textMuted),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: surfaceCardLight,
          thickness: 1,
        ),
      );

  // Box Decoration helpers
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: lightGreen.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration playerCardDecoration(bool isSelected) => BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? accentGold
              : lightGreen.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? accentGold.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
}
