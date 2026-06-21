import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Developer: Coach: Danilo
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.deepNavy,
      primaryColor: AppColors.electricBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.electricBlue,
        secondary: AppColors.neonCyan,
        surface: AppColors.charcoal,
        error: AppColors.neonMagentaAlert,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.neonWhite,
        displayColor: AppColors.neonWhite,
        fontFamily: 'Inter',
      ).copyWith(
        headlineLarge: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColors.neonWhite,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.neonWhite,
        ),
        bodySmall: TextStyle(
          color: AppColors.neonWhite.withOpacity(0.6),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoalLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.electricBlue.withOpacity(0.15)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.charcoalLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.electricBlue.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.neonWhite.withOpacity(0.4)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.charcoalLight,
        selectedColor: AppColors.electricBlue.withOpacity(0.25),
        labelStyle: const TextStyle(color: AppColors.neonWhite, fontSize: 12),
        side: BorderSide(color: AppColors.electricBlue.withOpacity(0.3)),
        shape: const StadiumBorder(),
      ),
      dividerColor: AppColors.electricBlue.withOpacity(0.12),
    );
  }
}
