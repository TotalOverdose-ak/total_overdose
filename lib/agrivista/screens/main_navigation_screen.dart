import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'history_screen.dart';
import 'market_prices_screen.dart';
import 'godown_screen.dart';
import 'harvest_screen.dart';
import 'market_recommendation_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const MarketPricesScreen(),
    const GodownScreen(),
    const HarvestScreen(),
    const MarketRecommendationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    final navItems = [
      _NavItem(icon: Icons.home_rounded, label: lang.tr('nav_home'), emoji: '🏠'),
      _NavItem(icon: Icons.history_rounded, label: lang.tr('nav_history'), emoji: '📋'),
      _NavItem(icon: Icons.store, label: lang.tr('nav_mandi'), emoji: '💹'),
      _NavItem(icon: Icons.warehouse_rounded, label: lang.tr('nav_godown'), emoji: '🏭'),
      _NavItem(icon: Icons.agriculture, label: lang.tr('nav_harvest'), emoji: '🌾'),
      _NavItem(icon: Icons.gps_fixed_rounded, label: lang.tr('nav_best_market'), emoji: '🎯'),
      _NavItem(icon: Icons.person_rounded, label: lang.tr('nav_profile'), emoji: '👤'),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _AgriVistaBottomNav(
        currentIndex: _currentIndex,
        items: navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Custom Bottom Nav ─────────────────────────────────────────────────────────
class _AgriVistaBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _AgriVistaBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isSelected = i == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mintGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            item.icon,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.textLight,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String emoji;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.emoji,
  });
}
