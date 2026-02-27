import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

/// Language selection screen — shown on first app launch.
/// Farmer picks their preferred language before anything else.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedLanguage;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    if (_selectedLanguage == null) return;

    final langProvider = context.read<LanguageProvider>();
    final authProvider = context.read<AuthProvider>();

    langProvider.setLanguage(_selectedLanguage!);
    await authProvider.completeLanguageSelection();

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final languages = LanguageProvider.supportedLanguages;
    final emojis = LanguageProvider.languageEmojis;

    // Native script names for display
    const nativeNames = {
      'English': 'English',
      'Hindi': 'हिंदी',
      'Hinglish': 'Hinglish',
      'Marathi': 'मराठी',
      'Tamil': 'தமிழ்',
      'Telugu': 'తెలుగు',
      'Bengali': 'বাংলা',
      'Kannada': 'ಕನ್ನಡ',
      'Gujarati': 'ગુજરાતી',
      'Punjabi': 'ਪੰਜਾਬੀ',
    };

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ── Header ────────────────────────────────────────────
                  Text('🌾', style: GoogleFonts.poppins(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    'Agri Vista',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose Your Language',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    'अपनी भाषा चुनें',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Language Grid ─────────────────────────────────────
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.6,
                          ),
                      itemCount: languages.length,
                      itemBuilder: (context, index) {
                        final lang = languages[index];
                        final isSelected = _selectedLanguage == lang;
                        final emoji = emojis[lang] ?? '🌐';
                        final native = nativeNames[lang] ?? lang;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedLanguage = lang),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : Colors.white.withValues(alpha: 0.3),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryGreen
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  native,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : Colors.white,
                                  ),
                                ),
                                if (lang != native)
                                  Text(
                                    lang,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: isSelected
                                          ? AppColors.textMedium
                                          : Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Continue Button ───────────────────────────────────
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedLanguage != null ? _onContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.3,
                        ),
                        disabledForegroundColor: Colors.white.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _selectedLanguage != null ? 4 : 0,
                      ),
                      child: Text(
                        _selectedLanguage != null
                            ? 'Continue →'
                            : 'Select a language',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
