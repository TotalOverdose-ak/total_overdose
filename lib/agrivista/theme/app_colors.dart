import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Palette (Green-White Clean) ───────────────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);   // rich green
  static const Color lightGreen = Color(0xFF4CAF50);     // medium green
  static const Color softGreen = Color(0xFF81C784);      // soft green
  static const Color mintGreen = Color(0xFFE8F5E9);      // very pale mint

  // Accent / Warm
  static const Color sunYellow = Color(0xFFF9E79F);      // pastel yellow
  static const Color warmOrange = Color(0xFFE8D5C4);     // peach / warm beige
  static const Color peachYellow = Color(0xFFFFF3D6);    // light warm cream

  // Gradient
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFFFFFFFF)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient cardGradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
  );

  static const LinearGradient cardGradientAmber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8D5C4), Color(0xFFF9E79F)],
  );

  static const LinearGradient cardGradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF388E3C), Color(0xFF66BB6A)],
  );

  // Risk Colors (functional)
  static const Color riskLow = Color(0xFF66BB6A);
  static const Color riskMedium = Color(0xFFFFCA28);
  static const Color riskHigh = Color(0xFFEF5350);

  // Neutral
  static const Color background = Color(0xFFF7F6F2);     // cream background
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);       // dark charcoal
  static const Color textMedium = Color(0xFF4A4A4A);     // medium grey
  static const Color textLight = Color(0xFF9E9E9E);      // light grey
  static const Color divider = Color(0xFFE8E4DF);

  // Profit
  static const Color profit = Color(0xFF2E7D32);         // green
  static const Color profitBg = Color(0xFFE8F5E9);
}
