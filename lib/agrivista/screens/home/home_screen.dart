import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/crop_model.dart';
import '../../data/dummy_data.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/weather_strip.dart';
import '../../widgets/motivational_quote_card.dart';
import '../../widgets/floating_mic_button.dart';
import '../result/result_screen.dart';
import '../weather/weather_screen.dart';

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
    // Simulate AI processing delay
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient Background ──────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: AppColors.homeGradient),
          ),
          // ── Decorative circles ───────────────────────────────────────────────
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
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
                color: Colors.white.withValues(alpha: 0.04),
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
                            // Weather strip
                            StaticWeatherStrip(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WeatherScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            // Crop selection
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
                            // Location selection
                            _SectionLabel(
                              label: 'Select Location',
                              emoji: '📍',
                            ),
                            const SizedBox(height: 8),
                            _LocationDropdown(
                              locations: DummyData.locations,
                              selected: _selectedLocation,
                              onSelect: (l) {
                                setState(() => _selectedLocation = l);
                                // Update weather for the selected location
                                context.read<WeatherProvider>().fetchWeather(
                                  l.name,
                                );
                              },
                            ),
                            const SizedBox(height: 22),
                            // CTA button
                            _GetRecommendationButton(
                              isLoading: _isLoading,
                              onTap: _getRecommendation,
                            ),
                            const SizedBox(height: 22),
                            // Motivational quote
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
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Welcome to Krishi Mitra AI',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your AI-powered farming companion 🤖🌱',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // App logo / avatar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Crop Grid (Animated + See All) ───────────────────────────────────────────
class _CropGrid extends StatefulWidget {
  final List<CropModel> crops;
  final CropModel? selected;
  final ValueChanged<CropModel> onSelect;

  const _CropGrid({
    required this.crops,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_CropGrid> createState() => _CropGridState();
}

class _CropGridState extends State<_CropGrid> with TickerProviderStateMixin {
  static const int _initialCount = 6;
  bool _showAll = false;

  late AnimationController _entranceController;
  int? _tappedIndex;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _arrowController;
  late Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entranceController.forward();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bounceAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.05), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 40),
        ]).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
        );

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _arrowRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bounceController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  void _handleTap(int index, CropModel crop) {
    setState(() => _tappedIndex = index);
    _bounceController.forward(from: 0).then((_) {
      if (mounted) setState(() => _tappedIndex = null);
    });
    widget.onSelect(crop);
  }

  void _toggleShowAll() {
    setState(() => _showAll = !_showAll);
    if (_showAll) {
      _arrowController.forward();
      _entranceController.forward(from: 0);
    } else {
      _arrowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleCrops = _showAll
        ? widget.crops
        : widget.crops.take(_initialCount).toList();
    final hasMore = widget.crops.length > _initialCount;

    return Column(
      children: [
        // ── Crop Chips wrapped layout ──
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(visibleCrops.length, (i) {
              final crop = visibleCrops[i];
              final isSelected = widget.selected?.id == crop.id;

              // Staggered entrance
              final delay = (i * 0.07).clamp(0.0, 1.0);
              final end = (delay + 0.45).clamp(0.0, 1.0);
              final entranceAnim = CurvedAnimation(
                parent: _entranceController,
                curve: Interval(delay, end, curve: Curves.easeOutBack),
              );

              return AnimatedBuilder(
                listenable: Listenable.merge([entranceAnim, _bounceAnim]),
                builder: (context, child) {
                  final entranceScale = entranceAnim.value;
                  final isTapped = _tappedIndex == i;
                  final bounce = isTapped ? _bounceAnim.value : 1.0;
                  final s = entranceScale * bounce;
                  return Transform.scale(
                    scale: s.clamp(0.0, 1.2),
                    child: Opacity(
                      opacity: entranceScale.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () => _handleTap(i, crop),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.sunYellow
                            : Colors.white.withValues(alpha: 0.35),
                        width: isSelected ? 2.2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.sunYellow.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(crop.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              crop.name,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.textDark
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              crop.nameSanskrit,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                height: 1.1,
                                color: isSelected
                                    ? AppColors.textLight
                                    : Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // ── See All / Show Less ──
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GestureDetector(
              onTap: _toggleShowAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showAll ? 'Show Less' : 'See All Crops',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    RotationTransition(
                      turns: _arrowRotation,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── AnimatedBuilder helper ───────────────────────────────────────────────────
class AnimatedBuilder extends AnimatedWidget {
  final TransitionBuilder builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) => builder(context, child);
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LocationModel>(
          isExpanded: true,
          dropdownColor: const Color(0xFF2E7D32),
          value: selected,
          hint: Text(
            '🗺  Select your village / city',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          items: locations.map((loc) {
            return DropdownMenuItem<LocationModel>(
              value: loc,
              child: Text(
                '📍 ${loc.name}, ${loc.state}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
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
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.sunYellow.withValues(alpha: 0.5),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Get AI Recommendation',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
