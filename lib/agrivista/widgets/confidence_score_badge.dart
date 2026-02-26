import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ConfidenceScoreBadge extends StatelessWidget {
  final int confidencePct;
  final bool large;

  const ConfidenceScoreBadge({
    super.key,
    required this.confidencePct,
    this.large = false,
  });

  Color get _color {
    if (confidencePct >= 80) return AppColors.riskLow;
    if (confidencePct >= 60) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    final size = large ? 56.0 : 44.0;
    final fontSize = large ? 15.0 : 12.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color.withValues(alpha: 0.15),
        border: Border.all(color: _color, width: 2),
      ),
      child: Center(
        child: Text(
          '$confidencePct%',
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: _color,
          ),
        ),
      ),
    );
  }
}
