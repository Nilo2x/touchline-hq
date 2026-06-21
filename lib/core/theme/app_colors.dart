import 'package:flutter/material.dart';

/// TouchlineHQ — Futuristic Electric Blue / Cyberpunk palette
/// Developer: Coach: Danilo
class AppColors {
  AppColors._();

  // Primary
  static const Color electricBlue = Color(0xFF1E6FFF);
  static const Color electricBlueDeep = Color(0xFF0A3FBF);

  // Secondary
  static const Color deepNavy = Color(0xFF050A18);
  static const Color charcoal = Color(0xFF11151F);
  static const Color charcoalLight = Color(0xFF1B2030);

  // Accents
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonWhite = Color(0xFFF4FBFF);
  static const Color neonMagentaAlert = Color(0xFFFF3D81); // negative/error accents

  // Status
  static const Color success = Color(0xFF1FFFA0);
  static const Color warning = Color(0xFFFFC93D);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepNavy, charcoal],
  );

  static const LinearGradient glowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, neonCyan],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [charcoalLight, charcoal],
  );

  // Rating tier colors (used on player cards)
  static Color ratingColor(int rating) {
    if (rating >= 85) return neonCyan;
    if (rating >= 75) return electricBlue;
    if (rating >= 65) return success;
    return warning;
  }
}
