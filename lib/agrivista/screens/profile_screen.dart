import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Profile Header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            title: Text(
              'My Profile',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.homeGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Center(
                          child: Text('🧑‍🌾', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ramesh Kumar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Farmer  •  Nagpur, Maharashtra',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Content ──────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(14),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                _StatsRow(),
                const SizedBox(height: 18),
                // Profile info card
                _ProfileInfoCard(),
                const SizedBox(height: 14),
                // My crops card
                _MyCropsCard(),
                const SizedBox(height: 14),
                // Settings card
                _SettingsCard(context: context),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'emoji': '📋', 'value': '12', 'label': 'Reports'},
      {'emoji': '🌾', 'value': '3', 'label': 'Crops'},
      {'emoji': '💰', 'value': '₹62K', 'label': 'Saved'},
      {'emoji': '⭐', 'value': '4.8', 'label': 'Rating'},
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
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
              children: [
                Text(s['emoji']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  s['value']!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  s['label']!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Profile Info Card ─────────────────────────────────────────────────────────
class _ProfileInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'My Information',
      emoji: '👤',
      children: [
        _ProfileRow(
          icon: Icons.person_outline,
          label: 'Name',
          value: 'Ramesh Kumar',
        ),
        _ProfileRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: '+91 98765 43210',
        ),
        _ProfileRow(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: 'Nagpur, Maharashtra',
        ),
        _ProfileRow(
          icon: Icons.landscape_outlined,
          label: 'Farm Size',
          value: '5.5 Acres',
        ),
        _ProfileRow(
          icon: Icons.calendar_today_outlined,
          label: 'Member Since',
          value: 'Jan 2025',
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textDark),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── My Crops Card ─────────────────────────────────────────────────────────────
class _MyCropsCard extends StatelessWidget {
  final _crops = const [
    {'emoji': '🍅', 'name': 'Tomato', 'season': 'Rabi'},
    {'emoji': '🧅', 'name': 'Onion', 'season': 'Kharif'},
    {'emoji': '🌱', 'name': 'Soybean', 'season': 'Kharif'},
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'My Crops',
      emoji: '🌾',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _crops.map((c) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.softGreen),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c['emoji']!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['name']!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        c['season']!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final BuildContext context;

  const _SettingsCard({required this.context});

  @override
  Widget build(BuildContext _) {
    final items = [
      {'icon': Icons.language, 'label': 'Language', 'value': 'Hindi'},
      {
        'icon': Icons.notifications_outlined,
        'label': 'Notifications',
        'value': 'On',
      },
      {
        'icon': Icons.wifi_off_outlined,
        'label': 'Offline Mode',
        'value': 'Enabled',
      },
      {'icon': Icons.help_outline, 'label': 'Help & Support', 'value': ''},
      {'icon': Icons.info_outline, 'label': 'App Version', 'value': 'v1.0.0'},
    ];

    return _SectionCard(
      title: 'Settings',
      emoji: '⚙️',
      children: items.map((item) {
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 20,
                  color: AppColors.textDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if ((item['value'] as String).isNotEmpty)
                  Text(
                    item['value'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Reusable Section Card ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.emoji,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
