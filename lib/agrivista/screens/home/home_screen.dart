import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/crop_model.dart';
import '../../data/dummy_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/weather_strip.dart';
import '../../widgets/motivational_quote_card.dart';
import '../../widgets/floating_mic_button.dart';
import '../result/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  CropModel? _selectedCrop;
  LocationModel? _selectedLocation;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _getRecommendation() async {
    if (_selectedCrop == null) {
      _showSnack('Please select a crop first 🌱');
      return;
    }
    if (_selectedLocation == null) {
      _showSnack('Please select your location 📍');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
            ResultScreen(result: DummyData.sampleResult),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.lavender,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Soft gradient background ─────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: AppColors.homeGradient),
          ),
          // ── Decorative circles (soft lavender) ──────────────────────────────
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lavender.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sunYellow.withValues(alpha: 0.12),
              ),
            ),
          ),
          // ── Main content ─────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const StaticWeatherStrip(),
                            const SizedBox(height: 16),
                            _SectionLabel(
                              label: 'Select Your Crop',
                              emoji: '🌾',
                            ),
                            const SizedBox(height: 8),
                            _CropGrid(
                              crops: DummyData.crops,
                              selected: _selectedCrop,
                              onSelect: (c) =>
                                  setState(() => _selectedCrop = c),
                            ),
                            const SizedBox(height: 18),
                            _SectionLabel(
                              label: 'Select Location',
                              emoji: '📍',
                            ),
                            const SizedBox(height: 8),
                            _LocationDropdown(
                              locations: DummyData.locations,
                              selected: _selectedLocation,
                              onSelect: (l) =>
                                  setState(() => _selectedLocation = l),
                            ),
                            const SizedBox(height: 22),
                            _GetRecommendationButton(
                              isLoading: _isLoading,
                              onTap: _getRecommendation,
                            ),
                            const SizedBox(height: 22),
                            const MotivationalQuoteCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingMicButton(
        onMicTap: () {},
        onPlaybackTap: () {},
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Namaste 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Krishi Mitra AI',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your AI-powered farming companion 🤖🌱',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lavenderLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lavender, width: 2),
            ),
            child: const Text('🧑‍🌾', style: TextStyle(fontSize: 28)),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final String emoji;

  const _SectionLabel({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// ── Crop Grid ────────────────────────────────────────────────────────────────
class _CropGrid extends StatelessWidget {
  final List<CropModel> crops;
  final CropModel? selected;
  final ValueChanged<CropModel> onSelect;

  const _CropGrid({
    required this.crops,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: crops.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (_, i) {
        final crop = crops[i];
        final isSelected = selected?.id == crop.id;
        return GestureDetector(
          onTap: () => onSelect(crop),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.lavenderLight
                  : AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.lavender
                    : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.lavender.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  crop.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.textDark : AppColors.textMedium,
                  ),
                ),
                Text(
                  crop.nameSanskrit,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Location Dropdown ─────────────────────────────────────────────────────────
class _LocationDropdown extends StatelessWidget {
  final List<LocationModel> locations;
  final LocationModel? selected;
  final ValueChanged<LocationModel> onSelect;

  const _LocationDropdown({
    required this.locations,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LocationModel>(
          isExpanded: true,
          dropdownColor: AppColors.cardWhite,
          value: selected,
          hint: Text(
            '🗺  Select your village / city',
            style: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.lavender,
          ),
          items: locations.map((loc) {
            return DropdownMenuItem<LocationModel>(
              value: loc,
              child: Text(
                '📍 ${loc.name}, ${loc.state}',
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onSelect(v);
          },
        ),
      ),
    );
  }
}

// ── Get Recommendation Button ────────────────────────────────────────────────
class _GetRecommendationButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GetRecommendationButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_GetRecommendationButton> createState() =>
      _GetRecommendationButtonState();
}

class _GetRecommendationButtonState extends State<_GetRecommendationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.lavender, AppColors.lavenderDeep],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.lavender.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Analysing with AI…',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Get AI Recommendation',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
