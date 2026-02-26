import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recommendation_model.dart';
import '../theme/app_colors.dart';

class MarketCard extends StatelessWidget {
  final MandiRecommendation mandi;

  const MarketCard({super.key, required this.mandi});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best Mandi',
                        style: GoogleFonts.poppins(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        mandi.mandiName,
                        style: GoogleFonts.poppins(
                          color: AppColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${mandi.distanceKm.toStringAsFixed(0)} km',
                        style: GoogleFonts.poppins(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Details grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatPill(
                      label: 'Expected Price',
                      value:
                          '₹${mandi.expectedPricePerQuintal.toStringAsFixed(0)}/q',
                      icon: Icons.sell_outlined,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      label: 'Net Profit Est.',
                      value: '₹${mandi.estimatedNetProfit.toStringAsFixed(0)}',
                      icon: Icons.trending_up,
                      color: AppColors.profit,
                      highlighted: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatPill(
                      label: 'Distance',
                      value: '${mandi.distanceKm.toStringAsFixed(0)} km',
                      icon: Icons.directions_car_outlined,
                      color: AppColors.warmOrange,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      label: 'Travel Time',
                      value: mandi.arrivalTime,
                      icon: Icons.access_time_outlined,
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Last 3 days prices
                _Last3DaysPriceRow(prices: mandi.last3DaysPrices),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlighted;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: highlighted
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: highlighted
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Last3DaysPriceRow extends StatelessWidget {
  final List<double> prices;

  const _Last3DaysPriceRow({required this.prices});

  @override
  Widget build(BuildContext context) {
    const labels = ['2 days ago', 'Yesterday', 'Today'];
    final max = prices.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 3 Days Price Trend',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: prices.asMap().entries.map((e) {
              final barH = (e.value / max * 40).clamp(10, 40).toDouble();
              final isLast = e.key == prices.length - 1;
              return Column(
                children: [
                  Text(
                    '₹${e.value.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isLast
                          ? AppColors.primaryGreen
                          : AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: barH,
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.primaryGreen
                          : AppColors.softGreen.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[e.key],
                    style: TextStyle(fontSize: 10, color: AppColors.textLight),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
