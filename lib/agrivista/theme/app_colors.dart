import 'package:flutter/material.dart';

class AppColors {
  // ── EcoBazaarX-inspired Clean Pastel Palette ──────────────────────────────

  // Primary Palette
  static const Color primaryGreen = Color(0xFF6B9F78);   // muted sage green
  static const Color lightGreen = Color(0xFF8FBF9A);     // soft green tint
  static const Color softGreen = Color(0xFFB5D6BE);      // very light sage
  static const Color mintGreen = Color(0xFFE4F0E8);      // near-white mint

  // Lavender accent (EcoBazaarX signature)
  static const Color lavender = Color(0xFFB5C7F7);       // lavender-blue
  static const Color lavenderLight = Color(0xFFD8E2FC);   // soft lavender
  static const Color lavenderDeep = Color(0xFF8FA8E8);    // deeper lavender

  // Accent / Warm
  static const Color sunYellow = Color(0xFFF9E79F);      // soft pastel yellow
  static const Color warmOrange = Color(0xFFE8B87A);     // muted peach-orange
  static const Color peachYellow = Color(0xFFFFF8E7);    // very light cream

  // Peach (EcoBazaarX signature)
  static const Color peach = Color(0xFFE8D5C4);          // peach
  static const Color peachLight = Color(0xFFF5EDE6);     // light peach

  // Gradient
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7F6F2), Color(0xFFD8E2FC), Color(0xFFB5C7F7)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B9F78), Color(0xFF8FBF9A)],
  );

  static const LinearGradient cardGradientAmber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8B87A), Color(0xFFF9E79F)],
  );

  static const LinearGradient cardGradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8FA8E8), Color(0xFFB5C7F7)],
  );

  // Risk Colors (kept functional — slightly softer)
  static const Color riskLow = Color(0xFF6BC17D);
  static const Color riskMedium = Color(0xFFF0C75E);
  static const Color riskHigh = Color(0xFFE87070);

  // Neutral (cream-tinted like EcoBazaarX)
  static const Color background = Color(0xFFF7F6F2);     // warm cream
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF22223B);        // navy text
  static const Color textMedium = Color(0xFF4A4A68);
  static const Color textLight = Color(0xFF8E8EA0);
  static const Color divider = Color(0xFFE8E8ED);

  // Profit
  static const Color profit = Color(0xFF5AADA8);
  static const Color profitBg = Color(0xFFE0F2F1);
}
