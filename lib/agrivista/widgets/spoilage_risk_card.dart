import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recommendation_model.dart';
import '../theme/app_colors.dart';

class SpoilageRiskCard extends StatefulWidget {
  final SpoilageRisk risk;
  final double riskScore; // 0.0 – 1.0

  const SpoilageRiskCard({
    super.key,
    required this.risk,
    required this.riskScore,
  });

  @override
  State<SpoilageRiskCard> createState() => _SpoilageRiskCardState();
}

class _SpoilageRiskCardState extends State<SpoilageRiskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _riskColor {
    switch (widget.risk) {
      case SpoilageRisk.low:
        return AppColors.riskLow;
      case SpoilageRisk.medium:
        return AppColors.riskMedium;
      case SpoilageRisk.high:
        return AppColors.riskHigh;
    }
  }

  String get _riskEmoji {
    switch (widget.risk) {
      case SpoilageRisk.low:
        return '🟢';
      case SpoilageRisk.medium:
        return '🟡';
      case SpoilageRisk.high:
        return '🔴';
    }
  }

  String get _riskLabel {
    switch (widget.risk) {
      case SpoilageRisk.low:
        return 'Low Risk';
      case SpoilageRisk.medium:
        return 'Medium Risk';
      case SpoilageRisk.high:
        return 'High Risk';
    }
  }

  String get _riskAdvice {
    switch (widget.risk) {
      case SpoilageRisk.low:
        return 'Crop is in good condition. Safe to delay harvest by 2–3 days if needed.';
      case SpoilageRisk.medium:
        return 'Start harvesting soon. Humidity and temperature may increase spoilage in 3–4 days.';
      case SpoilageRisk.high:
        return 'Harvest immediately! High risk of spoilage due to current weather conditions.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _riskColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'Spoilage Risk',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Risk meter + info
          Row(
            children: [
              // Circular risk meter
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) => CustomPaint(
                  size: const Size(90, 90),
                  painter: _RiskMeterPainter(
                    progress: _animation.value * widget.riskScore,
                    color: _riskColor,
                  ),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _riskEmoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${(widget.riskScore * 100).toInt()}%',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _riskColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              // Risk details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _riskColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _riskLabel,
                        style: GoogleFonts.nunito(
                          color: _riskColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _riskAdvice,
                      style: GoogleFonts.nunito(
                        color: AppColors.textMedium,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Risk level indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _RiskLevelDot(
                label: '🟢 Low',
                active: widget.risk == SpoilageRisk.low,
                color: AppColors.riskLow,
              ),
              _RiskLevelDot(
                label: '🟡 Medium',
                active: widget.risk == SpoilageRisk.medium,
                color: AppColors.riskMedium,
              ),
              _RiskLevelDot(
                label: '🔴 High',
                active: widget.risk == SpoilageRisk.high,
                color: AppColors.riskHigh,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskLevelDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;

  const _RiskLevelDot({
    required this.label,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? color : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          fontSize: 12,
          color: active ? color : AppColors.textLight,
        ),
      ),
    );
  }
}

class _RiskMeterPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RiskMeterPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RiskMeterPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
