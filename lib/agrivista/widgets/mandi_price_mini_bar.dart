import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/history_model.dart';

/// Mini bar chart showing 7-day price trend for a single mandi entry.
class MandiPriceMiniBar extends StatelessWidget {
  final MandiPriceSummary summary;

  const MandiPriceMiniBar({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final maxVal = summary.weekTrend.reduce((a, b) => a > b ? a : b);
    final minVal = summary.weekTrend.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).clamp(1, double.infinity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(summary.cropEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.cropName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${summary.mandiName} • ${summary.city}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${summary.todayPrice.toStringAsFixed(0)}/q',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        summary.isUp ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: summary.isUp
                            ? AppColors.riskLow
                            : AppColors.riskHigh,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${summary.changePercent.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: summary.isUp
                              ? AppColors.riskLow
                              : AppColors.riskHigh,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mini Bar Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: summary.weekTrend.asMap().entries.map((entry) {
              final isLast = entry.key == summary.weekTrend.length - 1;
              final barHeight = ((entry.value - minVal) / range * 36 + 8)
                  .clamp(8, 44)
                  .toDouble();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400 + entry.key * 60),
                        curve: Curves.easeOut,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: isLast
                              ? AppColors.primaryGreen
                              : AppColors.softGreen.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _dayLabel(entry.key),
                        style: TextStyle(
                          fontSize: 9,
                          color: isLast
                              ? AppColors.primaryGreen
                              : AppColors.textLight,
                          fontWeight: isLast
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayLabel(int index) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'T'];
    return days[index % days.length];
  }
}
