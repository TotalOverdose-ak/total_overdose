import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recommendation_model.dart';
import '../theme/app_colors.dart';

class PreservationCard extends StatelessWidget {
  final List<PreservationSuggestion> suggestions;

  const PreservationCard({super.key, required this.suggestions});

  Color _costColor(String label) {
    switch (label.toLowerCase()) {
      case 'low':
        return AppColors.riskLow;
      case 'medium':
        return AppColors.riskMedium;
      case 'high':
        return AppColors.riskHigh;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.peachYellow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text('🛠', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(
                  'Preservation Suggestions',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warmOrange,
                  ),
                ),
              ],
            ),
          ),
          // Suggestions list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: suggestions.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final s = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SuggestionTile(
                    rank: rank,
                    suggestion: s,
                    costColor: _costColor(s.costLabel),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final int rank;
  final PreservationSuggestion suggestion;
  final Color costColor;

  const _SuggestionTile({
    required this.rank,
    required this.suggestion,
    required this.costColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.sunYellow.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sunYellow, width: 1.5),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warmOrange,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(suggestion.iconEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  suggestion.description,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: costColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  suggestion.costLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: costColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Effectiveness bar
              _EffectivenessBar(pct: suggestion.effectivenessPct),
            ],
          ),
        ],
      ),
    );
  }
}

class _EffectivenessBar extends StatelessWidget {
  final int pct;

  const _EffectivenessBar({required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$pct% effective',
          style: const TextStyle(fontSize: 10, color: AppColors.textLight),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 80
                    ? AppColors.riskLow
                    : pct >= 60
                    ? AppColors.riskMedium
                    : AppColors.riskHigh,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
